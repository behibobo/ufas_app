import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ufas_app/blocs/authentication/authentication.dart';
import 'package:ufas_app/pages/pages.dart';
import 'package:ufas_app/pages/register_page.dart';
import 'package:ufas_app/pages/uuid_login_page.dart';

import 'home_page.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthenticationAuthenticated) {
            // show home page
            return HomePage(
              user: state.user,
            );
          }
          // otherwise show login page
          return SafeArea(
            child: Column(
              children: [
                RaisedButton(
                  child: Text("SignIn"),
                  onPressed: () => Navigator.of(context).pushReplacement(
                      new MaterialPageRoute(builder: (context) => LoginPage())),
                ),
                RaisedButton(
                  child: Text("UUID SignIn"),
                  onPressed: () => Navigator.of(context).pushReplacement(
                      new MaterialPageRoute(
                          builder: (context) => UuidLoginPage())),
                ),
                RaisedButton(
                  child: Text("SignUp"),
                  onPressed: () => Navigator.of(context).pushReplacement(
                      new MaterialPageRoute(
                          builder: (context) => RegisterPage())),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
