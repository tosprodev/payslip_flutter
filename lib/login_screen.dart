import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'otp_screen.dart';
import 'api_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final ApiService apiService = ApiService();
  final TextEditingController searchInputController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool isButtonHovered = false;
  bool isLoading = false; // Loading state

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    searchInputController.dispose();
    super.dispose();
  }

  void requestOtp(BuildContext context) async {
    String input = searchInputController.text.trim();

    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your email or employee ID.'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final response = await apiService.requestOtp(input);

    setState(() {
      isLoading = false;
    });

    // Check if the response is not null
    if (response != null) {
      // Handle the response based on status
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(searchInput: input),
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
          content: Text('Failed to send OTP. Please try again.'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Animated App Icon at the top
                AnimatedContainer(
                  duration: Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Image.asset(
                    'assets/logo.png', // Replace with your icon path
                    width: 600,
                    height: 60,
                  ),
                ),
                SizedBox(height: 30),

                // Animated and styled search input box
                AnimatedContainer(
                  duration: Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  child: TextField(
                    controller: searchInputController,
                    decoration: InputDecoration(
                      labelText: 'Email or Employee ID',
                      labelStyle: TextStyle(color: Colors.blueGrey),
                      prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      // Adjust padding for better label and content positioning
                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      floatingLabelBehavior: FloatingLabelBehavior.auto, // Change label behavior
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                SizedBox(height: 20),

                // Show loading indicator or button
                isLoading
                    ? CircularProgressIndicator() // Show progress indicator
                    : MouseRegion(
                  onEnter: (_) => setState(() => isButtonHovered = true),
                  onExit: (_) => setState(() => isButtonHovered = false),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: isButtonHovered
                            ? [Colors.blueAccent, Colors.lightBlueAccent]
                            : [Colors.lightBlueAccent, Colors.blueAccent],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => requestOtp(context),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Request OTP',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
