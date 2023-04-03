import 'dart:convert';

class LoginResponseModel {
  final String token;
  final String error;

  LoginResponseModel(
    this.token,
    this.error,
  );

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(json["token"] ?? "", json["error"] ?? "");
  }
}

class LoginRequestModel {
  String? email;
  String? password;

  LoginRequestModel({
    this.password,
    this.email,
  });

  String toJson() {
    return jsonEncode(<String, dynamic>{
      "email": email,
      "password": password,
    });
  }
}
