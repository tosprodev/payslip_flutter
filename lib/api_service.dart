import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<Map<String, dynamic>?> fetchEmployeeProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/employee/profile'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null; // Handle error scenarios appropriately
    }
  }

  Future<Map<String, dynamic>?> requestOtp(String emailOrId) async {
    // This is just an example of the requestOtp method
    final response = await http.post(
      Uri.parse('$baseUrl/send-otp'),
      body: {
        'emailOrId': emailOrId,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }
}
