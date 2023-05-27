import 'package:book_mingle_ui/models/chat_model.dart';
import 'package:book_mingle_ui/models/user_model.dart';
import 'package:book_mingle_ui/screens/exchange_demands_screen.dart';
import 'package:book_mingle_ui/screens/main/navigation_screens/chat_screen.dart';
import 'package:book_mingle_ui/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with AutomaticKeepAliveClientMixin {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  List<Chat> _chatInfoItems = [];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SmartRefresher(
          controller: _refreshController,
          header: const WaterDropHeader(),
          onRefresh: _onRefresh,
          child: _buildListView(),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: const Text(
        'Chats',
        style: TextStyle(color: Colors.black),
      ),
      actions: [
        TextButton(
            onPressed: _navigateToExchangeDemandsScreen,
            child: const Text('Exchange Requests'))
      ],
    );
  }

  Future<void> _onRefresh() async {
    bool isSuccessful = await _firstLoad();
    isSuccessful
        ? _refreshController.refreshCompleted()
        : _refreshController.refreshFailed();
  }

  Future<bool> _firstLoad() async {
    try {
      List<Chat> chatsInfo = await ApiService.getChatsInfo();
      setState(() {
        _chatInfoItems = chatsInfo;
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  ListView _buildListView() {
    return ListView.builder(
      itemCount: _chatInfoItems.length,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () => _navigateToChatScreen(_chatInfoItems[index]),
        child: Card(
          margin: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 10,
          ),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(index.toString()),
            ),
            title: Text(
                "${_chatInfoItems[index].receiver.name} ${_chatInfoItems[index].receiver.surname}"),
            subtitle: Text(_chatInfoItems[index].lastMessage ?? ''),
          ),
        ),
      ),
    );
  }

  void _navigateToChatScreen(Chat chat) async {
    const storage = FlutterSecureStorage();
    User chatSender = User(
        id: int.parse(await storage.read(key: 'userId') as String),
        name: await storage.read(key: 'name') as String,
        surname: await storage.read(key: 'surname') as String,
        email: await storage.read(key: 'email') as String,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context)  {
          return ChatScreen(receiver: chat.receiver, sender: chatSender,);
        },
      ),
    );
  }

  void _navigateToExchangeDemandsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const ExchangeDemandsScreen();
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
