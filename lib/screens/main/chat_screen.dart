import 'dart:convert';
import 'dart:math';

import 'package:book_mingle_ui/constant.dart';
import 'package:book_mingle_ui/models/message_model.dart';
import 'package:book_mingle_ui/models/user_model.dart';
import 'package:book_mingle_ui/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class ChatScreen extends StatefulWidget {
  final User receiver;
  final User sender;

  const ChatScreen({Key? key, required this.receiver, required this.sender})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late StompClient _stompClient;
  late String? _token;
  late types.User _senderForChat;
  late types.User _receiverForChat;
  late User _sender;
  late User _receiver;
  int _page = 0;
  bool _hasNextPage = true;

  List<types.Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _sender = widget.sender;
    _senderForChat = types.User(id: widget.sender.id.toString());
    _receiver = widget.receiver;
    _receiverForChat = types.User(id: widget.receiver.id.toString());

    _handleEndReached();

    const storage = FlutterSecureStorage();
    Future<String?> getToken() async {
      return await storage.read(key: 'token');
    }

    getToken().then((token) {
      setState(() {
        _token = token;
        _stompClient = StompClient(
          config: StompConfig(
            url: webSocketUrl,
            onConnect: onConnectCallback,
            webSocketConnectHeaders: {
              'Authorization': 'Bearer $_token',
            },
          ),
        );
        _stompClient.activate();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _stompClient.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _senderForChat,
        onEndReached: _handleEndReached,
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: Colors.grey,
        onPressed: _navigateToChatListScreen,
      ),
      title: Text(
        "${_receiver.name} ${_receiver.surname}",
        style: TextStyle(
          fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  void _navigateToChatListScreen() {
    Navigator.of(context).pop();
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _senderForChat,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );

    String content = message.text;
    _stompClient.send(
      destination: '/app/chat',
      body: jsonEncode({
        "senderId": _sender.id,
        "receiverId": _receiver.id,
        "content": content,
      }),
    );
    _addMessage(textMessage);
  }

  Future<void> _handleEndReached() async {
    if (!_hasNextPage) return;

    List<ChatMessage> prevMessages =
        await ApiService.getChatMessages(_page, _sender.id, _receiver.id);

    if (prevMessages.isEmpty) {
      setState(() {
        _hasNextPage = false;
      });
      return;
    }

    List<types.Message> processedMessages = [];
    for (ChatMessage message in prevMessages) {
      processedMessages.add(
        types.TextMessage(
          author: message.senderId == _sender.id
              ? _senderForChat
              : _receiverForChat,
          id: randomString(),
          text: message.content,
        ),
      );
    }

    setState(() {
      _messages = [..._messages, ...processedMessages];
      _page = _page + 1;
    });
  }

  String randomString() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  void onConnectCallback(StompFrame connectFrame) {
    // client is connected and ready
    var senderId = _sender.id;
    _stompClient.subscribe(
      destination: '/user/$senderId/queue/messages',
      callback: (StompFrame stompFrame) {
        final messageJson = jsonDecode(stompFrame.body!);
        var message = types.TextMessage(
          author: _receiverForChat,
          id: randomString(),
          text: messageJson['content'],
        );
        _addMessage(message);
      },
    );
  }
}
