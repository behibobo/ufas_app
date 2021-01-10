import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ufas_app/blocs/login/anonymous_login_bloc.dart';
import 'package:ufas_app/blocs/login/anonymous_login_event.dart';
import 'package:ufas_app/blocs/login/uuid_login_bloc.dart';
import 'package:ufas_app/pages/splash_page.dart';
import '../blocs/blocs.dart';
import '../helper.dart';
import '../services/services.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class AnonymousLoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => pushReplacement(context, SplashPage()),
        ),
        title: Text("Continue With Ads",
            style: TextStyle(
              color: Colors.black,
            )),
        centerTitle: true,
      ),
      body: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, state) {
              final authBloc = BlocProvider.of<AuthenticationBloc>(context);
              if (state is AuthenticationNotAuthenticated) {
                return _AuthForm();
              }
              if (state is AuthenticationFailure) {
                return Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(state.message),
                    FlatButton(
                      textColor: Theme.of(context).primaryColor,
                      child: Text('Retry'),
                      onPressed: () {
                        authBloc.add(AppLoaded());
                      },
                    )
                  ],
                ));
              }
              // return splash screen
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              );
            },
          )),
    );
  }
}

class _AuthForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = RepositoryProvider.of<AuthenticationService>(context);
    final authBloc = BlocProvider.of<AuthenticationBloc>(context);

    return Container(
      alignment: Alignment.center,
      child: BlocProvider<AnonymousLoginBloc>(
        create: (context) => AnonymousLoginBloc(authBloc, authService),
        child: _SignInForm(),
      ),
    );
  }
}

class _SignInForm extends StatefulWidget {
  @override
  __SignInFormState createState() => __SignInFormState();
}

class __SignInFormState extends State<_SignInForm> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final _uuidController = TextEditingController();
  bool _autoValidate = false;

  Future _scan() async {
    await Permission.camera.request();
    String barcode = await scanner.scan();
    if (barcode == null) {
      print('nothing return.');
    } else {
      _uuidController.text = barcode;
    }
  }

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
          return Expanded(
              child: Column(
            children: [
              Text("Long text about ads and why you need to register"),
              RaisedButton(
                child: Text("Are you sure?"),
                onPressed: () => _loginBloc.add(LoginInAnonymouslyPressed()),
              )
            ],
          ));
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
