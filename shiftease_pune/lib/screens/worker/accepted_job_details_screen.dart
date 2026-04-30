import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class AcceptedJobDetailsScreen extends StatelessWidget {
  const AcceptedJobDetailsScreen({super.key});

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

  Future<void> _dropJob(BuildContext context, String jobId) async {
    try {
      await FirebaseFirestore.instance.collection('requests').doc(jobId).update({
        'status': 'Pending',
        'workerId': FieldValue.delete(),
      });
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job dropped successfully.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error dropping job: $e')),
        );
      }
    }
  }

  void _confirmDropJob(BuildContext context, String jobId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Drop this job?'),
          content: const Text('Are you sure you want to decline this job? It will be made available to other workers again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('No, Keep It'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _dropJob(context, jobId);
              },
              child: const Text('Yes, Drop Job', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRequesterContactCard(BuildContext context, String requesterId) {
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
        final phone = userData['phone'] ?? 'No phone provided';

        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(userData['name'] ?? 'Requester'),
            subtitle: Text(phone),
            // NEW: The clickable phone icon
            trailing: IconButton(
              icon: const Icon(Icons.phone, color: Colors.green),
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
      appBar: AppBar(title: const Text('Accepted Job Details')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('requests').doc(jobId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Job not found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final dateTime = (data['dateTime'] as Timestamp).toDate();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['title'] ?? 'Job', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const Divider(),
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
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.payment),
                          title: Text('₹${data['payment']}'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Contact Requester', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildRequesterContactCard(context, data['requesterId']),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: () => _confirmDropJob(context, jobId),
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  label: const Text('Drop Job', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}