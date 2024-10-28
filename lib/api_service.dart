import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';

class ApiService {
  final String baseUrl = Constants.baseUrl;

  // Request OTP based on email or employee ID
  Future<Map<String, dynamic>?> requestOtp(String searchInput) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'search_input': searchInput,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Error: ${response.statusCode}, ${response.body}');
      return null;
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>?> verifyOtp(String otp, String searchInput) async {
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

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Error: ${response.statusCode}, ${response.body}');
      return null;
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
}
