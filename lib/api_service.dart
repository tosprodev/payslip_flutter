import 'dart:convert';
import 'package:http/http.dart' as http;
import 'employee.dart';

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<Employee?> fetchEmployeeProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/profile'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Employee.fromJson(data['employee']);
    } else {
      print('Failed to load employee profile: ${response.body}');
      return null;
    }
  }
}
