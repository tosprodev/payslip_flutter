// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/payslip.dart';
import '../constants.dart';

class PayslipService {
  static const String apiUrl = "${Constants.baseUrl}/api/payslips";

  // Fetch payslips data from the API
  Future<List<Payslip>> fetchPayslips(String token) async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Include the token in the headers
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body)['payslips'];
        return data.map((item) => Payslip.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load payslips: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Download payslip PDF using Dio with token authorization
  Future<void> downloadPayslip(String hashedId, String token, BuildContext context) async {
    Dio dio = Dio();
    String url = '${Constants.baseUrl}/api/payslips/download/$hashedId';

    try {
      // Request storage permission
      if (await _requestPermission()) {
        Directory? directory = await getApplicationDocumentsDirectory();
        String savePath = '${directory.path}/payslip_$hashedId.pdf';

        Response response = await dio.download(
          url,
          savePath,
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ),
          onReceiveProgress: (received, total) {
            if (total != -1) {
              int progress = (received / total * 100).toInt();
              print("Download progress: $progress%");
            }
          },
        );

        if (response.statusCode == 200) {
          print("✅ Download complete! File saved at: $savePath");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Download successful: $savePath')),
          );
        } else {
          throw Exception("Failed to download PDF. Status: ${response.statusCode}");
        }
      }
    } catch (e) {
      print("❌ Download error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error downloading payslip: $e")),
      );
    }
  }

  // Request storage permission
  Future<bool> _requestPermission() async {
    if (await Permission.storage.request().isGranted) {
      return true;
    }
    return false;
  }
}