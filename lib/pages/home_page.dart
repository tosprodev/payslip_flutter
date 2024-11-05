import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../screens/profile_screen.dart';
import '../screens/attendance_screen.dart';
import '../screens/payslip_screen.dart';
import '../screens/HomeScreen.dart';
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
  String? _token;
  String _appBarTitle = Constants.appName;
  DateTime? _lastBackPressTime;
  String? _profilePicture;
  String? _EmployeeName;
  String? _Designation;
  late List<Widget> _children = [const Center(child: CircularProgressIndicator())];

  @override
  void initState() {
    super.initState();
    _loadToken();
    _requestStoragePermission();
  }

  Future<void> _loadToken() async {
    print("Loading token...");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
      String? employeeJson = prefs.getString('employee');
      if (employeeJson != null) {
        Map<String, dynamic> employeeProfile = json.decode(employeeJson);
        String? photoPath = employeeProfile['employee']['photo'];
        if (photoPath != null && photoPath.isNotEmpty) {
          _profilePicture = photoPath;
          _EmployeeName = employeeProfile['employee']['full_name'];
          _Designation = employeeProfile['employee']['designation'];
        }
      } else {
        _profilePicture = null;
      }
      _children = [
        HomeScreen(),
        AttendanceScreen(),
        PayslipScreen(),
        LeaveManagementScreen(token: _token ?? ""),
        ProfileScreen(token: _token ?? ""),
      ];
    });
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null) {
      try {
        final logoutResponse = await ApiService.logout(token, Constants.baseUrl);
        if (logoutResponse != null) {
          if (logoutResponse['status'] == 'success') {
            await prefs.remove('token');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('You are successfully logged out'),
                backgroundColor: Colors.green,
              ),
            );

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LoginScreen()),
                  (Route<dynamic> route) => false,
            );
          } else {
            String message = logoutResponse['message'] ?? 'Logout failed. Please try again.';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message),
                backgroundColor: Colors.red,),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logout response is null. Please try again.'),
                backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred during logout. Please check your network connection.'),
              backgroundColor: Colors.red),
        );
      }
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }

  Future<bool> _onWillPop() async {
    DateTime currentTime = DateTime.now();
    bool backButtonExit = _lastBackPressTime == null ||
        currentTime.difference(_lastBackPressTime!) > const Duration(seconds: 2);

    if (backButtonExit) {
      _lastBackPressTime = currentTime;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    exit(0);
    return true;
  }

  void _showProfileMenu(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        PopupMenuItem(
          value: 'profile',
          child: SizedBox(
            width: 100,
            child: Row(
              children: [
                Image.asset('assets/icons/profile.png', height: 24),
                const SizedBox(width: 8),
                const Text('Profile'),
              ],
            ),
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Container(
            width: 100,
            child: Row(
              children: [
                Image.asset('assets/icons/setting.png', height: 24),
                const SizedBox(width: 8),
                const Text('Settings'),
              ],
            ),
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Container(
            width: 100,
            child: Row(
              children: [
                Image.asset('assets/icons/logout.png', height: 24),
                const SizedBox(width: 8),
                const Text('Logout'),
              ],
            ),
          ),
        ),
      ],
    ).then((value) {
      if (value == 'profile') {
        setState(() {
          _currentIndex = 4;
          _appBarTitle = 'Profile';
        });
      } else if (value == 'settings') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsScreen()),
        );
      } else if (value == 'logout') {
        _logout(context);
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
              icon: Image.asset('assets/menu.png', height: 24),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundImage: _profilePicture != null && _profilePicture!.isNotEmpty
                  ? NetworkImage('${Constants.baseUrl}/$_profilePicture')
                  : const AssetImage('assets/default_profile.png') as ImageProvider,
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
                gradient: LinearGradient(
                  colors: [
                    Colors.lightBlue[200]!,
                    Colors.pink[200]!,
                  ],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        height: 50,
                        width: 260,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: _profilePicture != null && _profilePicture!.isNotEmpty
                            ? NetworkImage('${Constants.baseUrl}/$_profilePicture')
                            : const AssetImage('assets/icons/profile.png') as ImageProvider,
                        radius: 30,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _EmployeeName != null && _EmployeeName!.length > 15
                                  ? '${_EmployeeName!.substring(0, 15)}...'
                                  : _EmployeeName ?? 'Employee Name',
                              style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _Designation != null && _Designation!.length > 20
                                  ? '${_Designation!.substring(0, 20)}...'
                                  : _Designation ?? 'Designation',
                              style: const TextStyle(color: Colors.black, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Image.asset('assets/icons/home.png', height: 24),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 0;
                  _appBarTitle = 'Home';
                });
              },
            ),
            ListTile(
              leading: Image.asset('assets/icons/attendance.png', height: 24),
              title: const Text('Attendance'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 1;
                  _appBarTitle = 'Attendance';
                });
              },
            ),
            ListTile(
              leading: Image.asset('assets/icons/payslip.png', height: 24),
              title: const Text('Payslip'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 2;
                  _appBarTitle = 'Payslip';
                });
              },
            ),
            ListTile(
              leading: Image.asset('assets/icons/leave.png', height: 24),
              title: const Text('Leave Management'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 3;
                  _appBarTitle = 'Leave Management';
                });
              },
            ),
            ListTile(
              leading: Image.asset('assets/icons/profile.png', height: 24),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 4;
                  _appBarTitle = 'Profile';
                });
              },
            ),
            const Divider(),
            ListTile(
              leading: Image.asset('assets/icons/setting.png', height: 24),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: Image.asset('assets/icons/logout.png', height: 24),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                _logout(context);
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
                _appBarTitle = 'Home';
            }
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/home.png', height: 24),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/attendance.png', height: 24),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/payslip.png', height: 24),
            label: 'Payslip',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/leave.png', height: 24),
            label: 'Leave',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/profile.png', height: 24),
            label: 'Profile',
          ),
        ],
        backgroundColor: Colors.lightBlue[100],
        selectedItemColor: Colors.blue[900],
        unselectedItemColor: Colors.blue[600],
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
