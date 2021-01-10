import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ufas_app/blocs/authentication/authentication.dart';
import 'package:ufas_app/blocs/login/anonymous_login_bloc.dart';
import 'package:ufas_app/blocs/login/anonymous_login_event.dart';
import 'package:ufas_app/blocs/login/login_state.dart';
import 'package:ufas_app/pages/anonymous_login_page.dart';
import 'package:ufas_app/pages/pages.dart';
import 'package:ufas_app/pages/register_page.dart';
import 'package:ufas_app/pages/uuid_login_page.dart';
import 'package:ufas_app/services/authentication_service.dart';

import 'home_page.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = RepositoryProvider.of<AuthenticationService>(context);
    final authBloc = BlocProvider.of<AuthenticationBloc>(context);
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
              child: BlocProvider<AnonymousLoginBloc>(
            create: (context) => AnonymousLoginBloc(authBloc, authService),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Image.asset(
                        'assets/openvpn_logo.png',
                        width: 100,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "UFAS VPN",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  FlatButton(
                    child: Text('Login / Register',
                        style: TextStyle(color: Colors.white, fontSize: 17)),
                    onPressed: () => Navigator.of(context).pushReplacement(
                        new MaterialPageRoute(
                            builder: (context) => LoginPage())),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text('OR'),
                  _SignInForm(),
                ],
              ),
            ),
          ));
        },
      ),
    );
  }
}

class _SignInForm extends StatefulWidget {
  @override
  __SignInFormState createState() => __SignInFormState();
}

class __SignInFormState extends State<_SignInForm> {
  @override
  Widget build(BuildContext context) {
    final _loginBloc = BlocProvider.of<AnonymousLoginBloc>(context);

    return BlocListener<AnonymousLoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          _showError(state.error);
        }
      },
      child: BlocBuilder<AnonymousLoginBloc, LoginState>(
        builder: (context, state) {
          if (state is LoginLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return FlatButton(
            child: Text(
              "Continue With Ads",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => _loginBloc.add(LoginInAnonymouslyPressed()),
          );
        },
      ),
    );
  }

  void _showError(String error) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(error),
      backgroundColor: Theme.of(context).errorColor,
    ));
  }
}
