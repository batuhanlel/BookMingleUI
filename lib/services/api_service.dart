import 'dart:convert';

import 'package:book_mingle_ui/constant.dart';
import 'package:book_mingle_ui/models/book_model.dart';
import 'package:book_mingle_ui/models/chat_model.dart';
import 'package:book_mingle_ui/models/exchange_book_model.dart';
import 'package:book_mingle_ui/models/exchange_demand_model.dart';
import 'package:book_mingle_ui/models/login_model.dart';
import 'package:book_mingle_ui/models/message_model.dart';
import 'package:book_mingle_ui/models/signup_model.dart';
import 'package:book_mingle_ui/models/user_model.dart';
import 'package:book_mingle_ui/models/user_profile_model.dart';
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

  static Future<List<ExchangeBookResponseModel>> exchangeBookRecommendations() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    String url = "$baseUrl/exchange/recommendations";
    final headers = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Accept' : '*/*',
      'Authorization' : 'Bearer $token'
    };

    final response = await http.get(Uri.parse(url), headers: headers);
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

  static Future<List<ExchangeBookResponseModel>> exchangeBookSearch(ExchangeBookRequestModel requestModel) async {
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

  static Future<User> userAbout() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    String url = "$baseUrl/user/about";
    final headers = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Accept' : '*/*',
      'Authorization' : 'Bearer $token'
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return userFromJson(response.body);
    } else {
      throw Exception("Failed to Get Data");
    }

  }

  static Future<UserProfileResponseModel> userProfile() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    String url = "$baseUrl/user/profile";
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

  static Future<List<Book>> getBookList(String query) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    String url = "$baseUrl/book/list";
    final headers = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Accept' : '*/*',
      'Authorization' : 'Bearer $token'
    };

    Map<String, dynamic> params = {"search": query};
    final response = await http.get(Uri.parse(url).replace(queryParameters: params), headers: headers);

    if (response.statusCode == 200) {
      return bookListFromJson(response.body);
    } else {
      throw Exception("Failed to Get Data");
    }
  }

  static Future<List<Book>> getUserBookList() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    String url = "$baseUrl/user/books";
    final headers = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Accept' : '*/*',
      'Authorization' : 'Bearer $token'
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return bookListFromJson(response.body);
    } else {
      throw Exception("Failed to Get Data");
    }
  }

  static Future<bool> createExchangeRequest(ExchangeDemandRequest request) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    String url = "$baseUrl/exchange/request";
    final headers = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Accept' : '*/*',
      'Authorization' : 'Bearer $token'
    };

    final response = await http.post(Uri.parse(url), headers: headers, body: exchangeDemandRequestToJson(request));

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception("Failed to Get Data");
    }
  }

  static Future<List<ExchangeDemandResponse>> getExchangeDemands(int page) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    String url = "$baseUrl/exchange/demand/get";
    final headers = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Accept' : '*/*',
      'Authorization' : 'Bearer $token'
    };

    Map<String, dynamic> params = {"page": page.toString()};
    final response = await http.get(Uri.parse(url).replace(queryParameters: params), headers: headers);

    if (response.statusCode == 200) {
      return exchangeDemandResponseFromJson(response.body);
    } else {
      throw Exception("Failed to Get Data");
    }
  }

  static Future<bool> addBookToLibrary(int bookId) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    String url = "$baseUrl/user/add/book/$bookId";
    final headers = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Accept' : '*/*',
      'Authorization' : 'Bearer $token'
    };

    final response = await http.post(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> updateExchangeDemandStatus(int demandId, bool isAccepted) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    String url = "$baseUrl/exchange/demand/$demandId";
    final headers = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Accept' : '*/*',
      'Authorization' : 'Bearer $token'
    };

    final response = await http.put(Uri.parse(url), headers: headers, body: isAccepted.toString());

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future<List<Chat>> getChatsInfo() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    String url = "$baseUrl/chat/list/user/get";
    final headers = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Accept' : '*/*',
      'Authorization' : 'Bearer $token'
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return chatFromJson(response.body);
    } else {
      throw Exception("Failed to Get Data");
    }
  }

  static Future<List<ChatMessage>> getChatMessages(int page, int user1Id, int user2Id) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    String url = "$baseUrl/chat/messages/get";
    final headers = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Accept' : '*/*',
      'Authorization' : 'Bearer $token'
    };

    Map<String, dynamic> params = {
      "page": page.toString(),
      "user1Id": user1Id.toString(),
      "user2Id": user2Id.toString(),
    };
    final response = await http.get(Uri.parse(url).replace(queryParameters: params), headers: headers);


    if (response.statusCode == 200) {
      return messageFromJson(response.body);
    } else {
      throw Exception("Failed to Get Data");
    }
  }
}
