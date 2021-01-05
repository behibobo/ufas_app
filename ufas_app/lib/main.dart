import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ufas_app/pages/onboarding_screen.dart';
import 'package:ufas_app/pages/splash_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'blocs/blocs.dart';
import 'services/services.dart';
import 'pages/pages.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() => {
      HttpOverrides.global = new MyHttpOverrides(),
      runApp(
          // Injects the Authentication service
          RepositoryProvider<AuthenticationService>(
        create: (context) {
          return MyAuthenticationService();
        },
        // Injects the Authentication BLoC
        child: BlocProvider<AuthenticationBloc>(
          create: (context) {
            final authService =
                RepositoryProvider.of<AuthenticationService>(context);
            return AuthenticationBloc(authService)..add(AppLoaded());
          },
          child: MyApp(),
        ),
      ))
    };

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authentication Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthenticationAuthenticated) {
            // show home page
            return HomePage(
              user: state.user,
            );
          }
          // otherwise show login page
          return OnBoarding();
        },
      ),
    );
  }
}

class OnBoarding extends StatefulWidget {
  @override
  State createState() {
    return OnBoardingState();
  }
}

class OnBoardingState extends State<OnBoarding> {
  bool finishedOnBoarding;

  Future<bool> hasFinishedOnBoarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool finishedOnBoarding = (prefs.getBool('finishedOnBoarding') ?? false);
    return finishedOnBoarding;
  }

  @override
  void initState() {
    super.initState();
    hasFinishedOnBoarding();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        color: Colors.blueAccent,
        home: FutureBuilder<bool>(
            future: hasFinishedOnBoarding(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data) {
                  return SplashPage();
                } else {
                  return OnBoardingScreen();
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                );
              }
            }));
  }
}
