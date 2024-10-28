import 'package:flutter/material.dart';

class OtpScreen extends StatelessWidget {
  final String searchInput;

  OtpScreen({required this.searchInput});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OTP Verification')),
      body: Center(
        child: Text('Enter the OTP sent to $searchInput'),
      ),
    );
  }
}
