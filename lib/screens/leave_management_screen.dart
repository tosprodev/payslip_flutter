import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api_service.dart';
import 'package:flutter_html/flutter_html.dart';
import '../pages/createleaverequest_page.dart';


class LeaveManagementScreen extends StatelessWidget {
  final String token;
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
      floatingActionButton: AnimatedButton(),
    );
  }
}

class AnimatedButton extends StatefulWidget {
  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  double _scale = 1.0;
  Color _shadowColor = Colors.black.withOpacity(0.2);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _scale = 0.9;
          _shadowColor = Colors.black.withOpacity(0.4);
        });
      },
      onTapUp: (_) {
        setState(() {
          _scale = 1.0;
          _shadowColor = Colors.black.withOpacity(0.2);
        });
      },
      onTapCancel: () {
        setState(() {
          _scale = 1.0;
          _shadowColor = Colors.black.withOpacity(0.2);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.lightBlue[200]!,
              Colors.pink[200]!,
            ],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _shadowColor,
              blurRadius: 10.0,
              spreadRadius: 2.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        transform: Matrix4.identity()..scale(_scale),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateLeaveRequestScreen()),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: const CircleBorder(),
          clipBehavior: Clip.hardEdge,
          child: const Icon(
            Icons.add,
            color: Colors.black,
          ),
        ),
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
      margin: const EdgeInsets.all(8.0),
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
              padding: const EdgeInsets.all(12.0),
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
              duration: const Duration(milliseconds: 300),
              child: Column(
                children: [
                  if (_isExpanded) ...[
                    AnimatedOpacity(
                      opacity: _isExpanded ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
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
                            const ThingCard(),
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

  const LeaveDetailsCard({required this.leaveRequest, required this.totalDays});

  @override
  Widget build(BuildContext context) {
    DateTime leaveFrom = DateTime.parse(leaveRequest['leave_date_from']);
    DateTime leaveTo = DateTime.parse(leaveRequest['leave_date_to']);

    return Card(
      color: Colors.white70,
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          // Card Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.lightBlue[200]!,
                  Colors.pink[200]!,
                ],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Text(
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
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12.0),
            child: Table(
              border: const TableBorder(
                horizontalInside: BorderSide(color: Colors.black, width: 1.0),
                verticalInside: BorderSide(color: Colors.black, width: 1.0),
                top: BorderSide(color: Colors.black, width: 1.0),
                bottom: BorderSide(color: Colors.black, width: 1.0),
                left: BorderSide(color: Colors.black, width: 1.0),
                right: BorderSide(color: Colors.black, width: 1.0),
              ),
              defaultColumnWidth: const IntrinsicColumnWidth(),
              children: [
                // Row for 'From'
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Leave Type:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        leaveRequest['day_type'] == 'full_day' ? 'Full Day' : 'Half Day',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'From:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(leaveFrom),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'To:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(leaveTo),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Total Days:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${totalDays} ${totalDays == 1 ? 'Day' : 'Days'}',
                        style: const TextStyle(fontSize: 12),
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

  const StatusCard({required this.leaveRequest});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red[100],
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.lightBlue[200]!,
                  Colors.pink[200]!,
                ],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            width: double.infinity,
            child: const Text(
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
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: leaveRequest['status'] == 'approved' ? Colors.green[400] : Colors.red[500],
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Text(
              '${leaveRequest['admin_reason']}',
              style: const TextStyle(
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

  const ExpandableCard({required this.reason});

  @override
  _ExpandableCardState createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange[100],
      margin: const EdgeInsets.only(bottom: 8.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
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
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.lightBlue[200]!,
                          Colors.pink[200]!,
                        ],
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Reason',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 0, right: 8),
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
              const SizedBox(height: 0),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
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
  double _editButtonScale = 1.0;
  double _deleteButtonScale = 1.0;

  void _onEditButtonPressed() {
    print('Edit button pressed');
  }

  void _onDeleteButtonPressed() {
    print('Delete button pressed');
  }

  void _animateButtonPress(String buttonType) {
    setState(() {
      if (buttonType == 'edit') {
        _editButtonScale = 0.95;
      } else if (buttonType == 'delete') {
        _deleteButtonScale = 0.95;
      }
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        if (buttonType == 'edit') {
          _editButtonScale = 1.0;
        } else if (buttonType == 'delete') {
          _deleteButtonScale = 1.0;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      color: Colors.transparent,
      elevation: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                _animateButtonPress('edit');
                _onEditButtonPressed();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.identity()..scale(_editButtonScale),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/edit.png',
                        color: Colors.blue,
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Edit',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Delete Button
          Expanded(
            child: GestureDetector(
              onTap: () {
                _animateButtonPress('delete');
                _onDeleteButtonPressed();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.identity()..scale(_deleteButtonScale),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/delete.png',
                        color: Colors.red,
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 4),
                      const Text(
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





