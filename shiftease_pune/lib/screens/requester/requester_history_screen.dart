import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class RequesterHistoryScreen extends StatelessWidget {
  const RequesterHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Please log in.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job History'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('requesterId', isEqualTo: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No job history found.'));
          }

          var historyJobs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['status'] == 'Completed';
          }).toList();

          historyJobs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTime = aData['createdAt'] as Timestamp?;
            final bTime = bData['createdAt'] as Timestamp?;
            
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime);
          });

          if (historyJobs.isEmpty) {
            return const Center(child: Text('No completed jobs yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: historyJobs.length,
            itemBuilder: (context, index) {
              final doc = historyJobs[index];
              final data = doc.data() as Map<String, dynamic>;
              final DateTime dateTime = (data['dateTime'] as Timestamp).toDate();

              return Card(
                child: ListTile(
                  title: Text(data['title'] ?? 'No Title', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(DateFormat('MMM dd, yyyy').format(dateTime)),
                  trailing: const Chip(
                    label: Text('Completed', style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.green,
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/request_status',
                      arguments: doc.id,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}