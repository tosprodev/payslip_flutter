// ignore_for_file: deprecated_member_use, unused_local_variable

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api_service.dart';
import '../constants.dart';

class AppointmentsScreen extends StatefulWidget {
  final String token;

  const AppointmentsScreen({super.key, required this.token});

  @override
  // ignore: library_private_types_in_public_api
  _AppointmentsScreenState createState() => _AppointmentsScreenState();
}

Color _getStatusTextColor(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return Colors.yellow.shade700;
    case 'confirmed':
      return Colors.green.shade700;
    case 'cancelled':
      return Colors.red.shade700;
    case 'transferred':
      return Colors.orange.shade700;
    case 'visited':
      return Colors.blue.shade700;
    default:
      return Colors.grey.shade700;
  }
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _futureAppointments = [];
  List<dynamic> _pastAppointments = [];
  List<dynamic> _filteredFutureAppointments = [];
  List<dynamic> _filteredPastAppointments = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    final response =
        await ApiService.fetchAppointments(widget.token, Constants.baseUrl);
    if (response != null && response['status'] != 'error') {
      setState(() {
        _futureAppointments = response['future_appointments'] ?? [];
        _pastAppointments = response['past_appointments'] ?? [];
        _filteredFutureAppointments = _futureAppointments;
        _filteredPastAppointments = _pastAppointments;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(response?['message'] ?? 'Failed to fetch appointments')),
      );
    }
  }

  void _filterAppointments(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredFutureAppointments = _futureAppointments.where((appointment) {
        final clientName =
            appointment['client']?['client_name']?.toLowerCase() ?? '';
        final companyName =
            appointment['client']?['company_name']?.toLowerCase() ?? '';
        final clientPhone =
            appointment['client']?['phone']?.toLowerCase() ?? '';
        final clientEmail =
            appointment['client']?['email']?.toLowerCase() ?? '';
        final creatorName =
            appointment['creator']?['full_name']?.toLowerCase() ?? '';
        return clientName.contains(_searchQuery) ||
            companyName.contains(_searchQuery) ||
            clientPhone.contains(_searchQuery) ||
            clientEmail.contains(_searchQuery) ||
            creatorName.contains(_searchQuery);
      }).toList();

      _filteredPastAppointments = _pastAppointments.where((appointment) {
        final clientName =
            appointment['client']?['client_name']?.toLowerCase() ?? '';
        final companyName =
            appointment['client']?['company_name']?.toLowerCase() ?? '';
        final clientPhone =
            appointment['client']?['phone']?.toLowerCase() ?? '';
        final clientEmail =
            appointment['client']?['email']?.toLowerCase() ?? '';
        final creatorName =
            appointment['creator']?['full_name']?.toLowerCase() ?? '';
        return clientName.contains(_searchQuery) ||
            companyName.contains(_searchQuery) ||
            clientPhone.contains(_searchQuery) ||
            clientEmail.contains(_searchQuery) ||
            creatorName.contains(_searchQuery);
      }).toList();
    });
  }

  Color _getHeaderColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.yellow.shade100;
      case 'confirmed':
        return Colors.green.shade100;
      case 'cancelled':
        return Colors.red.shade100;
      case 'transferred':
        return Colors.orange.shade100;
      case 'visited':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: _filterAppointments,
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'New Appointments'),
                    Tab(text: 'Past Appointments'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAppointmentsList(_filteredFutureAppointments),
                      _buildAppointmentsList(_filteredPastAppointments),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAppointmentsList(List<dynamic> appointments) {
    if (appointments.isEmpty) {
      return const Center(child: Text('No appointments available.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        final client = appointment['client'] ?? {};
        final creator = appointment['creator'] ?? {};
        final bdm = appointment['bdm'] ?? {};

        if (appointment['isExpanded'] == null) {
          appointment['isExpanded'] = false;
        }

        final appointmentDate = DateFormat('dd-MM-yyyy')
            .format(DateTime.parse(appointment['appointment_date']));
        final appointmentTime = DateFormat('hh:mm a')
            .format(DateFormat('HH:mm').parse(appointment['appointment_time']));
        final headerColor =
            _getHeaderColor(appointment['visit_status'] ?? 'unknown');

        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: headerColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${client['client_name'] != null && client['client_name'].length > 25 ? client['client_name'].substring(0, 25) + '..' : client['client_name'] ?? 'N/A'}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        if (appointment['map_url'] != null &&
                            appointment['map_url'].isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.location_on),
                            onPressed: () {
                              _launchMap(appointment['map_url']);
                            },
                            color: Colors.black,
                            iconSize: 24,
                            padding: const EdgeInsets.all(8.0),
                            constraints: const BoxConstraints(),
                            splashRadius: 14,
                            tooltip: 'Open Map',
                          ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.expand_more),
                          onPressed: () {
                            setState(() {
                              appointment['isExpanded'] =
                                  !(appointment['isExpanded'] ?? false);
                            });
                          },
                          color: Colors.black,
                          iconSize: 24,
                          padding: const EdgeInsets.all(8.0),
                          constraints: const BoxConstraints(),
                          splashRadius: 20,
                          tooltip: 'Expand',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (appointment['isExpanded'] ?? false)
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        elevation: 8,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Appointment Detail',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              Table(
                                border: TableBorder.all(color: Colors.grey),
                                columnWidths: const {
                                  0: FractionColumnWidth(0.3),
                                  1: FractionColumnWidth(0.7)
                                },
                                children: [
                                  TableRow(children: [
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Visit date:'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(appointmentDate),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Visit Time:'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(appointmentTime),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Purpose:'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          appointment['feedback'] ?? 'N/A'),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Status:'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        appointment['visit_status'] ?? 'N/A',
                                        style: TextStyle(
                                          color: _getStatusTextColor(
                                              appointment['visit_status'] ??
                                                  'unknown'),
                                        ),
                                      ),
                                    ),
                                  ]),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        elevation: 8,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Client Details',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              Table(
                                border: TableBorder.all(color: Colors.grey),
                                columnWidths: const {
                                  0: FractionColumnWidth(0.3),
                                  1: FractionColumnWidth(0.7)
                                },
                                children: [
                                  TableRow(children: [
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Name:'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child:
                                          Text(client['client_name'] ?? 'N/A'),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Business:'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child:
                                          Text(client['company_name'] ?? 'N/A'),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Phone:'),
                                    ),
                                    if (client['phone'] != null &&
                                        client['phone'].isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                _launchPhone(client['phone']);
                                              },
                                              child: Container(
                                                width: 20,
                                                height: 20,
                                                decoration: const BoxDecoration(
                                                  color: Colors.lightGreen,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.phone,
                                                    size: 12,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            GestureDetector(
                                              onTap: () {
                                                _launchPhone(client['phone']);
                                              },
                                              child: Text(client['phone'],
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.blue,
                                                      decoration: TextDecoration
                                                          .underline)),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('N/A'),
                                      ),
                                  ]),
                                  TableRow(children: [
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Email:'),
                                    ),
                                    if (client['email'] != null &&
                                        client['email'].isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                _launchEmail(client['email']);
                                              },
                                              child: Container(
                                                width: 20,
                                                height: 20,
                                                decoration: const BoxDecoration(
                                                  color: Colors.lightBlue,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.email,
                                                    size: 12,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            GestureDetector(
                                              onTap: () {
                                                _launchEmail(client['email']);
                                              },
                                              child: Text(client['email'],
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.blue,
                                                      decoration: TextDecoration
                                                          .underline)),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('N/A'),
                                      ),
                                  ]),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        elevation: 8,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Sales Person Details',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              Table(
                                border: TableBorder.all(color: Colors.grey),
                                columnWidths: const {
                                  0: FractionColumnWidth(0.3),
                                  1: FractionColumnWidth(0.7)
                                },
                                children: [
                                  TableRow(children: [
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Name:'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child:
                                          Text(creator['full_name'] ?? 'N/A'),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Emp. ID:'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        creator['employee_id'] != null
                                            ? creator['employee_id']
                                                    .startsWith('AAIK')
                                                ? '${creator['employee_id']} (KOLKATA)'
                                                : creator['employee_id']
                                                        .startsWith('AAIG')
                                                    ? '${creator['employee_id']} (GOA)'
                                                    : creator['employee_id']
                                            : 'N/A',
                                      ),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Phone:'),
                                    ),
                                    if (creator['phone'] != null &&
                                        creator['phone'].isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                _launchPhone(creator['phone']);
                                              },
                                              child: Container(
                                                width: 20,
                                                height: 20,
                                                decoration: const BoxDecoration(
                                                  color: Colors.lightGreen,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.phone,
                                                    size: 12,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            GestureDetector(
                                              onTap: () {
                                                _launchPhone(creator['phone']);
                                              },
                                              child: Text(creator['phone'],
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.blue,
                                                      decoration: TextDecoration
                                                          .underline)),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('N/A'),
                                      ),
                                  ]),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton('Confirm', Colors.green),
                          _buildActionButton('Cancel', Colors.red),
                          _buildActionButton('Transfer', Colors.orange),
                          _buildActionButton('Visited', Colors.blue),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(String text, Color color) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child:
          Text(text, style: const TextStyle(fontSize: 12, color: Colors.white)),
    );
  }

  void _launchMap(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunch(emailUri.toString())) {
      await launch(emailUri.toString());
    } else {
      throw 'Could not launch $emailUri';
    }
  }

  void _launchPhone(String phone) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    } else {
      throw 'Could not launch $phoneUri';
    }
  }
}
