import 'dart:convert';

class SignUpResponseModel {
  final String token;
  final Map<String, dynamic> errors;

  SignUpResponseModel(
    this.token,
    this.errors,
  );

  factory SignUpResponseModel.fromJson(Map<String, dynamic> json) {
    return SignUpResponseModel( json["token"]?? "", json["errors"] ?? {});
  }
}

class SignUpRequestModel {
  String? name;
  String? surname;
  String? phoneNumber;
  String? email;
  String? password;

  SignUpRequestModel({
    this.name,
    this.surname,
    this.phoneNumber,
    this.email,
    this.password,
  });

  String toJson() {
    return jsonEncode(<String, dynamic>{
      "name" : name,
      "surname" : surname,
      "phoneNumber" : phoneNumber,
      "email": email,
      "password": password,
    });
  }
}
