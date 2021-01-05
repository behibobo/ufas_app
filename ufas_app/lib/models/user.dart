import 'package:meta/meta.dart';

class User {
  final String email;
  final String token;
  final String uuid;

  User({@required this.email, this.token, this.uuid});

  User.fromJson(Map json)
      : email = json['email'],
        token = json['token'],
        uuid = json['uuid'];

  @override
  String toString() => 'User {  email: $email}';

  Map<String, dynamic> toJson() => {
        'email': email,
        'token': token,
        'uuid': uuid,
      };
}
