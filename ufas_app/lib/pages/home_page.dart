import 'dart:developer';

import 'package:animator/animator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_vpn/flutter_vpn.dart';
import 'package:ufas_app/blocs/authentication/authentication.dart';
import 'package:ufas_app/models/server.dart';
import 'package:ufas_app/pages/profile_page.dart';
import 'package:ufas_app/pages/servers_page.dart';
import 'package:ufas_app/services/api_service.dart';
import '../helper.dart';
import '../models/models.dart';

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({Key key, this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var state = FlutterVpnState.disconnected;
  final String logOut = 'assets/logout.svg';
  Future<dynamic> data;
  int serverType = 1;
  Server selectedServer = null;

  Future<dynamic> _getAccount() async {
    var _res = await APIService.getAccount(widget.user.token);
    return _res;
  }

  @override
  void initState() {
    setState(() {
      data = _getAccount();
    });
    FlutterVpn.prepare();
    FlutterVpn.onStateChanged.listen((s) {
      if (s == FlutterVpnState.connected) {
        // Device Connected
      }
      if (s == FlutterVpnState.disconnected) {
        // Device Disconnected
      }
      setState(() {
        state = s;
      });
    });

    super.initState();
  }

  void ikevConnect() {
    if (state == FlutterVpnState.connected ||
        state == FlutterVpnState.genericError) {
      FlutterVpn.disconnect();
    } else {
      FlutterVpn.simpleConnect(
          "grikvewhsona.ufasvpn.com", "behzad", "1234@qwerB");
    }
  }

  void connectVpn() {
    switch (serverType) {
      case 2:
        {
          log("vpn connection type => openVPN(TCP)");
        }
        break;

      case 3:
        {
          log("vpn connection type => openVPN(UDP)");
        }
        break;

      default:
        {
          log("vpn connection type => ikev");
          // ikevConnect();
        }
        break;
    }
  }

  Container _itemDown() => Container(
        child: DropdownButton<int>(
          items: [
            DropdownMenuItem(
              value: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Image.asset(
                    'assets/ikev_logo.png',
                    width: 25,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Ikev2",
                  ),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Image.asset(
                    'assets/openvpn_logo.png',
                    width: 25,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "OpenVPN(TCP)",
                  ),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Image.asset(
                    'assets/openvpn_logo.png',
                    width: 25,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "OpenVPN(UDP)",
                  ),
                ],
              ),
            ),
          ],
          onChanged: (value) {
            setState(() {
              serverType = value;
            });
          },
          value: serverType,
          isExpanded: false,
          elevation: 0,
        ),
      );

  Widget buildUi(BuildContext context) {
    if (state == FlutterVpnState.connected) {
      //bağlı
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "TAP TO\nTURN OFF VPN",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Montserrat-SemiBold",
                    fontSize: 16.0),
              ),
              SizedBox(height: screenAwareSize(15.0, context)),
              SizedBox(
                width: screenAwareSize(130.0, context),
                height: screenAwareSize(130.0, context),
                child: FloatingActionButton(
                  elevation: 0,
                  backgroundColor: Colors.green,
                  onPressed: connectVpn,
                  child: new Icon(Icons.power_settings_new,
                      size: screenAwareSize(100.0, context)),
                ),
              ),
              SizedBox(height: screenAwareSize(30.0, context)),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              ),
              SizedBox(height: screenAwareSize(30.0, context)),
            ],
          ))
        ],
      );
    } else if (state == FlutterVpnState.connecting) {
      // bağlanıyor
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Animator(
                duration: Duration(seconds: 2),
                repeats: 0,
                builder: (anim) => FadeTransition(
                  opacity: anim,
                  child: Text(
                    "CONNECTING",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Montserrat-SemiBold",
                        fontSize: 20.0),
                  ),
                ),
              ),
              SizedBox(height: screenAwareSize(15.0, context)),
              SpinKitRipple(
                color: Colors.black,
                size: 190.0,
              ),
              SizedBox(height: screenAwareSize(50.0, context)),
              // serverConnection(context),
              SizedBox(height: screenAwareSize(30.0, context)),
              Text(
                "CONNECTING VPN SERVER",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Montserrat-SemiBold",
                    fontSize: 12.0),
              ),
              SizedBox(height: screenAwareSize(30.0, context)),
            ],
          ))
        ],
      );
    } else {
      // bağlı değil
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "TAP TO\nTURN ON VPN",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Montserrat-SemiBold",
                    fontSize: 16.0),
              ),
              SizedBox(height: screenAwareSize(15.0, context)),
              SizedBox(
                width: screenAwareSize(130.0, context),
                height: screenAwareSize(130.0, context),
                child: FloatingActionButton(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  onPressed: connectVpn,
                  child: new Icon(Icons.power_settings_new,
                      color: Colors.green,
                      size: screenAwareSize(100.0, context)),
                ),
              ),
              SizedBox(height: screenAwareSize(40.0, context)),
            ],
          ))
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthenticationBloc>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 60,
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text("Profile"), Icon(Icons.person)],
              ),
              onTap: () {
                pushReplacement(context, ProfilePage(user: widget.user));
              },
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text("Logout"), Icon(Icons.logout)],
              ),
              onTap: () {
                authBloc.add(UserLoggedOut());
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              buildUi(context),
              _itemDown(),
              Container(
                width: MediaQuery.of(context).size.width / 1.5,
                child: FlatButton(
                  child: (selectedServer != null)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              selectedServer.flag,
                              width: 30,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(selectedServer.country),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.gps_fixed),
                            SizedBox(
                              width: 10,
                            ),
                            Text('AutoSelect'),
                          ],
                        ),
                  onPressed: () async {
                    final result = await Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ServersPage()));
                    setState(() {
                      selectedServer = result;
                    });
                  },
                ),
              ),
              FutureBuilder<dynamic>(
                  future: data,
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData) {
                      return SizedBox(
                        height: 10,
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
