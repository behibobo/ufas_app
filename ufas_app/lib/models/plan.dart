class Plan {
  int id;
  String name;
  int days;

  Plan({this.id, this.name, this.days});

  Plan.fromJson(Map json)
      : id = json['id'],
        name = json['name'],
        days = json['days'];
}
