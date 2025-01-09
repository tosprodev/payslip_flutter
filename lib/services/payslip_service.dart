import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../models/payslip.dart';
import '../constants.dart';
import 'package:art_sweetalert/art_sweetalert.dart';

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
  Future<void> downloadPayslip(
      String hashedId,
      String token,
      String savePath,
      Function(int)? onProgress,
      BuildContext context,
      ) async {
    Dio dio = Dio();
    try {
      final response = await dio.download(
        '${Constants.baseUrl}/api/payslips/download/$hashedId',
        savePath,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token', // Include the token in the headers
          },
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            int progress = (received / total * 100).toInt();
            if (onProgress != null) {
              onProgress(progress);
            }
          }
        },
      );

      if (response.statusCode == 200) {
        ArtSweetAlert.show(
          context: context, // Make sure you have access to the context
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.success,
            title: "Download Successful!",
            text: "Your payslip has been downloaded.", // Optional text
          ),
        );
      } else {
        throw Exception('Download failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Download error: $e');
      ArtSweetAlert.show(
        context: context, // Make sure you have access to the context
        artDialogArgs: ArtDialogArgs(
          title: "Download Failed!",
          text: "An error occurred while downloading your payslip. Please try again.", // Optional text
        ),
      );
      throw e;  // Re-throw the error to handle it in the calling function
    }
  }

}
