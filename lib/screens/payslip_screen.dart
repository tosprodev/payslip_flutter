// ignore_for_file: unused_local_variable, use_build_context_synchronously, deprecated_member_use, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class PayslipScreen extends StatelessWidget {
  final String token;

  const PayslipScreen({super.key, required this.token});

  Future<List<Map<String, dynamic>>> fetchPayslips(String token) async {
    const String apiUrl = "${Constants.baseUrl}/api/payslips";

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body)['payslips'];
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load payslips: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchPayslips(token),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No payslips available.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final payslips = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: payslips.length,
            itemBuilder: (context, index) {
              final payslip = payslips[index];
              return PayslipCard(payslip: payslip, token: token);
            },
          );
        },
      ),
    );
  }
}

class PayslipCard extends StatefulWidget {
  final Map<String, dynamic> payslip;
  final String token;

  const PayslipCard({super.key, required this.payslip, required this.token});

  @override
  _PayslipCardState createState() => _PayslipCardState();
}

class _PayslipCardState extends State<PayslipCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    int month = int.parse(widget.payslip['payslip_month']);
    int year = int.parse(widget.payslip['payslip_year']);
    final String formattedDate =
        DateFormat('MMMM yyyy').format(DateTime(year, month));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.pink.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: ListTile(
              title: Text(
                '# $formattedDate',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    shape: const CircleBorder(),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade200, Colors.pink.shade200],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      width: 28,
                      height: 28,
                      child: IconButton(
                        icon: const Icon(Icons.download, color: Colors.white),
                        onPressed: () {
                          _downloadPayslip(widget.payslip['hashedId']);
                        },
                        iconSize: 14,
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                        splashRadius: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    shape: const CircleBorder(),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 235, 188, 240),
                            Color.fromARGB(255, 129, 205, 246)
                          ], // Different gradient color
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      width: 28,
                      height: 28,
                      child: IconButton(
                        icon: Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        iconSize: 14,
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                        splashRadius: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTable([
                    [
                      'Employee Name',
                      widget.payslip['employee']['full_name'] ?? 'N/A'
                    ],
                    [
                      'Designation',
                      widget.payslip['employee']['designation'] ?? 'N/A'
                    ],
                    ['Work Days', widget.payslip['work_days'].toString()],
                    ['Paid Days', widget.payslip['paid_days'].toString()],
                    ['Late Days', widget.payslip['late_days'].toString()],
                    ['LOP Days', widget.payslip['lop_days'].toString()],
                    [
                      'Leave Days Taken',
                      widget.payslip['leave_days_taken'].toString()
                    ],
                    ['In-Hand Salary', '₹${widget.payslip['gross_salary']}'],
                    ['LOP Amount', '₹${widget.payslip['canteen']}'],
                    [
                      'This Month Salary',
                      '₹${widget.payslip['inhand_salary']}'
                    ],
                  ]),
                  const SizedBox(height: 10),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _downloadPayslip(String hashedId) async {
    const String apiUrl = '${Constants.baseUrl}/api/payslips/download';
    final url = '$apiUrl/$hashedId';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildTable(List<List<String>> data) {
    return Table(
      columnWidths: const {
        0: FractionColumnWidth(0.4),
        1: FractionColumnWidth(0.6)
      },
      border: TableBorder.all(color: Colors.black.withOpacity(0.2)),
      children: data.map((row) {
        return TableRow(
          children: row.map((cell) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(cell),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

class PayslipDetailScreen extends StatelessWidget {
  final Map<String, dynamic> payslip;

  const PayslipDetailScreen({super.key, required this.payslip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Details for ${payslip['payslip_month']}/${payslip['payslip_year']}'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          children: [
            _buildTable([
              ['Company', payslip['company']['name'] ?? 'N/A'],
              ['Pay Date', payslip['pay_date'] ?? 'N/A'],
              ['Gross Salary', '₹${payslip['gross_salary']}'],
              ['Basic', '₹${payslip['basic']}'],
              ['HRA', '₹${payslip['hra']}'],
              ['Special Allowance', '₹${payslip['special']}'],
              ['EPF Contribution', '₹${payslip['epf']}'],
              ['CTC', '₹${payslip['ctc']}'],
            ]),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(List<List<String>> data) {
    return Table(
      columnWidths: const {
        0: FractionColumnWidth(0.4),
        1: FractionColumnWidth(0.6)
      },
      border: TableBorder.all(color: Colors.black.withOpacity(0.2)),
      children: data.map((row) {
        return TableRow(
          children: row.map((cell) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(cell),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
