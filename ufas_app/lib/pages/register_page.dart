import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ufas_app/models/user.dart';
import 'package:ufas_app/pages/pages.dart';
import 'package:ufas_app/pages/splash_page.dart';
import 'package:ufas_app/services/api_service.dart';
import '../blocs/blocs.dart';
import '../helper.dart';
import '../services/services.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => pushReplacement(context, SplashPage()),
        ),
        title: Text("Register",
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
      child: BlocProvider<LoginBloc>(
        create: (context) => LoginBloc(authBloc, authService),
        child: _SignUpForm(),
      ),
    );
  }
}

class _SignUpForm extends StatefulWidget {
  @override
  __SignUpFormState createState() => __SignUpFormState();
}

class __SignUpFormState extends State<_SignUpForm> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _rePasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _referredController = TextEditingController();
  bool _autoValidate = false;
  bool referralOK = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> getReferral(String code) async {
    var res = await APIService.getReferrer(code);
    log(res);
    if (res == 'error') {
      setState(() {
        referralOK = false;
      });
    } else {
      setState(() {
        referralOK = true;
      });
    }
  }

  Future<bool> emailExists(String email) async {
    var res = await APIService.emailExists(email);
    return res;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _loginBloc = BlocProvider.of<LoginBloc>(context);

    _onRegisterButtonPressed() async {
      if (_key.currentState.validate()) {
        var ea = await emailExists(_emailController.text);
        log(ea.toString());
        if (ea) {
          _showError('Someone has already signed up with this email');
          return;
        }

        var repo = new MyAuthenticationService();
        final user = await repo.signUpWithEmailAndPassword(
            _emailController.text,
            _passwordController.text,
            _referredController.text);

        if (user is User) {
          _loginBloc.add(LoginInWithEmailButtonPressed(
              email: _emailController.text,
              password: _passwordController.text));
        } else {
          //error
        }
      } else {
        setState(() {
          _autoValidate = true;
        });
      }
    }

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          _showError(state.error);
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          if (state is LoginLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Form(
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
                        labelText: 'Email address',
                        filled: true,
                        isDense: true,
                      ),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      validator: (value) {
                        Pattern pattern =
                            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                        RegExp regex = new RegExp(pattern);
                        if (value.isEmpty) {
                          return 'Email is required.';
                        } else if (!regex.hasMatch(value)) {
                          return 'Enter Valid Email';
                        }
                        return null;
                      }),
                  SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      filled: true,
                      isDense: true,
                    ),
                    obscureText: true,
                    controller: _passwordController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Password is required.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password Confirmation',
                      filled: true,
                      isDense: true,
                    ),
                    obscureText: true,
                    controller: _rePasswordController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Password Confirmation is required.';
                      } else if (value != _passwordController.text) {
                        return 'Password doesn\'t match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: (referralOK)
                        ? InputDecoration(
                            labelText: 'Referrer Code',
                            filled: true,
                            isDense: true,
                            icon: Icon(
                              Icons.check,
                              size: 30,
                              color: Colors.green,
                            ))
                        : InputDecoration(
                            labelText: 'Referrer Code',
                            filled: true,
                            isDense: true,
                          ),
                    controller: _referredController,
                    autocorrect: false,
                    onChanged: (code) async {
                      if (code.length >= 10) {
                        await getReferral(code);
                      }
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  RaisedButton(
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(8.0)),
                    child: Text('REGISTER'),
                    onPressed: state is LoginLoading
                        ? () {}
                        : _onRegisterButtonPressed,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  RaisedButton(
                      elevation: 0,
                      color: Colors.transparent,
                      child: Text("SignIn"),
                      onPressed: () => Navigator.of(context).pushReplacement(
                          new MaterialPageRoute(
                              builder: (context) => LoginPage())))
                ],
              ),
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
