import 'dart:convert';

Book bookFromJson(String str) => Book.fromJson(json.decode(str));
String bookToJson(Book data) => json.encode(data.toJson());

List<Book> bookListFromJson(String str) => List<Book>.from(json.decode(str).map((x) => Book.fromJson(x)));
String bookListToJson(List<Book> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Book {
  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.publisher,
    required this.imageUrl,
  });

  int id;
  String title;
  String author;
  String publisher;
  String imageUrl;

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json["id"],
    title: json["title"],
    author: json["author"],
    publisher: json["publisher"],
    imageUrl: json["imageUrl"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "author": author,
    "publisher": publisher,
    "imageUrl": imageUrl,
  };
}
