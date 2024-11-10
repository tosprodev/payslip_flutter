import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import '../api_service.dart';
import 'dart:async';

import 'home_page.dart';

class CreateLeaveRequestScreen extends StatefulWidget {
  @override
  _CreateLeaveRequestScreenState createState() =>
      _CreateLeaveRequestScreenState();
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
  File? _prescriptionImage;

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

  void submitSuccess(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(initialIndex: 3),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (wordCount < 15) {
        _showErrorDialog(context, 'Please enter at least 15 words in reason. Currently, you have entered only $wordCount words.');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final requestData = {
        'leave_type': leaveTypeMapping[leaveType] ?? '',
        'day_type': dayType.toLowerCase().replaceAll(' ', '_'),
        'reason': reason,
        'leave_date_from': DateFormat('yyyy-MM-dd').format(leaveDateFrom),
        'leave_date_to': DateFormat('yyyy-MM-dd').format(leaveDateTo),
      };

      try {
        final response = await apiService.submitLeaveRequest(_token ?? '', requestData, _prescriptionImage);
        setState(() {
          _isLoading = false;
        });
        if (response != null && response['status'] == 'success') {
          _showSuccessDialog(context, 'Leave request submitted for the review successfully!');
          submitSuccess(context);
        } else {
          _showErrorDialog(context, response?['message'] ?? 'Error submitting request.');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog(context, e.toString());
      }
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

  Future<void> _pickPrescriptionImage() async {
    final PermissionStatus permissionStatus = await Permission.camera.request();
    if (permissionStatus.isGranted) {
      final ImagePicker _picker = ImagePicker();
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxHeight: 600,
        maxWidth: 600,
      );
      if (pickedFile != null) {
        setState(() {
          _prescriptionImage = File(pickedFile.path);
        });
      }
    } else {
      _showErrorDialog(context, 'Please allow camera access to upload prescription.');
    }
  }

  Future<void> _pickImageFromFile() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 600,
      maxWidth: 600,
    );
    if (pickedFile != null) {
      setState(() {
        _prescriptionImage = File(pickedFile.path);
      });
    }
  }

  void _showImagePopup(BuildContext context, File image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Image.file(image),
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

  void _showSuccessDialog(BuildContext context, String successMessage) {
    ArtSweetAlert.show(
      context: context,
      artDialogArgs: ArtDialogArgs(
        title: "Success",
        text: successMessage,
        type: ArtSweetAlertType.success,
        confirmButtonText: "OK",
        onConfirm: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Leave Request'),
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
                    decoration: const InputDecoration(
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
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
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
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Leave Date From',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
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
                    controller: TextEditingController(text: formatDate(leaveDateFrom)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select leave start date';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Leave Date To',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
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
                    controller: TextEditingController(text: formatDate(leaveDateTo)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select leave end date';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Reason for Leave',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        reason = value;
                      });
                      _updateWordCount(value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter reason for leave';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Word Count: $wordCount',
                        style: TextStyle(
                          color: wordCount > 14 ? Colors.green : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_prescriptionImage != null)
                    GestureDetector(
                      onTap: () {
                        _showImagePopup(context, _prescriptionImage!);
                      },
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(_prescriptionImage!),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),

                  if (leaveType == 'Medical Leave')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('Upload Prescription (if any)'),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Capture'),
                              onPressed: _pickPrescriptionImage,
                            ),
                            const SizedBox(width: 10),
                            const Text(' Or '),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.folder),
                              label: const Text('Choose'),
                              onPressed: _pickImageFromFile,
                            ),
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Submit Leave Request'),
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
