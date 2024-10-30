import 'package:flutter/material.dart';
import 'package:html_editor_plus/html_editor.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart'; // Import your ApiService

class CreateLeaveRequestScreen extends StatefulWidget {
  @override
  _CreateLeaveRequestScreenState createState() => _CreateLeaveRequestScreenState();
}

class _CreateLeaveRequestScreenState extends State<CreateLeaveRequestScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String? _token;
  final _formKey = GlobalKey<FormState>();
  String reason = '';
  int wordCount = 0;
  bool _isLoading = false;

  final Map<String, String> leaveTypeMapping = {
    'Select Leave Type': '',
    'Casual Leave': 'casual',
    'Medical Leave': 'medical',
    'Unpaid Leave': 'unpaid',
  };

  List<String> leaveTypes = [];
  List<String> dayTypes = ['Full Day', 'Half Day'];

  String leaveType = '';
  String dayType = 'Full Day';
  DateTime leaveDateFrom = DateTime.now();
  DateTime leaveDateTo = DateTime.now();

  ApiService apiService = ApiService();
  final HtmlEditorController _htmlEditorController = HtmlEditorController();

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _loadToken();
    leaveTypes = leaveTypeMapping.keys.toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateWordCount(String value) {
    final words = value.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
    setState(() {
      wordCount = words.length;
    });
  }

  void _submitForm() async {
    if (wordCount < 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter at least 15 words')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String token = _token ?? '';

    Map<String, dynamic> requestData = {
      'leave_type': leaveTypeMapping[leaveType] ?? '',
      'day_type': dayType.toLowerCase().replaceAll(' ', '_'),
      'reason': reason,
      'leave_date_from': DateFormat('yyyy-MM-dd').format(leaveDateFrom),
      'leave_date_to': DateFormat('yyyy-MM-dd').format(leaveDateTo),
    };

    final response = await apiService.submitLeaveRequest(token, requestData);

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response?['status'] == 'success'
            ? 'Leave request submitted successfully!'
            : response?['message'] ?? 'Error submitting request.'),
        backgroundColor: response?['status'] == 'success' ? Colors.green : Colors.red,
      ),
    );

    if (response?['status'] == 'success') {
      Navigator.of(context).pop();
    }
  }

  void _onLeaveTypeChanged(String? newValue) {
    setState(() {
      leaveType = newValue ?? '';
    });
  }

  String formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  Future<void> _getEditorContent() async {
    reason = await _htmlEditorController.getText() ?? '';
    _updateWordCount(reason);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Leave Request'),
      ),
      body: FadeTransition(
        opacity: _animation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Leave Type',
                      border: OutlineInputBorder(),
                    ),
                    value: leaveType.isNotEmpty ? leaveType : null,
                    onChanged: _onLeaveTypeChanged,
                    items: leaveTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value == null || value.isEmpty || value == 'Select Leave Type') {
                        return 'Please select leave type';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Day Type',
                      border: OutlineInputBorder(),
                    ),
                    value: dayType,
                    onChanged: (newValue) {
                      setState(() {
                        dayType = newValue!;
                      });
                    },
                    items: dayTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select day type';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  HtmlEditor(
                    controller: _htmlEditorController,
                    htmlEditorOptions: HtmlEditorOptions(
                      hint: 'Enter your reason here...',
                    ),
                    callbacks: Callbacks(
                      onInit: () {
                        _htmlEditorController.setText(''); // Initialize the editor with empty content
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('Word Count: $wordCount', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Leave Date From',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: leaveDateFrom,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null && pickedDate != leaveDateFrom) {
                            setState(() {
                              leaveDateFrom = pickedDate;
                            });
                          }
                        },
                      ),
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text: formatDate(leaveDateFrom),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Leave Date To',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: leaveDateTo,
                            firstDate: leaveDateFrom,
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null && pickedDate != leaveDateTo) {
                            setState(() {
                              leaveDateTo = pickedDate;
                            });
                          }
                        },
                      ),
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text: formatDate(leaveDateTo),
                    ),
                  ),
                  if (leaveType == 'Medical Leave') ...[
                    SizedBox(height: 20),
                    Text('Upload Medical Prescription'),
                    ElevatedButton(
                      onPressed: () {
                        // Implement upload logic here
                      },
                      child: Text('Upload Prescription'),
                    ),
                  ],
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _getEditorContent(); // Update content before submission
                      _submitForm();
                    },
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Submit Leave Request'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
