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
  Future<Map<String, dynamic>?> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Include the token for authorization
        },
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
        'message': 'Failed to log out. Please try again.', // Handle network errors
      };
    }
  }

}
