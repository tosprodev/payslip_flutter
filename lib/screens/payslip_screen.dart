// ignore_for_file: unused_local_variable, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import '../services/payslip_service.dart';
import '../models/payslip.dart';

class PayslipScreen extends StatelessWidget {
  final String token;

  const PayslipScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    final PayslipService payslipService = PayslipService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payslips'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Payslip>>(
        future: payslipService.fetchPayslips(token),
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

class PayslipCard extends StatelessWidget {
  final Payslip payslip;
  final String token;

  const PayslipCard({super.key, required this.payslip, required this.token});

  @override
  Widget build(BuildContext context) {
    // Format the date as "July 2024"
    int month = int.parse(payslip.payslipMonth.toString());
    int year = int.parse(payslip.payslipYear.toString());
    final String formattedDate = DateFormat('MMMM yyyy').format(DateTime(year, month));

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.pink.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(10),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          title: Text(
            '# $formattedDate',  // Displaying Month and Year like "July 2024"
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTable([
                    ['Employee Name', payslip.employee.fullName],
                    ['Designation', payslip.employee.designation],
                    ['Work Days', payslip.workDays.toString()],
                    ['Paid Days', payslip.paidDays.toString()],
                    ['Late Days', payslip.lateDays.toString()],
                    ['LOP Days', payslip.lopDays.toString()],
                    ['Leave Days Taken', payslip.leaveDaysTaken.toString()],
                    ['In-Hand Salary', '₹${payslip.grossSalary}'],
                    ['LOP Amount', '₹${payslip.canteen}'],
                    ['This Month Salary', '₹${payslip.inhandSalary}'],
                  ]),
                  const SizedBox(height: 10),
                  Center( // Centering the Download button
                    child: ElevatedButton(
                      onPressed: () {
                        _downloadPayslip(payslip.hashedId, context); // Call your download method here
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.blue, // Text color set to white
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Download Now'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadPayslip(String hashedId, BuildContext context) async {
    try {
      final savePath = await _getSavePath(); // Get the path where to save the file
      final payslipService = PayslipService();

      // Show loading dialog
      showDialog(
        context: context,
        builder: (BuildContext context) => const AlertDialog(
          title: Text("Downloading..."),
          content: LinearProgressIndicator(),
        ),
      );

      // Download payslip with progress
      await payslipService.downloadPayslip(hashedId, token, context);

      // Dismiss the loading dialog
      Navigator.of(context).pop();

      // Show success SweetAlert (moved to downloadPayslip)

    } catch (e) {
      // Dismiss the loading dialog
      Navigator.of(context).pop();

      // Show error SweetAlert
      ArtSweetAlert.show(
        context: context, // Make sure you have access to the context
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "Download Failed!",
          text: "An error occurred while downloading your payslip. Please try again.", // Optional text
        ),
      );
    }
  }

  Future<String> _getSavePath() async {
    final directory = await getExternalStorageDirectory();
    final savePath = '${directory!.path}/payslip_${payslip.hashedId}.pdf';
    return savePath;
  }

  Widget _buildTable(List<List<String>> data) {
    return Table(
      columnWidths: const {0: FractionColumnWidth(0.4), 1: FractionColumnWidth(0.6)},
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
  final Payslip payslip;

  const PayslipDetailScreen({super.key, required this.payslip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details for ${payslip.payslipMonth}/${payslip.payslipYear}'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          children: [
            _buildTable([
              ['Company', payslip.company.name],
              ['Pay Date', payslip.payDate],
              ['Gross Salary', '₹${payslip.grossSalary}'],
              ['Basic', '₹${payslip.basic}'],
              ['HRA', '₹${payslip.hra}'],
              ['Special Allowance', '₹${payslip.special}'],
              ['EPF Contribution', '₹${payslip.epf}'],
              ['CTC', '₹${payslip.ctc}'],
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
      columnWidths: const {0: FractionColumnWidth(0.4), 1: FractionColumnWidth(0.6)},
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
