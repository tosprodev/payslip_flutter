import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';

class ApiService {
  final String baseUrl = Constants.baseUrl;

  // Request OTP based on email or employee ID
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

      // Parse the response body
      final Map<String, dynamic> responseBody = json.decode(response.body);

      // Check if the response indicates success
      if (responseBody.containsKey('success')) {
        return {
          'status': 'success',
          'message': responseBody['success'], // Get the success message
        };
      } else if (responseBody.containsKey('error')) {
        return {
          'status': 'error',
          'message': responseBody['error'], // Get the error message if it exists
        };
      } else {
        return {
          'status': 'error',
          'message': 'An unknown error occurred.', // Handle unexpected cases
        };
      }
    } catch (e) {
      print('Exception: $e');
      return {
        'status': 'error',
        'message': 'Failed to send OTP. Please try again.', // Handle network errors
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

      // Parse the response body
      final Map<String, dynamic> responseBody = json.decode(response.body);

      // Check if the response indicates success
      if (responseBody.containsKey('success')) {
        return {
          'status': 'success',
          'token': responseBody['token'], // Get the token if success
        };
      } else if (responseBody.containsKey('error')) {
        return {
          'status': 'error',
          'message': responseBody['error'], // Get the error message if it exists
        };
      } else {
        return {
          'status': 'error',
          'message': 'An unknown error occurred.', // Handle unexpected cases
        };
      }
    } catch (e) {
      print('Exception: $e');
      return {
        'status': 'error',
        'message': 'Failed to verify OTP. Please try again.', // Handle network errors
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

        // Check for expected success key in the response
        if (responseBody.containsKey('success')) {
          return {
            'status': 'success',
            'message': responseBody['success'], // Get the success message
          };
        } else {
          return {
            'status': 'error',
            'message': responseBody['error'] ?? 'An unknown error occurred.', // Better error handling
          };
        }
      } else {
        // Handle non-200 responses and provide error detail if available
        return {
          'status': 'error',
          'message': response.body.isNotEmpty ? json.decode(response.body)['error'] : 'Failed to log out. Please try again.',
        };
      }
    } catch (e) {
      print('Exception during logout: $e');
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
      print('Exception during fetchLeaveRequests: $e');
      return {
        'status': 'error',
        'message': 'Failed to fetch leave requests due to network error. Please try again.',
      };
    }
  }

  // Submit Leave Request
  Future<Map<String, dynamic>?> submitLeaveRequest(
      String token, Map<String, dynamic> requestData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/employee/leave-requests/store'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestData),
      );

      // Parse the response body
      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'status': 'success',
          'message': responseBody['message'],
          'leave_request': responseBody['leave_request'],
        };
      } else {
        return {
          'status': 'error',
          'message': responseBody['error'] ?? 'Failed to submit leave request.',
        };
      }
    } catch (e) {
      print('Exception during leave request submission: $e');
      return {
        'status': 'error',
        'message': 'Failed to submit leave request due to network error.',
      };
    }
  }

}
