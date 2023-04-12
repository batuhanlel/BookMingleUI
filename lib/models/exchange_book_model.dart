class ExchangeBookResponseModel {
  final int bookId;
  final String title;
  final String author;
  final int userId;
  final String userName;
  final String userSurname;
  final String userEmail;
  final String error;
  final Map<String, dynamic> errors;

  ExchangeBookResponseModel(
    this.bookId,
    this.title,
    this.author,
    this.userId,
    this.userName,
    this.userSurname,
    this.userEmail,
    this.error,
    this.errors,
  );

  factory ExchangeBookResponseModel.fromJson(Map<String, dynamic> json) {
    return ExchangeBookResponseModel(
        json["bookId"] ?? "",
        json["title"] ?? "",
        json["author"] ?? "",
        json["userId"] ?? "",
        json["userName"] ?? "",
        json["userSurname"] ?? "",
        json["userEmail"] ?? "",
        json["error"] ?? "",
        json["errors"] ?? {});
  }
}

class ExchangeBookRequestModel {
  String? searchText;
  String? sort;
  int page;
  int? length;

  ExchangeBookRequestModel({
    this.searchText,
    this.sort = 'title',
    required this.page,
    this.length = 3,
  });

  Map<String, dynamic> toQueryParam() {
    return <String, dynamic>{
      "searchText": searchText,
      "sort": sort,
      "page": page.toString(),
      "length": length.toString(),
    };
  }
}
