import 'package:flutter/material.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        backgroundColor: Colors.blueAccent,
      ),
      body: const Center(
        child: Text(
          'Clients Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
