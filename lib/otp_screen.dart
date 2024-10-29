import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Keep this for FilteringTextInputFormatter
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'home_page.dart'; // Import your homepage here

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
  bool _isLoading = false; // Variable to manage loading state

  @override
  void initState() {
    super.initState();
  }

  void verifyOtp(BuildContext context) async {
    String otp = _otpControllers.map((controller) => controller.text).join();

    setState(() {
      _isLoading = true; // Start loading
    });

    final response = await apiService.verifyOtp(otp, widget.searchInput);

    setState(() {
      _isLoading = false; // Stop loading
    });

    if (response != null) {
      if (response['status'] == 'success' && response['token'] != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response['token']); // Save token

        // Navigate to the homepage after successful OTP verification
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(), // Replace with your homepage widget
          ),
        );
      } else if (response['status'] == 'error') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to verify OTP. Please try again.'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onChanged(String value, int index) {
    if (value.length == 1) {
      // Move to the next input field
      if (index < 5) {
        FocusScope.of(context).nextFocus();
      }
    } else if (value.isEmpty && index > 0) {
      // Move back to the previous input field
      FocusScope.of(context).previousFocus();
    }
  }

  void _handlePaste(String value) {
    if (value.length == 6) {
      for (int i = 0; i < 6; i++) {
        _otpControllers[i].text = value[i];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon at the Top
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: [
                  Image.asset('assets/logo.png', height: 100), // Change the path to your app icon
                  SizedBox(height: 20),
                  Text(
                    'Enter the OTP sent to your email',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // OTP Input Boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(6, (index) {
                return Container(
                  width: 50, // Increased width
                  height: 70, // Increased height
                  child: TextField(
                    controller: _otpControllers[index],
                    onChanged: (value) {
                      _onChanged(value, index);
                    },
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                      counterText: '', // Remove character counter
                    ),
                    style: TextStyle(fontSize: 28, height: 1), // Increased font size for better visibility
                    maxLength: 1,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // Ensure only digits are allowed
                    ],
                    showCursor: false, // Hide cursor to improve visual appeal
                  ),
                );
              }),
            ),

            SizedBox(height: 20),

            // Progress Indicator
            if (_isLoading)
              CircularProgressIndicator(), // Show progress indicator if loading
            SizedBox(height: 20),

            // Container to make the button wider
            Container(
              width: double.infinity, // Make the button fill the available width
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => verifyOtp(context), // Disable button while loading
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15), // Vertical padding
                  backgroundColor: Colors.blue, // Change to desired color
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                  ),
                ),
                child: Text(
                  'Verify OTP',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), // Customize text style
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
