// ignore_for_file: use_build_context_synchronously, deprecated_member_use, unnecessary_null_comparison, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../api_service.dart';
import '../constants.dart';
import 'package:open_file/open_file.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/foundation.dart';

class ProfileScreen extends StatefulWidget {
  final String token;

  const ProfileScreen({super.key, required this.token});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ApiService apiService;
  Map<String, dynamic>? profileData;

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final fetchedData = await apiService.fetchEmployeeProfile(widget.token);
    setState(() {
      profileData = fetchedData;
    });
  }

  void _showWebViewPopup(String url) {
    double loadingProgress = 0.0;
    bool isLoading = true;
    bool isDownloadableDocument(String url) {
      return url.endsWith('.pdf') || url.endsWith('.doc') || url.endsWith('.docx') ||
          url.endsWith('.ppt') || url.endsWith('.pptx') || url.endsWith('.xls') ||
          url.endsWith('.xlsx') || url.endsWith('.txt');
    }
    if (isDownloadableDocument(url)) {
      _showConfirmationDialog(context, url);
      return;
    }
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
                        _showErrorDialog(context, "Failed to load the document: $message");
                      },
                      onLoadHttpError: (InAppWebViewController controller, Uri? url, int statusCode, String description) {
                        setState(() {
                          isLoading = false;
                        });
                        _showErrorDialog(context, "HTTP Error: $statusCode $description");
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

  void _showConfirmationDialog(BuildContext context, String url) {
    ArtSweetAlert.show(
      context: context,
      artDialogArgs: ArtDialogArgs(
        title: 'Open Document',
        text: 'This document is downloadable. Would you like to open it in your web browser?',
        type: ArtSweetAlertType.info,
        showCancelBtn: true,
        confirmButtonText: 'Open',
        cancelButtonText: 'Cancel',
        onConfirm: () {
          Navigator.of(context).pop();
          _launchURL(url);
        },
        onCancel: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _showErrorDialog(context, "Could not launch $url");
    }
  }

  Future<void> _requestPermissionAndDownload(String url) async {
    PermissionStatus status;

    if (Platform.isAndroid) {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      final AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        status = await Permission.manageExternalStorage.status;
        if (status.isDenied || status.isRestricted || status.isLimited) {
          status = await Permission.manageExternalStorage.request();
        }
      } else {
        status = await Permission.storage.status;
        if (status.isDenied || status.isRestricted || status.isLimited) {
          status = await Permission.storage.request();
        }
      }
    } else {
      status = await Permission.storage.status;
      if (status.isDenied || status.isRestricted || status.isLimited) {
        status = await Permission.storage.request();
      }
    }
    if (status.isGranted) {
      await _downloadFile(url);
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
      _showErrorDialog(context, "Please enable storage permission in settings to download files.");
    } else {
      _showErrorDialog(context, "Storage permission is required to download files.");
    }
  }

  Future<void> _downloadFile(String url) async {
    Directory? downloadsDir;

    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download');
    } else {
      downloadsDir = await getApplicationDocumentsDirectory();
    }

    final appFolder = Directory('${downloadsDir.path}/${Constants.appName}');
    if (!await appFolder.exists()) {
      await appFolder.create();
    }

    final filePath = '${appFolder.path}/${url.split('/').last}';
    HttpClient httpClient = HttpClient();
    try {
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();
      final bytes = await consolidateHttpClientResponseBytes(response);
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      _showOpenFileDialog(context, filePath);
    } catch (e) {
      _showErrorDialog(context, "Download failed: $e");
    } finally {
      httpClient.close();
    }
  }

  void _showOpenFileDialog(BuildContext context, String filePath) {
    ArtSweetAlert.show(
      context: context,
      artDialogArgs: ArtDialogArgs(
        title: "Download Complete",
        text: "Would you like to open the downloaded file?",
        type: ArtSweetAlertType.success,
        showCancelBtn: true,
        confirmButtonText: "Open",
        cancelButtonText: "Cancel",
        onConfirm: () {
          OpenFile.open(filePath);
          Navigator.of(context).pop();
        },
        onCancel: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    ArtSweetAlert.show(
      context: context,
      artDialogArgs: ArtDialogArgs(
        title: "Error",
        text: errorMessage,
        type: ArtSweetAlertType.danger,
        confirmButtonText: "OK",
        onConfirm: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: profileData == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Center(
                child: CircleAvatar(
                  radius: 80,
                  backgroundImage: profileData!['employee']['photo'] != null
                      ? NetworkImage('${Constants.baseUrl}/${profileData!['employee']['photo']}')
                      : const AssetImage('assets/default_profile.png') as ImageProvider,
                ),
              ),
              const SizedBox(height: 16.0),
              buildSectionHeader("Profile Details"),
              buildProfileTable(),
              if (profileData!['employee']['documents'] != null) ...[
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
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
        buildTableRow('Employee ID', profileData!['employee']['employee_id'] ?? 'N/A'),
        buildTableRow('Full Name', profileData!['employee']['full_name'] ?? 'N/A'),
        buildTableRow('Email', profileData!['employee']['email'] ?? 'N/A'),
        buildTableRow('Phone', profileData!['employee']['phone'] ?? 'N/A'),
        buildTableRow('PAN Number', profileData!['employee']['pan_number'] ?? 'N/A'),
        buildTableRow('Bank Name', profileData!['employee']['bank_name'] ?? 'N/A'),
        buildTableRow('Account Number', profileData!['employee']['bank_account_number'] ?? 'N/A'),
        buildTableRow('IFSC Code', profileData!['employee']['ifsc_code'] ?? 'N/A'),
        buildTableRow('Joining Date', profileData!['employee']['doj'] ?? 'N/A'),
        buildTableRow('Date of Birth', profileData!['employee']['dob'] ?? 'N/A'),
        buildTableRow('Blood Group', profileData!['employee']['bloodgroup'] ?? 'N/A'),
        buildTableRow('Gross Salary', profileData!['employee']['gross_salary']?.toString() ?? 'N/A'),
        buildTableRow('PF Number', profileData!['employee']['pf'] ?? 'N/A'),
        buildTableRow('Shift Type', profileData!['employee']['shift_type'] ?? 'N/A'),
        buildTableRow('Aadhar', profileData!['employee']['aadhar'] ?? 'N/A'),
        buildTableRow('Last Education', profileData!['employee']['last_education'] ?? 'N/A'),
        buildTableRow('Degree', profileData!['employee']['degree'] ?? 'N/A'),
        buildTableRow('College', profileData!['employee']['college'] ?? 'N/A'),
        buildTableRow('Completion Year', profileData!['employee']['completion_year']?.toString() ?? 'N/A'),
        buildTableRow('Address', profileData!['employee']['address'] ?? 'N/A'),
        buildTableRow('Emergency Contact', profileData!['employee']['emergency_contact'] ?? 'N/A'),
      ],
    );
  }

  TableRow buildClickableTableRow(String title, String? documentUrl) {
    return TableRow(
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: buildCell(
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            true,
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: buildCell(
            documentUrl != null && documentUrl.isNotEmpty
                ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    String completeUrl = '${Constants.baseUrl}/$documentUrl';
                    _showWebViewPopup(completeUrl);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  child: const Text(
                    'View',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    String completeUrl = '${Constants.baseUrl}/$documentUrl';
                    _requestPermissionAndDownload(completeUrl);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  child: const Text(
                    'Download',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )
                : const Text(
              "No Document",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
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
        buildClickableTableRow('Resume', profileData!['employee']['documents']['resume']),
        buildClickableTableRow('ID Proof', profileData!['employee']['documents']['id_proof']),
        buildClickableTableRow('Address Proof', profileData!['employee']['documents']['address_proof']),
        buildClickableTableRow('PAN Card', profileData!['employee']['documents']['pan_card']),
        buildClickableTableRow('Offer Letter', profileData!['employee']['documents']['offer_letter']),
        buildClickableTableRow('Educational Certificate', profileData!['employee']['documents']['educational_certificate']),
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