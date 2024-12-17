import 'package:flutter/material.dart';
import 'pages/splash_page.dart';
import 'constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'GoogleSans',
      ),
      home: SplashScreen(),
    );
  }
}
