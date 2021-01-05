import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ufas_app/models/region.dart';
import 'package:ufas_app/models/server.dart';
import 'package:ufas_app/services/api_service.dart';
import '../models/models.dart';

class ServersPage extends StatefulWidget {
  final User user;

  const ServersPage({Key key, this.user}) : super(key: key);

  @override
  _ServersPageState createState() => _ServersPageState();
}

class _ServersPageState extends State<ServersPage> {
  Server selectedServer = null;

  Future<List<Region>> _getServers() async {
    var response = await APIService.getServers();
    Iterable list = await json.decode(response.body);
    var connections = list.map((model) => Region.fromJson(model)).toList();
    return connections;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        child: Scaffold(
            backgroundColor: Colors.transparent,
            // drawer: MainDrawer(),
            body: FutureBuilder(
              future: _getServers(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return new Text('loading...');
                  default:
                    if (snapshot.hasError)
                      return new Text('Error: ${snapshot.error}');
                    else
                      return createListView(context, snapshot);
                }
              },
            )));
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    List<Region> values = snapshot.data;
    return new ListView.builder(
      itemCount: values.length,
      itemBuilder: (BuildContext context, int index) {
        Region region = values[index];
        List<Server> servers = region.servers;
        return new Column(
          children: <Widget>[
            Container(
                child: Column(
              children: [serverList(servers)],
            )),
            new Divider(
              height: 2.0,
            ),
          ],
        );
      },
    );
  }

  Widget serverList(List<Server> servers) {
    return new Column(
        children: servers
            .map((item) => new GestureDetector(
                onTap: () {
                  setState(() {
                    selectedServer = item;
                  });
                },
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    margin: EdgeInsets.symmetric(vertical: 2),
                    // decoration: BoxDecoration(
                    //     border: Border.all(
                    //   color: Colors.grey[200],
                    // )),
                    child: Row(
                      children: [
                        // Image.network(
                        //   item.flag,
                        //   width: 35,
                        // ),
                        SizedBox(
                          width: 15,
                        ),
                        Expanded(child: Text("Country")),
                        Row(children: [
                          // Image.asset(
                          //   "assets/connection.png",
                          //   width: 20,
                          // ),
                          SizedBox(
                            width: 10,
                          ),
                          Text("121"),
                        ]),
                        SizedBox(
                          width: 15,
                        )
                      ],
                    ))))
            .toList());
  }
}
