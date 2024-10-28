import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'otp_screen.dart';
import 'profile_screen.dart';
import 'api_service.dart';

class LoginScreen extends StatelessWidget {
  final ApiService apiService = ApiService();
  final TextEditingController searchInputController = TextEditingController();

  LoginScreen({super.key});

  void requestOtp(BuildContext context) async {
    final response = await apiService.requestOtp(searchInputController.text);
    if (response != null && response['message'] == 'OTP sent to your email.') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpScreen(searchInput: searchInputController.text),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response?['error'] ?? 'Failed to send OTP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchInputController,
              decoration: InputDecoration(labelText: 'Email or Employee ID'),
            ),
            ElevatedButton(
              onPressed: () => requestOtp(context),
              child: Text('Request OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
