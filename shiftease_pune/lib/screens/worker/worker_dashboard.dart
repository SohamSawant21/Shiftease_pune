import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class WorkerDashboard extends StatelessWidget {
  const WorkerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Dashboard'),
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
      body: currentUser == null
          ? const Center(child: Text('Please log in.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('requests').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                   return _buildEmptyState();
                }

                final allDocs = snapshot.data!.docs;

                final pendingJobs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['status'] == 'Pending' && data['requesterId'] != currentUser.uid;
                }).toList();

                final acceptedJobs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['status'] == 'Accepted' && data['workerId'] == currentUser.uid;
                }).toList();

                if (pendingJobs.isEmpty && acceptedJobs.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    if (acceptedJobs.isNotEmpty) ...[
                      const Text('My Accepted Jobs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ...acceptedJobs.map((doc) => _buildBasicAcceptedJobCard(context, doc)),
                      const SizedBox(height: 24),
                    ],
                    if (pendingJobs.isNotEmpty) ...[
                      const Text('Available Jobs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ...pendingJobs.map((doc) => _buildBasicJobCard(context, doc)),
                    ],
                  ],
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.work_off_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No available jobs at the moment.', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildBasicJobCard(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final DateTime dateTime = (data['dateTime'] as Timestamp).toDate();
    final double payment = (data['payment'] as num).toDouble();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['title'] ?? 'Job',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(data['location'] ?? '')),
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
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${payment.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Pass the Firebase Document ID to the details screen
                    Navigator.pushNamed(context, '/job_details', arguments: doc.id);
                  },
                  child: const Text('View Job'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicAcceptedJobCard(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final double payment = (data['payment'] as num).toDouble();

    return Card(
      color: Colors.green.shade50,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green, size: 40),
        title: Text(data['title'] ?? 'Job', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${data['location']}\n₹${payment.toStringAsFixed(0)}'),
        isThreeLine: true,
        trailing: const Chip(
          label: Text('Accepted', style: TextStyle(color: Colors.white, fontSize: 12)),
          backgroundColor: Colors.green,
          side: BorderSide.none,
        ),
        onTap: () {
          Navigator.pushNamed(context, '/accepted_job_details', arguments: doc.id);
        },
      ),
    );
  }
}