import 'dart:convert';

import 'package:book_mingle_ui/models/book_model.dart';
import 'package:book_mingle_ui/models/user_model.dart';

ExchangeDemandRequest exchangeDemandRequestFromJson(String str) =>
    ExchangeDemandRequest.fromJson(json.decode(str));

String exchangeDemandRequestToJson(ExchangeDemandRequest data) =>
    json.encode(data.toJson());

class ExchangeDemandRequest {
  int proposedBookId;
  int requestedUserId;
  int requestedBookId;

  ExchangeDemandRequest({
    required this.proposedBookId,
    required this.requestedUserId,
    required this.requestedBookId,
  });

  factory ExchangeDemandRequest.fromJson(Map<String, dynamic> json) => ExchangeDemandRequest(
    proposedBookId: json["proposedBookId"],
    requestedUserId: json["requestedUserId"],
    requestedBookId: json["requestedBookId"],
  );

  Map<String, dynamic> toJson() => {
        "proposedBookId": proposedBookId,
        "requestedUserId": requestedUserId,
        "requestedBookId": requestedBookId,
      };
}

List<ExchangeDemandResponse> exchangeDemandResponseFromJson(String str) =>
    List<ExchangeDemandResponse>.from(json.decode(str).map((x) => ExchangeDemandResponse.fromJson(x)));
String exchangeDemandResponseToJson(List<ExchangeDemandResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ExchangeDemandResponse {
  int requestId;
  String requestStatus;
  String requestType;
  dynamic requestDate;
  dynamic acceptedDate;
  Book proposedBook;
  Book requestedBook;
  User requesterUser;

  ExchangeDemandResponse({
    required this.requestId,
    required this.requestStatus,
    required this.requestType,
    this.requestDate,
    this.acceptedDate,
    required this.proposedBook,
    required this.requestedBook,
    required this.requesterUser,
  });

  factory ExchangeDemandResponse.fromJson(Map<String, dynamic> json) =>
      ExchangeDemandResponse(
        requestId: json["requestId"],
        requestStatus: json["requestStatus"],
        requestType: json["requestType"],
        requestDate: json["requestDate"],
        acceptedDate: json["acceptedDate"],
        proposedBook: Book.fromJson(json["proposedBook"]),
        requestedBook: Book.fromJson(json["requestedBook"]),
        requesterUser: User.fromJson(json["requesterUser"]),
      );

  Map<String, dynamic> toJson() => {
        "requestId": requestId,
        "requestStatus": requestStatus,
        "requestType": requestType,
        "requestDate": requestDate,
        "acceptedDate": acceptedDate,
        "proposedBook": proposedBook.toJson(),
        "requestedBook": requestedBook.toJson(),
        "requesterUser": requesterUser.toJson(),
      };
}
