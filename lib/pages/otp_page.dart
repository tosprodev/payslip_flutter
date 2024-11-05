import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Keep this for FilteringTextInputFormatter
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import 'home_page.dart';

class OtpScreen extends StatefulWidget {
  final String searchInput;

  const OtpScreen({Key? key, required this.searchInput}) : super(key: key);

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers =
  List.generate(6, (index) => TextEditingController());
  final ApiService apiService = ApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void verifyOtp(BuildContext context) async {
    String otp = _otpControllers.map((controller) => controller.text).join();

    setState(() {
      _isLoading = true;
    });

    final response = await apiService.verifyOtp(otp, widget.searchInput);

    setState(() {
      _isLoading = false;
    });

    if (response != null && response['status'] == 'success' && response['token'] != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = response['token'];
      await prefs.setString('token', token);
      final profile = await apiService.fetchEmployeeProfile(token);
      if (profile != null) {
        await prefs.setString('employee', json.encode(profile));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      } else {
        // Handle profile fetch failure
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to fetch profile. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response?['message'] ?? 'Failed to verify OTP. Please try again.'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onChanged(String value, int index) {
    if (value.length == 1) {
      if (index < 5) {
        FocusScope.of(context).nextFocus();
      }
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).previousFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade100, Colors.pink.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    Image.asset('assets/logo.png', height: 100),
                    const SizedBox(height: 10),
                    const Text(
                      'Verify OTP',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Enter the OTP sent to your email',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(6, (index) {
                  return Container(
                    width: 50,
                    height: 70,
                    child: TextField(
                      controller: _otpControllers[index],
                      onChanged: (value) {
                        _onChanged(value, index);
                      },
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent),
                        ),
                        counterText: '',
                      ),
                      style: const TextStyle(fontSize: 28, height: 1),
                      maxLength: 1,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      showCursor: true,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
              if (_isLoading)
                const CircularProgressIndicator(),
              const SizedBox(height: 10),
              SizedBox(
                width: 200,
                child: Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(20),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.lightBlueAccent, Colors.blueAccent],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _isLoading ? null : () => verifyOtp(context),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: Text(
                            'Verify OTP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
