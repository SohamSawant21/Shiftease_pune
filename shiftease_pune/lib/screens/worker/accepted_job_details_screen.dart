import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AcceptedJobDetailsScreen extends StatelessWidget {
  const AcceptedJobDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String jobId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accepted Job'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('requests').doc(jobId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Job not found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final String status = data['status'] ?? 'Pending';
          final String requesterId = data['requesterId'];
          
          // If the status changes while they are looking at it
          if (status != 'Accepted') {
            return const Center(child: Text('You are no longer assigned to this job.'));
          }

          final DateTime dateTime = (data['dateTime'] as Timestamp).toDate();
          final double payment = (data['payment'] as num).toDouble();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Contact Info Card (Fetches Requester Details)
                _buildRequesterContactCard(requesterId),
                const SizedBox(height: 16),

                // 2. Job Details Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Job Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Divider(),
                        Text(
                          data['name'] ?? 'Job Name',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(child: Text(data['location'] ?? '', style: const TextStyle(fontSize: 16))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime), style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.currency_rupee, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              '₹${payment.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 3. Drop Job Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDropJob(context, jobId),
                    icon: const Icon(Icons.warning_amber_rounded),
                    label: const Text('Decline / Drop Job', style: TextStyle(fontSize: 16)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper Widget: Fetches the Requester's Profile
  Widget _buildRequesterContactCard(String requesterId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(requesterId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox();
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;

        return Card(
          elevation: 2,
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.person, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Customer Contact Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.account_circle_outlined),
                  title: Text(userData['name'] ?? 'Customer Name', style: const TextStyle(fontSize: 18)),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.phone),
                  title: Text(userData['phone'] ?? 'No phone number', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Call to coordinate'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper Method: Confirm before dropping to prevent accidental clicks
  void _confirmDropJob(BuildContext context, String jobId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Drop this job?'),
          content: const Text('Are you sure you want to decline this job? It will be made available to other workers again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), // Cancel
              child: const Text('No, Keep It'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close dialog
                _dropJob(context, jobId); // Execute drop
              },
              child: const Text('Yes, Drop Job', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Helper Method: Updates Firestore to revert the job to 'Pending'
  Future<void> _dropJob(BuildContext context, String jobId) async {
    try {
      // 1. Revert status to Pending
      // 2. Remove the workerId from the document so it is unassigned using FieldValue.delete()
      await FirebaseFirestore.instance.collection('requests').doc(jobId).update({
        'status': 'Pending',
        'workerId': FieldValue.delete(), 
      });

      if (!context.mounted) return;
      
      Navigator.pop(context); // Go back to the dashboard
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job dropped. It is now available to others.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error dropping job: $e')),
      );
    }
  }
}