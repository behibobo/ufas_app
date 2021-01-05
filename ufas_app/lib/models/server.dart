class Server {
  int id;
  String country;
  String flag;
  String host;
  bool premium;

  Server({this.id, this.country, this.flag, this.host, this.premium});

  Server.fromJson(Map json)
      : id = json['id'],
        country = json['country'],
        flag = json['flag'],
        host = json['host'],
        premium = json['premium'];

  Map toJson() {
    return {
      'id': id,
      'country': country,
      'flag': flag,
      'host': host,
      'premium': premium,
    };
  }
}
