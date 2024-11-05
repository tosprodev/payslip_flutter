import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../api_service.dart';
import '../models/employee.dart';
import '../constants.dart';

class ProfileScreen extends StatefulWidget {
  final String token;

  const ProfileScreen({Key? key, required this.token}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ApiService apiService;
  Employee? employee;

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final fetchedData = await apiService.fetchEmployeeProfile(widget.token);
    setState(() {
      employee = fetchedData != null ? Employee.fromJson(fetchedData['employee']) : null;
    });
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showWebViewPopup(String url) {
    double loadingProgress = 0.0;
    bool isLoading = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Document'),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Stack(
                  children: [
                    InAppWebView(
                      initialUrlRequest: URLRequest(
                        url: WebUri(url),
                      ),
                      onWebViewCreated: (InAppWebViewController controller) {},
                      onLoadStart: (InAppWebViewController controller, Uri? url) {
                        setState(() {
                          isLoading = true;
                        });
                      },
                      onLoadStop: (InAppWebViewController controller, Uri? url) async {
                        setState(() {
                          isLoading = false;
                        });
                      },
                      onProgressChanged: (InAppWebViewController controller, int progress) {
                        setState(() {
                          loadingProgress = progress / 100.0;
                        });
                      },
                      onLoadError: (InAppWebViewController controller, Uri? url, int code, String message) {
                        setState(() {
                          isLoading = false;
                        });
                        _showSnackbar("Failed to load the document: $message");
                      },
                      onLoadHttpError: (InAppWebViewController controller, Uri? url, int statusCode, String description) {
                        setState(() {
                          isLoading = false;
                        });
                        _showSnackbar("HTTP Error: $statusCode $description");
                      },
                      initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                          mediaPlaybackRequiresUserGesture: false,
                        ),
                      ),
                    ),
                    if (isLoading)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 10),
                            Text(
                              "${(loadingProgress * 100).toStringAsFixed(0)}%",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _downloadFile(String url) async {
    // Check for storage permission
    final status = await Permission.storage.status;

    if (status.isDenied) {
      // If the permission is denied, request permission
      final result = await Permission.storage.request();
      if (result.isDenied) {
        _showSnackbar("Storage permission is required to download files.");
        return;
      }
    }

    // If permission is granted, proceed with downloading the file
    if (status.isGranted || status.isLimited) {
      // Get the document directory
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${url.split('/').last}';

      // Use HttpClient to download the file
      HttpClient httpClient = HttpClient();
      try {
        final request = await httpClient.getUrl(Uri.parse(url));
        final response = await request.close();
        final bytes = await consolidateHttpClientResponseBytes(response);
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        _showSnackbar("Downloaded to: $filePath");
      } catch (e) {
        _showSnackbar("Download failed: $e");
      } finally {
        httpClient.close();
      }
    } else {
      _showSnackbar("Storage permission is required to download files.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: employee == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Center(
                child: CircleAvatar(
                  radius: 80,
                  backgroundImage: employee!.photo != null
                      ? NetworkImage('${Constants.baseUrl}/${employee!.photo}')
                      : const AssetImage('assets/default_profile.png') as ImageProvider,
                ),
              ),
              const SizedBox(height: 16.0),
              buildSectionHeader("Profile Details"),
              buildProfileTable(),
              if (employee!.documents != null) ...[
                buildSectionHeader("Documents"),
                buildDocumentsTable(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildProfileTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(4),
        1: FlexColumnWidth(6),
      },
      border: TableBorder.all(color: Colors.grey.shade300),
      children: [
        buildTableRow('Employee ID', employee!.employeeId),
        buildTableRow('Full Name', employee!.fullName),
        buildTableRow('Email', employee!.email),
        buildTableRow('Phone', employee!.phone),
        buildTableRow('PAN Number', employee!.panNumber),
        buildTableRow('Bank Name', employee!.bankName),
        buildTableRow('Account Number', employee!.bankAccountNumber),
        buildTableRow('IFSC Code', employee!.ifscCode),
        buildTableRow('Joining Date', employee!.doj),
        buildTableRow('Date of Birth', employee!.dob),
        buildTableRow('Blood Group', employee!.bloodGroup),
        buildTableRow('Gross Salary', employee!.grossSalary),
        buildTableRow('PF Number', employee!.pf),
        buildTableRow('Shift Type', employee!.shiftType),
        buildTableRow('Aadhar', employee!.aadhar),
        buildTableRow('Last Education', employee!.lastEducation),
        buildTableRow('Degree', employee!.degree),
        buildTableRow('College', employee!.college),
        buildTableRow('Completion Year', employee!.completionYear.toString()),
        buildTableRow('Address', employee!.address),
        buildTableRow('Emergency Contact', employee!.emergencyContact),
      ],
    );
  }

  Widget buildDocumentsTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(4),
        1: FlexColumnWidth(6),
      },
      border: TableBorder.all(color: Colors.grey.shade300),
      children: [
        buildClickableTableRow('Resume', employee!.documents!.resume),
        buildClickableTableRow('ID Proof', employee!.documents!.idProof),
        buildClickableTableRow('Address Proof', employee!.documents!.addressProof),
        buildClickableTableRow('PAN Card', employee!.documents!.panCard),
        buildClickableTableRow('Offer Letter', employee!.documents!.offerLetter),
        buildClickableTableRow('Educational Certificate', employee!.documents!.educationalCertificate),
      ],
    );
  }

  TableRow buildClickableTableRow(String title, String? documentUrl) {
    return TableRow(
      children: [
        buildCell(Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), true),
        buildCell(
          documentUrl != null && documentUrl.isNotEmpty
              ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  String completeUrl = '${Constants.baseUrl}/$documentUrl';
                  print("Url : $completeUrl");
                  _showWebViewPopup(completeUrl);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                child: const Text('View'),
              ),
              ElevatedButton(
                onPressed: () {
                  String completeUrl = '${Constants.baseUrl}/$documentUrl';
                  _downloadFile(completeUrl);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                child: const Text('Download'),
              ),
            ],
          )
              : const Text("No Document"),
        ),
      ],
    );
  }

  TableRow buildTableRow(String title, String value) {
    return TableRow(
      children: [
        buildCell(Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), true),
        buildCell(Text(value)),
      ],
    );
  }

  Widget buildCell(Widget child, [bool isHeader = false]) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: isHeader
          ? Container(
        color: Colors.grey.shade200,
        child: child,
      )
          : child,
    );
  }
}
