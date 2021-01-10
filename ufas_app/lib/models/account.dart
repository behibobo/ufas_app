import 'package:ufas_app/models/plan.dart';

class Account {
  final String startedDate;
  final String expireDate;
  final int daysLeft;
  final Plan plan;
  final bool active;

  Account(
      {this.startedDate,
      this.expireDate,
      this.daysLeft,
      this.plan,
      this.active});

  factory Account.fromJson(Map<String, dynamic> parsedJson) {
    return Account(
        startedDate: parsedJson['started_date'],
        expireDate: parsedJson['expire_date'],
        daysLeft: parsedJson['days_left'],
        active: parsedJson['active'],
        plan: Plan.fromJson(parsedJson['plan']));
  }
}
