import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ufas_app/blocs/login/uuid_login_bloc.dart';
import 'package:ufas_app/pages/splash_page.dart';
import '../blocs/blocs.dart';
import '../helper.dart';
import '../services/services.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class UuidLoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => pushReplacement(context, SplashPage()),
        ),
        title: Text("UUID Login",
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
      child: BlocProvider<UuidLoginBloc>(
        create: (context) => UuidLoginBloc(authBloc, authService),
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
    final _loginBloc = BlocProvider.of<UuidLoginBloc>(context);

    _onLoginButtonPressed() {
      if (_key.currentState.validate()) {
        _loginBloc
            .add(LoginInWithUuidButtonPressed(uuid: _uuidController.text));
      } else {
        setState(() {
          _autoValidate = true;
        });
      }
    }

    return BlocListener<UuidLoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          _showError(state.error);
        }
      },
      child: BlocBuilder<UuidLoginBloc, LoginState>(
        builder: (context, state) {
          if (state is LoginLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Expanded(
            child: Column(
              children: [
                Center(
                  child: GestureDetector(
                      onTap: _scan,
                      child: Image.asset(
                        'assets/scanner.png',
                        width: 100,
                      )),
                ),
                Form(
                  key: _key,
                  autovalidateMode: _autoValidate
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'UUID',
                            filled: true,
                            isDense: true,
                          ),
                          controller: _uuidController,
                          keyboardType: TextInputType.text,
                          autocorrect: false,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Email is required.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        RaisedButton(
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(8.0)),
                          child: Text('LOG IN'),
                          onPressed: state is LoginLoading
                              ? () {}
                              : _onLoginButtonPressed,
                        ),
                        const SizedBox(
                          height: 16,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
