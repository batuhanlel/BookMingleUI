import 'dart:convert';

class LoginResponseModel {
  final String token;
  final String error;
  final Map<String, dynamic> errors;

  LoginResponseModel(
    this.token,
    this.error,
    this.errors,
  );

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(json["token"] ?? "", json["error"] ?? "", json["errors"] ?? {});
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
