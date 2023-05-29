import 'dart:convert';

List<ChatMessage> messageFromJson(String str) => List<ChatMessage>.from(
    json.decode(str).map((x) => ChatMessage.fromJson(x)));

String messageToJson(List<ChatMessage> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ChatMessage {
  int senderId;
  int receiverId;
  String content;

  ChatMessage({
    required this.senderId,
    required this.receiverId,
    required this.content,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        senderId: json["senderId"],
        receiverId: json["receiverId"],
        content: json["content"],
      );

  Map<String, dynamic> toJson() => {
        "senderId": senderId,
        "receiverId": receiverId,
        "content": content,
      };
}
