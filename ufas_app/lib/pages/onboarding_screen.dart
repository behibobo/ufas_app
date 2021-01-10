import 'package:flutter/material.dart';
import 'package:ufas_app/pages/splash_page.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _currentPageNotifier = ValueNotifier<int>(0);

final List<String> _titlesList = [
  'Highly Secure & Fast',
  'User_friendly and Smooth UI',
  'Servers in almost all countries'
];

final List<String> _subtitlesList = [
  'Some lines about security and performace',
  'with some illustration depict user interface',
  'about servers and some of the major countries'
];

final List<IconData> _imageList = [
  Icons.developer_mode,
  Icons.layers,
  Icons.account_circle
];
final List<Widget> _pages = [];

List<Widget> populatePages(BuildContext context) {
  _pages.clear();
  _titlesList.asMap().forEach((index, value) => _pages.add(getPage(
      _imageList.elementAt(index), value, _subtitlesList.elementAt(index))));
  _pages.add(getLastPage(context));
  return _pages;
}

Widget _buildCircleIndicator() {
  return CirclePageIndicator(
    selectedDotColor: Colors.white,
    dotColor: Colors.white30,
    selectedSize: 8,
    size: 6.5,
    itemCount: _pages.length,
    currentPageNotifier: _currentPageNotifier,
  );
}

Widget getPage(IconData icon, String title, String subTitle) {
  return Center(
    child: Container(
      color: Colors.blueAccent,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: new Icon(
                icon,
                color: Colors.white,
                size: 120,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                subTitle,
                style: TextStyle(color: Colors.white70, fontSize: 17.0),
              ),
            )
          ],
        ),
      ),
    ),
  );
}

Widget getLastPage(BuildContext context) {
  return Center(
    child: Container(
      color: Colors.blueAccent,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: new Icon(
                  Icons.code,
                  color: Colors.white,
                  size: 120,
                ),
              ),
              Text(
                'Jump straight into the action.',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: OutlineButton(
                    onPressed: () {
                      setFinishedOnBoarding();
                      Navigator.of(context).pushReplacement(
                          new MaterialPageRoute(
                              builder: (context) => SplashPage()));
                    },
                    child: Text(
                      "Get Started",
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    borderSide: BorderSide(color: Colors.white),
                    shape: StadiumBorder(),
                  ))
            ],
          ),
        ),
      ),
    ),
  );
}

Future<bool> setFinishedOnBoarding() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setBool('finishedOnBoarding', true);
}

class OnBoardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        PageView(
          children: populatePages(context),
          onPageChanged: (int index) {
            _currentPageNotifier.value = index;
          },
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 30.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: _buildCircleIndicator(),
          ),
        )
      ],
    ));
  }
}
