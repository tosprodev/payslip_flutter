import 'package:flutter/material.dart';
import 'otp_screen.dart'; // Correct import for OtpScreen
import 'api_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _searchInputController = TextEditingController();
  final ApiService _apiService = ApiService('https://payslip.ataanalytiqpvt.com');

  void _sendOtp() async {
    // Sending email/employee ID to the server to request OTP
    final response = await _apiService.requestOtp(_searchInputController.text);

    if (response != null && response['success'] == true) {
      // Navigate to OTP screen if OTP is sent successfully
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpScreen(searchInput: _searchInputController.text),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send OTP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchInputController,
              decoration: InputDecoration(labelText: 'Email or Employee ID'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendOtp,
              child: Text('Send OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
