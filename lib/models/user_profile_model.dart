// To parse this JSON data, do
//
//     final userProfileResponse = userProfileResponseFromJson(jsonString);

import 'dart:convert';

import 'package:book_mingle_ui/models/book_model.dart';

UserProfileResponseModel userProfileResponseFromJson(String str) =>
    UserProfileResponseModel.fromJson(json.decode(str));

String userProfileResponseToJson(UserProfileResponseModel data) =>
    json.encode(data.toJson());

class UserProfileResponseModel {
  UserProfileResponseModel({
    required this.email,
    required this.name,
    required this.surname,
    required this.bookCount,
    required this.successfulExchangeCount,
    required this.books,
  });

  String email;
  String name;
  String surname;
  int bookCount;
  int successfulExchangeCount;
  List<Book> books;

  factory UserProfileResponseModel.fromJson(Map<String, dynamic> json) =>
      UserProfileResponseModel(
        email: json["email"],
        name: json["name"],
        surname: json["surname"],
        bookCount: json["bookCount"],
        successfulExchangeCount: json["successfulExchangeCount"],
        books: List<Book>.from(json["books"].map((x) => Book.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "name": name,
        "surname": surname,
        "bookCount": bookCount,
        "successfulExchangeCount": successfulExchangeCount,
        "books": List<dynamic>.from(books.map((x) => x.toJson())),
      };
}

