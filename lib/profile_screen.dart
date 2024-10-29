import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'; // Ensure this import is correct
import 'login_screen.dart';
import 'api_service.dart';
import 'employee.dart';
import 'constants.dart';

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

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showWebViewPopup(String url) {
    double loadingProgress = 0.0; // Initialize loading progress
    bool isLoading = true; // Initialize loading state

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Document'),
              content: Container(
                width: double.maxFinite,
                height: 400,
                child: Stack(
                  children: [
                    InAppWebView(
                      initialUrlRequest: URLRequest(
                        url: WebUri(url), // Keep using WebUri for the initial URL
                      ),
                      onWebViewCreated: (InAppWebViewController controller) {
                        // Additional configuration can go here
                      },
                      onLoadStart: (InAppWebViewController controller, Uri? url) {
                        setState(() {
                          isLoading = true; // Start loading
                        });
                      },
                      onLoadStop: (InAppWebViewController controller, Uri? url) async {
                        setState(() {
                          isLoading = false; // Stop loading
                        });
                      },
                      onProgressChanged: (InAppWebViewController controller, int progress) {
                        setState(() {
                          loadingProgress = progress / 100.0; // Update loading progress (0.0 to 1.0)
                        });
                      },
                      onLoadError: (InAppWebViewController controller, Uri? url, int code, String message) {
                        setState(() {
                          isLoading = false; // Stop loading
                        });
                        _showSnackbar("Failed to load the document: $message");
                      },
                      onLoadHttpError: (InAppWebViewController controller, Uri? url, int statusCode, String description) {
                        setState(() {
                          isLoading = false; // Stop loading
                        });
                        _showSnackbar("HTTP Error: $statusCode $description");
                      },
                      initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                          mediaPlaybackRequiresUserGesture: false, // Allows media to autoplay
                        ),
                      ),
                    ),
                    if (isLoading) // Show loader if loading
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 10),
                            Text(
                              "${(loadingProgress * 100).toStringAsFixed(0)}%", // Show loading percentage
                              style: TextStyle(fontSize: 16),
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
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: employee == null
            ? Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Center(
                child: CircleAvatar(
                  radius: 80,
                  backgroundImage: employee!.photo != null
                      ? NetworkImage('${Constants.baseUrl}/${employee!.photo}')
                      : AssetImage('assets/default_profile.png') as ImageProvider,
                ),
              ),
              SizedBox(height: 16.0),
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
      columnWidths: {
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
      columnWidths: {
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
        buildCell(Text(title, style: TextStyle(fontWeight: FontWeight.bold)), true),
        buildCell(
          documentUrl != null && documentUrl.isNotEmpty
              ? ElevatedButton(
            onPressed: () {
              String completeUrl = '${Constants.baseUrl}/$documentUrl'; // Construct the complete URL
              _showWebViewPopup(completeUrl); // Open the WebView popup
            },
            child: Text(
              'View', // Show "View" button instead of document name
              style: TextStyle(color: Colors.white), // Text color for better visibility
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Background color of the button
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0), // Button padding
            ),
          )
              : Text('Not Provided', style: TextStyle(color: Colors.grey)),
          false,
        ),
      ],
    );
  }

  TableRow buildTableRow(String title, String value) {
    return TableRow(
      children: [
        buildCell(Text(title, style: TextStyle(fontWeight: FontWeight.bold)), true),
        buildCell(Text(value), false),
      ],
    );
  }

  Widget buildCell(Widget child, bool isHeader) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: isHeader ? BoxDecoration(color: Colors.grey.shade200) : null,
        child: child,
      ),
    );
  }
}
