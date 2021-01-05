import 'dart:typed_data';

import 'package:animator/animator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_vpn/flutter_vpn.dart';
import 'package:ufas_app/blocs/authentication/authentication.dart';
import 'package:ufas_app/pages/splash_page.dart';
import 'package:ufas_app/services/api_service.dart';
import '../helper.dart';
import '../models/models.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({Key key, this.user}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<dynamic> data;
  Uint8List bytes = Uint8List(0);

  Future<dynamic> _getAccount() async {
    var _res = await APIService.getAccount(widget.user.token);
    return _res;
  }

  Future _generateBarCode(String inputCode) async {
    Uint8List result = await scanner.generateBarCode(inputCode);
    setState(() {
      bytes = result;
    });
  }

  @override
  void initState() {
    setState(() {
      data = _getAccount();
    });
    _generateBarCode(widget.user.uuid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthenticationBloc>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => pushReplacement(context, SplashPage()),
        ),
        title: Text("Profile",
            style: TextStyle(
              color: Colors.black,
            )),
        centerTitle: true,
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: <Widget>[
              Text(
                'Welcome, ${widget.user.email}',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(
                height: 12,
              ),
              SizedBox(
                height: 190,
                child: bytes.isEmpty
                    ? Center(
                        child: RaisedButton(
                          child: Text('Empty code ... ',
                              style: TextStyle(color: Colors.black38)),
                          onPressed: () async {
                            await _generateBarCode(widget.user.uuid);
                          },
                        ),
                      )
                    : Image.memory(bytes),
              ),
              FutureBuilder<dynamic>(
                  future: data,
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData) {
                      var account = snapshot.data;
                      var plan = account.plan;
                      return SafeArea(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 15,
                            ),
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              onPressed: () {
                                Clipboard.setData(new ClipboardData(
                                        text: widget.user.uuid))
                                    .then((_) {
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                      content:
                                          Text("uuid copied to clipboard")));
                                });
                              },
                              child: Text(widget.user.uuid),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: Text(
                                  "You can use the uuid or scan QRCode to log into your account on other devices",
                                  textAlign: TextAlign.center,
                                )),
                            SizedBox(
                              height: 35,
                            ),
                            Text("Your Current Plan"),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        width: 2.0,
                                        color: const Color.fromRGBO(
                                            130, 0, 0, 1))),
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            Text("StartDate"),
                                            Text(account.startedDate)
                                          ],
                                        ),
                                        Container(
                                          width: 100,
                                          height: 100,
                                          decoration: new BoxDecoration(
                                            color: Color.fromRGBO(139, 0, 0, 8),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Center(
                                                child: Text(
                                                  account.daysLeft.toString(),
                                                  style: TextStyle(
                                                      fontSize: 25,
                                                      color: Colors.white),
                                                ),
                                              ),
                                              Center(
                                                child: Text(
                                                  "days left",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Text("EndDate"),
                                            Text(account.expireDate)
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
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
