import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<Offset> _textSlideAnimation;

  String appName = "ATA CRM";
  String appLogo = "";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _logoSlideAnimation = Tween<Offset>(
        begin: const Offset(0, -1), end: const Offset(0, 0))
        .animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _textSlideAnimation = Tween<Offset>(
        begin: const Offset(0, 1), end: const Offset(0, 0))
        .animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward().then((_) {
      _fetchAppSettings();
    });
  }

  Future<void> _fetchAppSettings() async {
    final apiService = ApiService();

    try {
      final response = await apiService.fetchAppSettings();

      if (response != null) {
        setState(() {
          appName = response['app_name'] ?? "App";
          appLogo = response['appLogo'] ?? "";
        });
        Timer(const Duration(seconds: 1), () => _navigateToNextScreen());
      } else {
        throw Exception("No response");
      }
    } catch (e) {
      // Show ArtSweetAlert on network failure
      _showNetworkError();
    }
  }

  void _showNetworkError() {
    ArtSweetAlert.show(
      context: context,
      artDialogArgs: ArtDialogArgs(
        type: ArtSweetAlertType.danger,
        title: "Network Error",
        text: "Failed to load app settings. Please check your connection.",
        showCancelBtn: true,
        cancelButtonText: "Exit",
        confirmButtonText: "Retry",
        onConfirm: () {
          _fetchAppSettings(); // Retry fetching app settings
        },
        onCancel: () {
          _exitApp(); // Exit the app
        },
      ),
    );
  }

  void _exitApp() {
    SystemNavigator.pop(); // Close the app
  }

  Future<void> _navigateToNextScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

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
    _controller.dispose();
    super.dispose();
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SlideTransition(
                position: _logoSlideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: appLogo.isNotEmpty
                      ? Image.network(appLogo, width: 120, height: 80)
                      : Image.asset('assets/icon/app_icon.png',
                      width: 120, height: 80),
                ),
              ),
              const SizedBox(height: 20),
              SlideTransition(
                position: _textSlideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    appName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
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
