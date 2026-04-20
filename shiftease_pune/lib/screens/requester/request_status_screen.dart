import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RequestStatusScreen extends StatelessWidget {
  const RequestStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Safely retrieve the jobId passed from the My Requests screen
    final String jobId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Status'),
      ),
      // Listen to the specific request document in Firestore
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
            return const Center(child: Text('Request not found or has been deleted.'));
          }

          // Extract the data
          final requestData = snapshot.data!.data() as Map<String, dynamic>;
          final String status = requestData['status'] ?? 'Pending';
          final String? workerId = requestData['workerId'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Status Indicator
                _buildStatusCard(status),
                const SizedBox(height: 16),

                // 2. Job Details Summary
                _buildJobDetailsCard(requestData),
                const SizedBox(height: 16),

                // 3. Worker Details (Only show if Accepted and workerId exists)
                if (status == 'Accepted' && workerId != null)
                  _buildWorkerDetails(workerId),

                const SizedBox(height: 32),

                // 4. Cancel Button (Only allow cancellation if still Pending)
                if (status == 'Pending')
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _cancelRequest(context, jobId),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancel Request', style: TextStyle(fontSize: 16)),
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

  // Helper Widget: Visual representation of the job's current status
  Widget _buildStatusCard(String status) {
    return Card(
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(
          status == 'Accepted' ? Icons.check_circle : Icons.hourglass_empty,
          color: status == 'Accepted' ? Colors.green : Colors.orange,
          size: 40,
        ),
        title: Text(
          'Status: $status',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          status == 'Accepted'
              ? 'A worker has accepted your request!'
              : 'Waiting for a local helper to accept...',
        ),
      ),
    );
  }

  // Helper Widget: Shows what the requester originally posted
  Widget _buildJobDetailsCard(Map<String, dynamic> data) {
    final DateTime dateTime = (data['dateTime'] as Timestamp).toDate();
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Job Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.work_outline),
              title: Text(data['name'] ?? 'Job'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.location_on_outlined),
              title: Text(data['location'] ?? 'Location'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime)),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget: Fetches and displays the assigned worker's profile
  Widget _buildWorkerDetails(String workerId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(workerId).get(),
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

        final workerData = snapshot.data!.data() as Map<String, dynamic>;

        return Card(
          elevation: 2,
          color: Colors.green.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.handshake, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Worker Contact Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.person_outline),
                  title: Text(workerData['name'] ?? 'Worker Name', style: const TextStyle(fontSize: 18)),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.phone),
                  title: Text(workerData['phone'] ?? 'No phone number provided', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Call to coordinate the shift'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper Method: Deletes the document from Firestore if cancelled
  Future<void> _cancelRequest(BuildContext context, String jobId) async {
    try {
      await FirebaseFirestore.instance.collection('requests').doc(jobId).delete();
      
      if (!context.mounted) return;
      
      Navigator.pop(context); // Go back to the dashboard
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request cancelled successfully.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cancelling request: $e')),
      );
    }
  }
}