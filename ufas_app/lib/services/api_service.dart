import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ufas_app/models/account.dart';

const baseUrl = "https://192.168.1.54:3000/api";

class APIService {
  static Future<Account> getAccount(String token) async {
    var url = baseUrl + '/account';

    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> apiResponse = json.decode(response.body);
      var acc = Account.fromJson(apiResponse);
      return acc;
    }

    return null;
  }

  static Future<String> getReferrer(String referrerCode) async {
    final url = "$baseUrl/referrer/$referrerCode";

    final response =
        await http.get(url, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      Map<String, dynamic> apiResponse = json.decode(response.body);
      return apiResponse["result"];
    }

    return "error";
  }

  static Future<bool> emailExists(String email) async {
    final url = "$baseUrl/email_exists";

    Map<String, String> body = {
      'email': email,
    };

    final jsonBody = jsonEncode(body);

    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'}, body: jsonBody);

    if (response.statusCode == 200) {
      Map<String, dynamic> apiResponse = json.decode(response.body);
      return apiResponse["result"];
    }
    return false;
  }

  static Future getServers() {
    var url = baseUrl + "/servers";
    return http.get(url);
  }
}
