import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api_service.dart';
import 'package:flutter_html/flutter_html.dart';
import '../pages/createleaverequest_page.dart';

class LeaveManagementScreen extends StatelessWidget {
  final String token; // Pass the token when creating the screen

  const LeaveManagementScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>?>(
        future: ApiService().fetchLeaveRequests(token),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Error fetching leave requests.'));
          } else {
            final leaveRequests = snapshot.data!['data'] as List<dynamic>;

            return ListView.builder(
              itemCount: leaveRequests.length,
              itemBuilder: (context, index) {
                final leaveRequest = leaveRequests[index];

                // Calculate total leave days
                DateTime leaveFrom = DateTime.parse(leaveRequest['leave_date_from']);
                DateTime leaveTo = DateTime.parse(leaveRequest['leave_date_to']);
                int totalDays = leaveTo.difference(leaveFrom).inDays + 1;

                return ExpandableMainCard(
                  leaveRequest: leaveRequest,
                  totalDays: totalDays,
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle the creation of a new leave request here
          // For example, navigate to a new screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateLeaveRequestScreen()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add), // Customize as needed
      ),
    );
  }
}

class ExpandableMainCard extends StatefulWidget {
  final Map<String, dynamic> leaveRequest;
  final int totalDays;

  ExpandableMainCard({required this.leaveRequest, required this.totalDays});

  @override
  _ExpandableMainCardState createState() => _ExpandableMainCardState();
}

class _ExpandableMainCardState extends State<ExpandableMainCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.leaveRequest['status'] == 'approved' ? Colors.green[100] : Colors.red[100],
      margin: EdgeInsets.all(8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Column(
          children: [
            // Card Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.lightBlue[800]!,
                    Colors.pink[800]!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: _isExpanded ? Radius.zero : Radius.circular(12),
                  bottomRight: _isExpanded ? Radius.zero : Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '# Request : ${capitalizeFirstLetter(widget.leaveRequest['leave_type'])} Leave For ${widget.totalDays} ${widget.totalDays == 1 ? 'Day' : 'Days'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 0),
                        Text(
                          'Created on: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.leaveRequest['created_at']))} (${widget.leaveRequest['day_type'] == 'full_day' ? 'Full Day' : 'Half Day'})',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
            // Expanded content
            AnimatedSize(
              duration: Duration(milliseconds: 300),
              child: Column(
                children: [
                  if (_isExpanded) ...[
                    AnimatedOpacity(
                      opacity: _isExpanded ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 300),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            ExpandableCard(reason: widget.leaveRequest['reason']),
                            LeaveDetailsCard(
                              leaveRequest: widget.leaveRequest,
                              totalDays: widget.totalDays,
                            ),
                            StatusCard(leaveRequest: widget.leaveRequest),
                            ThingCard(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LeaveDetailsCard extends StatelessWidget {
  final Map<String, dynamic> leaveRequest;
  final int totalDays;

  LeaveDetailsCard({required this.leaveRequest, required this.totalDays});

  @override
  Widget build(BuildContext context) {
    DateTime leaveFrom = DateTime.parse(leaveRequest['leave_date_from']);
    DateTime leaveTo = DateTime.parse(leaveRequest['leave_date_to']);

    return Card(
      color: Colors.white70,
      margin: EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          // Card Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.lightBlue[200]!,
                  Colors.pink[200]!,
                ],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(
              'Leave Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
          // Table for dates
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12.0),
            child: Table(
              border: TableBorder(
                horizontalInside: BorderSide(color: Colors.black, width: 1.0),
                verticalInside: BorderSide(color: Colors.black, width: 1.0),
                top: BorderSide(color: Colors.black, width: 1.0),
                bottom: BorderSide(color: Colors.black, width: 1.0),
                left: BorderSide(color: Colors.black, width: 1.0),
                right: BorderSide(color: Colors.black, width: 1.0),
              ),
              defaultColumnWidth: IntrinsicColumnWidth(),
              children: [
                // Row for 'From'
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Leave Type:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        leaveRequest['day_type'] == 'full_day' ? 'Full Day' : 'Half Day',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'From:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(leaveFrom),
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'To:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(leaveTo),
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Total Days:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${totalDays} ${totalDays == 1 ? 'Day' : 'Days'}',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatusCard extends StatelessWidget {
  final Map<String, dynamic> leaveRequest;

  StatusCard({required this.leaveRequest});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red[100],
      margin: EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          // Card Header
          Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.lightBlue[200]!,
                  Colors.pink[200]!,
                ],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            width: double.infinity,
            child: Text(
              'Status',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          // Card Body
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: leaveRequest['status'] == 'approved' ? Colors.green[400] : Colors.red[500],
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Text(
              '${leaveRequest['admin_reason']}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExpandableCard extends StatefulWidget {
  final String reason;

  ExpandableCard({required this.reason});

  @override
  _ExpandableCardState createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange[100],
      margin: EdgeInsets.only(bottom: 8.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded; // Toggle the expansion state
          });
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Full-width header
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.lightBlue[200]!,
                          Colors.pink[200]!,
                        ],
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                      ),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Reason',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 0, right: 8),
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.transparent,
                            child: Icon(
                              _isExpanded ? Icons.expand_less : Icons.expand_more,
                              color: Colors.black,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0),
              AnimatedSize(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Html(
                      data: _isExpanded
                          ? '${widget.reason}'
                          : '${widget.reason.split(' ').take(12).join(' ')}...',
                      style: {
                        "body": Style(
                          fontSize: FontSize(12),
                        ),
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}

class ThingCard extends StatefulWidget {
  const ThingCard({Key? key}) : super(key: key);

  @override
  _ThingCardState createState() => _ThingCardState();
}

class _ThingCardState extends State<ThingCard> {
  double _editButtonScale = 1.0; // Scale factor for edit button
  double _deleteButtonScale = 1.0; // Scale factor for delete button

  void _onEditButtonPressed() {
    // Handle edit action
    print('Edit button pressed');
  }

  void _onDeleteButtonPressed() {
    // Handle delete action
    print('Delete button pressed');
  }

  void _animateButtonPress(String buttonType) {
    setState(() {
      if (buttonType == 'edit') {
        _editButtonScale = 0.95; // Scale down on press
      } else if (buttonType == 'delete') {
        _deleteButtonScale = 0.95; // Scale down on press
      }
    });
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        if (buttonType == 'edit') {
          _editButtonScale = 1.0; // Reset scale
        } else if (buttonType == 'delete') {
          _deleteButtonScale = 1.0; // Reset scale
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.0),
      color: Colors.transparent, // Make card transparent
      elevation: 0, // No elevation for the card
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Equal space around buttons
        children: [
          // Edit Button
          Expanded(
            child: GestureDetector(
              onTap: () {
                _animateButtonPress('edit');
                _onEditButtonPressed();
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200), // Animation duration
                transform: Matrix4.identity()..scale(_editButtonScale), // Scaling animation
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.0), // Thinner padding for button
                  decoration: BoxDecoration(
                    color: Colors.blue[100], // Background color
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2), // Shadow color
                        spreadRadius: 1, // Spread radius
                        blurRadius: 4, // Blur radius
                        offset: Offset(0, 2), // Changes position of shadow
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/edit.png', // Path to your custom image icon
                        color: Colors.blue,
                        width: 20, // Smaller icon size
                        height: 20, // Smaller icon size
                      ),
                      SizedBox(width: 4), // Space between icon and text
                      Text(
                        'Edit',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8), // Space between buttons
          // Delete Button
          Expanded(
            child: GestureDetector(
              onTap: () {
                _animateButtonPress('delete');
                _onDeleteButtonPressed();
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200), // Animation duration
                transform: Matrix4.identity()..scale(_deleteButtonScale), // Scaling animation
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.0), // Thinner padding for button
                  decoration: BoxDecoration(
                    color: Colors.red[100], // Background color
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2), // Shadow color
                        spreadRadius: 1, // Spread radius
                        blurRadius: 4, // Blur radius
                        offset: Offset(0, 2), // Changes position of shadow
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/delete.png', // Path to your custom image icon
                        color: Colors.red,
                        width: 20, // Smaller icon size
                        height: 20, // Smaller icon size
                      ),
                      SizedBox(width: 4), // Space between icon and text
                      Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}





