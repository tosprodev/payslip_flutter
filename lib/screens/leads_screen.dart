import 'package:flutter/material.dart';

class LeadsScreen extends StatelessWidget {
  const LeadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leads'),
        backgroundColor: Colors.blueAccent,
      ),
      body: const Center(
        child: Text(
          'Leads Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
