import 'dart:convert';

import 'package:book_mingle_ui/models/user_model.dart';

List<Chat> chatFromJson(String str) =>
    List<Chat>.from(json.decode(str).map((x) => Chat.fromJson(x)));

String chatToJson(List<Chat> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Chat {
  User receiver;
  dynamic lastMessage;
  dynamic updatedAt;

  Chat({
    required this.receiver,
    this.lastMessage,
    this.updatedAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        receiver: User.fromJson(json["receiver"]),
        lastMessage: json["lastMessage"],
        updatedAt: json["updatedAt"],
      );

  Map<String, dynamic> toJson() => {
        "user": receiver.toJson(),
        "lastMessage": lastMessage,
        "updatedAt": updatedAt,
      };
}
