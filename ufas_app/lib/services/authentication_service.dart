import 'dart:convert';

import 'package:ufas_app/services/shared_pref.dart';

import '../exceptions/exceptions.dart';
import '../models/models.dart';
import 'package:http/http.dart' as http;

abstract class AuthenticationService {
  Future<User> getCurrentUser();
  Future<User> signInWithEmailAndPassword(String email, String password);
  Future<User> signInWithUuid(String uuid);
  Future<User> signUpWithEmailAndPassword(
      String email, String password, String referralCode);
  Future<void> signOut();
}

class MyAuthenticationService extends AuthenticationService {
  final String api = 'https://192.168.1.54:3000';

  @override
  Future<User> getCurrentUser() async {
    try {
      var user = User.fromJson(await SharedPref.read('user'));
      return user;
    } catch (Excepetion) {
      return null;
    }
  }

  @override
  Future<User> signInWithUuid(String uuid) async {
    final url = "$api/uuid_signin";

    Map<String, String> body = {
      'uuid': uuid,
    };

    final jsonBody = jsonEncode(body);
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonBody,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> apiResponse = jsonDecode(response.body);
      var user = User(
          token: apiResponse['token'],
          email: apiResponse['user']['email'],
          uuid: apiResponse['user']['uuid']);
      await SharedPref.save('user', user);

      return user;
    }

    throw AuthenticationException(message: 'Wrong UUID');
  }

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    final url = "$api/signin";

    Map<String, String> body = {
      'email': email,
      'password': password,
    };

    final jsonBody = jsonEncode(body);
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonBody,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> apiResponse = jsonDecode(response.body);
      var user = User(
          token: apiResponse['token'],
          email: apiResponse['user']['email'],
          uuid: apiResponse['user']['uuid']);
      await SharedPref.save('user', user);

      return user;
    }

    throw AuthenticationException(message: 'Wrong username or password');
  }

  @override
  Future<User> signUpWithEmailAndPassword(
      String email, String password, String referralCode) async {
    final url = "$api/signup";

    Map<String, String> body = {
      'email': email,
      'password': password,
      'referral_code': referralCode
    };

    final jsonBody = jsonEncode(body);
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonBody,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> apiResponse = jsonDecode(response.body);
      var user = User(
          token: apiResponse['token'],
          email: apiResponse['user']['email'],
          uuid: apiResponse['user']['uuid']);
      await SharedPref.save('user', user);

      return user;
    }

    throw AuthenticationException(message: 'Wrong username or password');
  }

  @override
  Future<void> signOut() async {
    await SharedPref.remove('user');
    return null;
  }
}
