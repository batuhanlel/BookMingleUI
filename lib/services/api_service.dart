import 'dart:convert';
import 'package:book_mingle_ui/models/login_model.dart';
import 'package:book_mingle_ui/models/signup_model.dart';
import 'package:book_mingle_ui/constant.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<LoginResponseModel> login(
      LoginRequestModel requestModel) async {
    String url = "$baseUrl/auth/login";
    final headers = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
    };

    final response = await http.post(Uri.parse(url),
        headers: headers, body: requestModel.toJson());

    if (response.statusCode == 200 || response.statusCode == 400) {
      return LoginResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to Get Data");
    }
  }

  static Future<SignUpResponseModel> signup(
      SignUpRequestModel requestModel) async {
    String url = "$baseUrl/auth/register";
    final headers = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Accept' : '*/*'
    };

    final response = await http.post(Uri.parse(url),
        headers: headers, body: requestModel.toJson());

    if (response.statusCode == 200 || response.statusCode == 400) {
      return SignUpResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to Get Data");
    }
  }
}
