import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/request_provider.dart';
// Note: Depending on your exact setup, you may need to import your Request model
// import '../../models/request.dart'; 

class MyRequestsScreen extends StatelessWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shiftease Pune'),
      ),
      // 1. Wrap the body in a Consumer to connect to your Provider state
      body: Consumer<RequestProvider>(
        builder: (context, provider, child) {
          // Fetch all requests belonging to the user
          final requests = provider.requests;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Header
                const Text(
                  'My Requests',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Manage your active relocation services and tracking updates.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                
                // 2. Dynamically show either the Empty State OR the List of Jobs
                Expanded(
                  child: requests.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 60,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No requests yet.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final request = requests[index];
                            
                            // 3. Simple, beginner-friendly Card for each request
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.local_shipping, 
                                  color: Colors.blue, 
                                  size: 32
                                ),
                                title: Text(
                                  request.location, 
                                  style: const TextStyle(fontWeight: FontWeight.bold)
                                ),
                                subtitle: Text('Status: ${request.status}'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  // 4. Feature Intact: Navigate to the status screen, passing the ID
                                  Navigator.pushNamed(
                                    context, 
                                    '/request_status', 
                                    arguments: request.id,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      // Default FloatingActionButton remains the same
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create_request');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}