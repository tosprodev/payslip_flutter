import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../screens/profile_screen.dart';
import '../screens/attendance_screen.dart';
import '../screens/payslip_screen.dart';
import '../screens/leave_management_screen.dart';
import '../api_service.dart';
import 'login_page.dart';
import 'setting_page.dart';
import '../constants.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String? _token; // Variable to hold the token
  String _appBarTitle = Constants.appName; // Variable to hold the AppBar title
  DateTime? _lastBackPressTime;
  late List<Widget> _children = [Center(child: CircularProgressIndicator())]; // Initialize with a placeholder

  @override
  void initState() {
    super.initState();
    _loadToken();
    _requestStoragePermission();
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token'); // Load the token from shared preferences
      // Initialize your screens here after the token is loaded
      _children = [
        HomeScreen(), // Create a separate HomeScreen widget
        AttendanceScreen(),
        PayslipScreen(),
        LeaveManagementScreen(token: _token ?? ""),
        ProfileScreen(token: _token ?? ""), // Pass the token here
      ];
    });
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      try {
        // Call the logout method from ApiService
        final logoutResponse = await ApiService.logout(token, Constants.baseUrl);

        // Check if the logoutResponse is not null and contains the expected keys
        if (logoutResponse != null) {
          if (logoutResponse['status'] == 'success') {
            await prefs.remove('token'); // Clear the token from shared preferences

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('You are successfully logged out'),
                backgroundColor: Colors.green, // Set the background color to green
              ),
            );

            // Navigate to the LoginScreen and clear previous routes
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LoginScreen()),
                  (Route<dynamic> route) => false,
            );
          } else {
            // If the status is not 'success', show the error message
            String message = logoutResponse['message'] ?? 'Logout failed. Please try again.'; // Log the error message for debugging
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message),
                backgroundColor: Colors.red,),
            );
          }
        } else {
          // Handle the case where logoutResponse is null
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logout response is null. Please try again.'),
                backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        // Handle exceptions (network issues, etc.)
        print('Error during logout: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred during logout. Please check your network connection.'),
              backgroundColor: Colors.red),
        );
      }
    } else {
      // If no token is found, navigate to login directly
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }

  Future<bool> _onWillPop() async {
    DateTime currentTime = DateTime.now();
    bool backButtonExit = _lastBackPressTime == null ||
        currentTime.difference(_lastBackPressTime!) > Duration(seconds: 2);

    if (backButtonExit) {
      _lastBackPressTime = currentTime;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
      return false; // Do not exit yet
    }

    exit(0); // Completely exit the app
    return true; // Required to satisfy the return type, even though it won’t be reached
  }

  void _showProfileMenu(BuildContext context) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        PopupMenuItem(
          value: 'profile',
          child: Container(
            width: 100, // Set a fixed width for the menu item
            child: Row(
              children: [
                Image.asset('assets/icons/profile.png', height: 24), // Custom icon for Profile
                SizedBox(width: 8),
                Text('Profile'),
              ],
            ),
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Container(
            width: 100, // Set a fixed width for the menu item
            child: Row(
              children: [
                Image.asset('assets/icons/setting.png', height: 24), // Custom icon for Settings
                SizedBox(width: 8),
                Text('Settings'),
              ],
            ),
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Container(
            width: 100, // Set a fixed width for the menu item
            child: Row(
              children: [
                Image.asset('assets/icons/logout.png', height: 24), // Custom icon for Logout
                SizedBox(width: 8),
                Text('Logout'),
              ],
            ),
          ),
        ),
      ],
    ).then((value) {
      if (value == 'profile') {
        setState(() {
          _currentIndex = 4; // Navigate to Profile
          _appBarTitle = 'Profile'; // Update AppBar title
        });
      } else if (value == 'settings') {
        // Navigate to Settings Screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsScreen()), // Replace with your SettingsScreen widget
        );
      } else if (value == 'logout') {
        _logout(context); // Call logout function
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
        child: Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Image.asset('assets/menu.png', height: 24), // Set height for the icon
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Open the drawer
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundImage: AssetImage('assets/default_profile.png'), // Placeholder for employee photo
            ),
            onPressed: () => _showProfileMenu(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                children: [
                  // Add app icon at the top of the sidebar
                  Image.asset('assets/logo.png', height: 80), // Make sure to add your app icon here
                  SizedBox(height: 8),
                  Text(Constants.appName, style: TextStyle(color: Colors.white, fontSize: 24)),
                ],
              ),
            ),
            ListTile(
              leading: Image.asset('assets/icons/home.png', height: 24), // Custom icon for Home
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                setState(() {
                  _currentIndex = 0;
                  _appBarTitle = 'Home'; // Update AppBar title
                });
              },
            ),
            ListTile(
              leading: Image.asset('assets/icons/attendance.png', height: 24), // Custom icon for Attendance
              title: Text('Attendance'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 1;
                  _appBarTitle = 'Attendance'; // Update AppBar title
                });
              },
            ),
            ListTile(
              leading: Image.asset('assets/icons/payslip.png', height: 24), // Custom icon for Payslip
              title: Text('Payslip'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 2;
                  _appBarTitle = 'Payslip'; // Update AppBar title
                });
              },
            ),
            ListTile(
              leading: Image.asset('assets/icons/leave.png', height: 24), // Custom icon for Leave Management
              title: Text('Leave Management'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 3;
                  _appBarTitle = 'Leave Management'; // Update AppBar title
                });
              },
            ),
            ListTile(
              leading: Image.asset('assets/icons/profile.png', height: 24), // Custom icon for Profile
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 4; // Navigate to Profile
                  _appBarTitle = 'Profile'; // Update AppBar title
                });
              },
            ),
            Divider(),
            ListTile(
              leading: Image.asset('assets/icons/setting.png', height: 24), // Custom icon for Settings
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Settings Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()), // Replace with your SettingsScreen widget
                );
              },
            ),
            ListTile(
              leading: Image.asset('assets/icons/logout.png', height: 24), // Custom icon for Logout
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                _logout(context); // Call logout function
              },
            ),
          ],
        ),
      ),
      body: _children.isNotEmpty ? _children[_currentIndex] : Center(child: CircularProgressIndicator()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            // Update AppBar title based on selected index
            switch (index) {
              case 0:
                _appBarTitle = 'Home';
                break;
              case 1:
                _appBarTitle = 'Attendance';
                break;
              case 2:
                _appBarTitle = 'Payslip';
                break;
              case 3:
                _appBarTitle = 'Leave Management';
                break;
              case 4:
                _appBarTitle = 'Profile';
                break;
              default:
                _appBarTitle = 'Home'; // Default title
            }
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/home.png', height: 24), // Custom icon for Home
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/attendance.png', height: 24), // Custom icon for Attendance
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/payslip.png', height: 24), // Custom icon for Payslip
            label: 'Payslip',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/leave.png', height: 24), // Custom icon for Leave
            label: 'Leave',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/profile.png', height: 24), // Custom icon for Profile
            label: 'Profile',
          ),
        ],
        backgroundColor: Colors.lightBlue[100], // Set the light blue color
        selectedItemColor: Colors.blue[900], // Dark blue color for selected item
        unselectedItemColor: Colors.blue[600], // Dark blue color for unselected item
      ),
    )
    );
  }
}

Future<void> _requestStoragePermission() async {
  final status = await Permission.storage.status;
  if (!status.isGranted) {
    await Permission.storage.request();
  }
}

// Separate HomeScreen Widget
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Welcome to the Home Screen',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
