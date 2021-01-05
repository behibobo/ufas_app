import 'package:ufas_app/models/server.dart';

class Region {
  final String region;
  final List<Server> servers;

  Region({this.region, this.servers});

  factory Region.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['servers'] as List;
    List<Server> serverList = list.map((i) => Server.fromJson(i)).toList();

    return Region(region: parsedJson['region'], servers: serverList);
  }
}
