import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shiftease Pune',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Title
              const Text(
                'Select Your Role',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              const Text(
                'Choose how you want to use Shiftease today. You can always switch later in settings.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey, // Standard grey instead of AppTheme
                ),
              ),
              const SizedBox(height: 48),

              Card(
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: const Icon(
                    Icons.local_shipping,
                    size: 40,
                    color: Colors.blue,
                  ),
                  title: const Text(
                    'Need Help',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text('Post a shifting request'),
                  trailing: const Icon(Icons.chevron_right),
                  // Original navigation logic preserved exactly
                  onTap: () => Navigator.pushNamed(context, '/my_requests'),
                ),
              ),
              
              const SizedBox(height: 16),

              Card(
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: const Icon(
                    Icons.work,
                    size: 40,
                    color: Colors.brown,
                  ),
                  title: const Text(
                    'I Want Work',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text('Find and accept jobs'),
                  trailing: const Icon(Icons.chevron_right),
                  // Original navigation logic preserved exactly
                  onTap: () => Navigator.pushNamed(context, '/worker_dashboard'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}