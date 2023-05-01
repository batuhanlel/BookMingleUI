import 'dart:convert';

ExchangeDemandRequest exchangeDemandRequestFromJson(String str) => ExchangeDemandRequest.fromJson(json.decode(str));

String exchangeDemandRequestToJson(ExchangeDemandRequest data) => json.encode(data.toJson());

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
  };}
