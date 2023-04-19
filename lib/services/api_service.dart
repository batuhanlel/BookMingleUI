import 'dart:convert';
import 'package:book_mingle_ui/models/exchange_book_model.dart';
import 'package:book_mingle_ui/models/login_model.dart';
import 'package:book_mingle_ui/models/signup_model.dart';
import 'package:book_mingle_ui/models/user_profile_model.dart';
import 'package:book_mingle_ui/constant.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  static Future<List<ExchangeBookResponseModel>> exchangeBookRecommendation(ExchangeBookRequestModel requestModel) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    String url = "$baseUrl/exchange/list/get";
    final headers = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Accept' : '*/*',
      'Authorization' : 'Bearer $token'
    };

    final response = await http.get(Uri.parse(url).replace(queryParameters: requestModel.toQueryParam()), headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> jsonArray = jsonDecode(response.body);
      List<ExchangeBookResponseModel> items = [];
      for (var i = 0; i < jsonArray.length; i++) {
        items.add(ExchangeBookResponseModel.fromJson(jsonArray[i]));
      }
      return items;
    } else {
      throw Exception("Failed to Get Data");
    }
  }

  static Future<UserProfileResponseModel> userProfile() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    String url = "$baseUrl/user/me";
    final headers = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Accept' : '*/*',
      'Authorization' : 'Bearer $token'
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return userProfileResponseFromJson(response.body);
    } else {
      throw Exception("Failed to Get Data");
    }

  }
}
