import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'profile_screen.dart';

class OtpScreen extends StatelessWidget {
  final String searchInput;
  final TextEditingController otpController = TextEditingController();
  final ApiService apiService = ApiService();

  OtpScreen({super.key, required this.searchInput});

  void verifyOtp(BuildContext context) async {
    final response = await apiService.verifyOtp(otpController.text, searchInput);

    if (response != null && response['token'] != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response['token']); // Save token

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(token: response['token']),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid OTP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: otpController,
              decoration: InputDecoration(labelText: 'Enter OTP'),
            ),
            ElevatedButton(
              onPressed: () => verifyOtp(context),
              child: Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
