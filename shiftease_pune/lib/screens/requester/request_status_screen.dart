import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestStatusScreen extends StatelessWidget {
  const RequestStatusScreen({super.key});

  // NEW: The logic to launch the native phone dialer
  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open the phone dialer.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred while launching the dialer.')),
        );
      }
    }
  }

  Future<void> _cancelRequest(BuildContext context, String jobId) async {
    try {
      await FirebaseFirestore.instance.collection('requests').doc(jobId).delete();
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request cancelled successfully.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cancelling request: $e')),
        );
      }
    }
  }

  Future<void> _markAsCompleted(BuildContext context, String jobId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete Job?'),
        content: const Text('Are you sure the shifting is completely done? This will close the job and finalize it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No, Go Back'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Mark Completed'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('requests').doc(jobId).update({
          'status': 'Completed',
        });
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Job marked as completed.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating status: $e')),
          );
        }
      }
    }
  }

  Widget _buildWorkerDetails(BuildContext context, String workerId) {
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

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final phone = userData['phone'] ?? 'No phone provided';

        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.engineering, color: Colors.white),
            ),
            title: Text(userData['name'] ?? 'Worker'),
            subtitle: Text(phone),
            // NEW: The clickable phone icon
            trailing: IconButton(
              icon: const Icon(Icons.phone, color: Colors.blue),
              onPressed: () => _makePhoneCall(context, phone),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String jobId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: const Text('Request Status')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('requests').doc(jobId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Request not found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final status = data['status'] ?? 'Pending';
          final dateTime = (data['dateTime'] as Timestamp).toDate();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: status == 'Accepted' ? Colors.green.shade50 : Colors.orange.shade50,
                  child: ListTile(
                    leading: Icon(
                      status == 'Accepted' ? Icons.check_circle : Icons.access_time,
                      color: status == 'Accepted' ? Colors.green : Colors.orange,
                      size: 32,
                    ),
                    title: Text('Status: $status', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text(status == 'Accepted' ? 'A worker has accepted your job!' : 'Waiting for workers...'),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
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
                ),
                const SizedBox(height: 16),
                if (status == 'Accepted' && data['workerId'] != null) ...[
                  const Text('Assigned Worker', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildWorkerDetails(context, data['workerId']),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => _markAsCompleted(context, jobId),
                    icon: const Icon(Icons.done_all),
                    label: const Text('Mark as Completed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
                if (status == 'Pending') ...[
                  const SizedBox(height: 32),
                  TextButton.icon(
                    onPressed: () => _cancelRequest(context, jobId),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text('Cancel Request', style: TextStyle(color: Colors.red)),
                  ),
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}