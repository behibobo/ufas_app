import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ufas_app/pages/register_page.dart';
import 'package:ufas_app/pages/splash_page.dart';
import 'package:ufas_app/pages/uuid_login_page.dart';
import '../blocs/blocs.dart';
import '../helper.dart';
import '../services/services.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => pushReplacement(context, SplashPage()),
        ),
        title: Text("Login",
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
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  bool _autoValidate = false;

  @override
  Widget build(BuildContext context) {
    final _loginBloc = BlocProvider.of<LoginBloc>(context);

    _onLoginButtonPressed() {
      if (_key.currentState.validate()) {
        _loginBloc.add(LoginInWithEmailButtonPressed(
            email: _emailController.text, password: _passwordController.text));
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
          return Column(
            children: [
              SizedBox(
                height: 20,
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
                          labelText: 'Email address',
                          filled: true,
                          isDense: true,
                          focusColor: Colors.white,
                        ),
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Email is required.';
                          }
                          return null;
                        },
                      ),
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
                      const SizedBox(
                        height: 16,
                      ),
                      RaisedButton(
                        color: Colors.redAccent,
                        textColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(8.0)),
                        child: Text('LOG IN'),
                        onPressed: state is LoginLoading
                            ? () {}
                            : _onLoginButtonPressed,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200], width: 4),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FlatButton(
                    onPressed: () => pushReplacement(context, UuidLoginPage()),
                    child: Column(
                      children: [
                        Icon(Icons.qr_code),
                        SizedBox(
                          height: 20,
                        ),
                        Text("Scan QRCode to Login")
                      ],
                    )),
              ),
              SizedBox(
                height: 15,
              ),
              Text("OR"),
              SizedBox(
                height: 5,
              ),
              RaisedButton(
                  elevation: 0,
                  color: Colors.transparent,
                  child: Text("CreateAccount"),
                  onPressed: () => Navigator.of(context).pushReplacement(
                      new MaterialPageRoute(
                          builder: (context) => RegisterPage()))),
            ],
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
