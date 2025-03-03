// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'constants.dart';

class ApiService {
  final String baseUrl = Constants.baseUrl;
  File? prescriptionImage;

  Future<Map<String, dynamic>?> requestOtp(String searchInput) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'search_input': searchInput,
        }),
      );
      final Map<String, dynamic> responseBody = json.decode(response.body);
      if (responseBody.containsKey('success')) {
        return {
          'status': 'success',
          'message': responseBody['success'],
        };
      } else if (responseBody.containsKey('error')) {
        return {
          'status': 'error',
          'message': responseBody['error'],
        };
      } else {
        return {
          'status': 'error',
          'message': 'An unknown error occurred.',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to send OTP. Please try again.',
      };
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>?> verifyOtp(String otp, String searchInput) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'otp': otp,
          'search_input': searchInput,
        }),
      );
      final Map<String, dynamic> responseBody = json.decode(response.body);
      if (responseBody.containsKey('success')) {
        return {
          'status': 'success',
          'token': responseBody['token'],
        };
      } else if (responseBody.containsKey('error')) {
        return {
          'status': 'error',
          'message': responseBody['error'],
        };
      } else {
        return {
          'status': 'error',
          'message': 'An unknown error occurred.',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to verify OTP. Please try again.',
      };
    }
  }

  // Fetch Profile
  Future<Map<String, dynamic>?> fetchEmployeeProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  // Logout the user
  static Future<Map<String, dynamic>?> logout(String token, String baseUrl) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody.containsKey('success')) {
          return {
            'status': 'success',
            'message': responseBody['success'],
          };
        } else {
          return {
            'status': 'error',
            'message': responseBody['error'] ?? 'An unknown error occurred.',
          };
        }
      } else {
        return {
          'status': 'error',
          'message': response.body.isNotEmpty ? json.decode(response.body)['error'] : 'Failed to log out. Please try again.',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to log out due to network error. Please try again.',
      };
    }
  }

  // Fetch Leave Requests
  Future<Map<String, dynamic>?> fetchLeaveRequests(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/employee/leave-requests'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'status': 'error',
          'message': response.body.isNotEmpty
              ? json.decode(response.body)['error']
              : 'Failed to fetch leave requests. Please try again.',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to fetch leave requests due to network error. Please try again.',
      };
    }
  }

  // Submit Leave Request
  Future<Map<String, dynamic>?> submitLeaveRequest(
      String token, Map<String, dynamic> requestData, File? prescriptionImage) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/employee/leave-requests/store'),
      );
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
      request.fields['leave_type'] = requestData['leave_type'];
      request.fields['day_type'] = requestData['day_type'];
      request.fields['reason'] = requestData['reason'];
      request.fields['leave_date_from'] = requestData['leave_date_from'];
      request.fields['leave_date_to'] = requestData['leave_date_to'];
      if (prescriptionImage != null) {
        var prescriptionImageFile = await http.MultipartFile.fromPath(
          'medical_prescription',
          prescriptionImage.path,
          contentType: MediaType('application', 'octet-stream'),
        );
        request.files.add(prescriptionImageFile);
      }
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final responseJson = json.decode(responseBody);

      if (response.statusCode == 201) {
        return {
          'status': 'success',
          'message': responseJson['message'],
          'leave_request': responseJson['leave_request'],
        };
      } else {
        return {
          'status': 'error',
          'message': responseJson['error'] ?? 'Failed to submit leave request.',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to submit leave request due to network error.',
      };
    }
  }

  // Get Settings
  Future<Map<String, dynamic>?> fetchAppSettings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/app-setting'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching app settings: $e");
      return null;
    }
  }

  // Fetch User Role
  static Future<Map<String, dynamic>?> getUserRole(String token, String baseUrl) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/user-role'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Failed to fetch user role. Please try again.',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to fetch user role due to network error. Please try again.',
      };
    }
  }

  // Fetch Appointments
  static Future<Map<String, dynamic>?> fetchAppointments(String token, String baseUrl) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/appointments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Failed to fetch appointments. Please try again.',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to fetch appointments due to network error. Please try again.',
      };
    }
  }
}
