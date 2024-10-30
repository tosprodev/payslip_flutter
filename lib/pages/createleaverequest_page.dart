import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:flutter/cupertino.dart';
import 'dart:io'; // Import for file handling

class CreateLeaveRequestScreen extends StatefulWidget {
  @override
  _CreateLeaveRequestScreenState createState() => _CreateLeaveRequestScreenState();
}

class _CreateLeaveRequestScreenState extends State<CreateLeaveRequestScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final _formKey = GlobalKey<FormState>();
  List<String> leaveTypes = [
    'Select Leave Type',
    'Casual Leave',
    'Medical Leave',
    'Unpaid Leave'
  ];
  List<String> dayTypes = ['Full Day', 'Half Day'];
  String leaveType = '';
  String dayType = 'Full Day'; // Default value
  String reason = '';
  DateTime leaveDateFrom = DateTime.now();
  DateTime leaveDateTo = DateTime.now();
  bool _isLoading = false; // To track loading state

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Start loading
      });
      _formKey.currentState!.save();

      // Simulate a network call
      await Future.delayed(Duration(seconds: 2));

      // Here you would usually handle your API call
      // Simulating success or error
      bool success = true; // Change to false to simulate error

      setState(() {
        _isLoading = false; // Stop loading
      });

      // Show success or error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Leave request submitted successfully!' : 'Failed to submit leave request.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
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
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Reason',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter reason';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      reason = value!;
                    },
                  ),
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
                      text: formatDate(leaveDateFrom), // Format date
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
                            firstDate: DateTime.now(),
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
                      text: formatDate(leaveDateTo), // Format date
                    ),
                  ),
                  // Show prescription upload option if Medical Leave is selected
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
                    onPressed: _isLoading ? null : _submitForm, // Disable button if loading
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white) // Show loading indicator
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