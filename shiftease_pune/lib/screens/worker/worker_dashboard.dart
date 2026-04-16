import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/request.dart';
import '../../services/request_provider.dart';
import 'package:intl/intl.dart';

class WorkerDashboard extends StatelessWidget {
  // Ensures this can be called with 'const' in your routes map
  const WorkerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Dashboard'),
      ),
      // Consumer ensures the data connections remain intact
      body: Consumer<RequestProvider>(
        builder: (context, provider, child) {
          final pendingJobs = provider.pendingRequests;
          final acceptedJobs = provider.acceptedRequests;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Available Jobs',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Simplified to only show 'All Jobs'
                const Chip(
                  label: Text('All Jobs'),
                  backgroundColor: Colors.blue,
                  labelStyle: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),

                // Expanded ListView handles the scrolling and dynamic lists
                Expanded(
                  child: ListView(
                    children: [
                      // --- ACCEPTED JOBS SECTION ---
                      if (acceptedJobs.isNotEmpty) ...[
                        const Text(
                          'MY ACTIVE JOBS',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        ...acceptedJobs.map((job) => _buildBasicAcceptedJobCard(context, job)),
                        const SizedBox(height: 16),
                      ],

                      // --- PENDING JOBS SECTION ---
                      if (pendingJobs.isNotEmpty) ...[
                        const Text(
                          'OPEN REQUESTS',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        ...pendingJobs.map((job) => _buildBasicJobCard(context, job)),
                      ],

                      // --- EMPTY STATE ---
                      if (pendingJobs.isEmpty && acceptedJobs.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 40.0),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.work_off_outlined,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No available jobs at the moment.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // A very basic, standard Card layout for pending jobs
  Widget _buildBasicJobCard(BuildContext context, Request job) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(job.location)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(DateFormat('MMM dd, hh:mm a').format(job.dateTime)),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${job.payment.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Feature intact: navigates to details passing the job ID
                    Navigator.pushNamed(context, '/job_details', arguments: job.id);
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

  // A very basic ListTile layout for accepted jobs
  Widget _buildBasicAcceptedJobCard(BuildContext context, Request job) {
    return Card(
      color: Colors.green.shade50, // Subtle green tint to show it's active
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green, size: 40),
        title: Text(job.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${job.location}\n₹${job.payment.toStringAsFixed(0)}'),
        isThreeLine: true,
        trailing: const Chip(
          label: Text('Accepted', style: TextStyle(color: Colors.white, fontSize: 12)),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }
}