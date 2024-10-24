import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'api_service.dart';
import 'employee.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final token = Provider.of<AuthProvider>(context).token;

    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: FutureBuilder<Employee?>(
        future: ApiService('https://payslip.ataanalytiqpvt.com').fetchEmployeeProfile(token!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Employee not found.'));
          }

          final employee = snapshot.data!;
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${employee.fullName}'),
                Text('Email: ${employee.email}'),
                Text('Phone: ${employee.phone}'),
                // Add other fields as necessary
              ],
            ),
          );
        },
      ),
    );
  }
}
