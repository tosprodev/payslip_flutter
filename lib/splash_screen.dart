import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart';
import 'home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Define the fade animation for both logo and app name
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    // Start the fade-in animation
    _controller.forward().then((_) {
      // Wait for the animation to finish, then fade out
      Timer(Duration(seconds: 1), () {
        _controller.reverse().then((_) {
          // After fading out, navigate to the next screen
          _navigateToNextScreen();
        });
      });
    });
  }

  Future<void> _navigateToNextScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // Navigate to the appropriate screen
    if (token != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with fade animation
            FadeTransition(
              opacity: _fadeAnimation,
              child: Image.asset(
                'assets/icon/app_icon.png', // Replace with your icon path
                width: 120,
                height: 80,
              ),
            ),
            SizedBox(height: 20),
            // Text with fade animation
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                Constants.appName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
