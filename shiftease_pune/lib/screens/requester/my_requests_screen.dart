import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MyRequestsScreen extends StatelessWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz, size: 28),
            tooltip: 'Switch Role',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/role_selection');
            },
          ),
        ],
      ),
      // Use StreamBuilder to listen to Firestore instead of Provider
      body: currentUser == null
          ? const Center(child: Text('Please log in.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('requests')
                  .where('requesterId', isEqualTo: currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                // If there is no data or the list is empty, show the empty state
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No requests yet.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  );
                }

                // We have data! Map it to a list of cards
                final requests = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final doc = requests[index];
                    final data = doc.data() as Map<String, dynamic>;
                    
                    // Convert Firestore Timestamp to Dart DateTime
                    final DateTime dateTime = (data['dateTime'] as Timestamp).toDate();

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          data['name'] ?? 'Job',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(data['location'] ?? ''),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(DateFormat('MMM dd, hh:mm a').format(dateTime)),
                              ],
                            ),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(
                            data['status'] ?? 'Pending',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          backgroundColor: data['status'] == 'Accepted' ? Colors.green : Colors.orange,
                          side: BorderSide.none,
                        ),
                        onTap: () {
                          // Pass the Firebase Document ID to the status screen
                          Navigator.pushNamed(context, '/request_status', arguments: doc.id);
                        },
                      ),
                    );
                  },
                );
              },
            ),
      // Floating Action Button restored
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create_request');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}