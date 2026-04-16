import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/request_provider.dart';
import '../../models/request.dart';
import 'package:intl/intl.dart';

class JobDetailsScreen extends StatelessWidget {
  const JobDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String jobId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
      ),
      body: Consumer<RequestProvider>(
        builder: (context, provider, child) {
          final allJobs = [...provider.pendingRequests, ...provider.acceptedRequests];
          
          final jobIndex = allJobs.indexWhere((j) => j.id == jobId);
          if (jobIndex == -1) {
            return const Center(child: Text('Job not found.'));
          }
          final job = allJobs[jobIndex];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Job Request: ${job.name}',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Payment: ₹${job.payment.toStringAsFixed(0)}', 
                          style: const TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Duration: ${job.duration} Hours'),
                        Text('Helpers Needed: ${job.helpers}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.person, size: 40, color: Colors.blue),
                    title: const Text('Customer Info', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Name: ${job.name}\nPhone: ${job.phone}'),
                    isThreeLine: true,
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  elevation: 2,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Date & Time'),
                        subtitle: Text(DateFormat('dd MMM yyyy • hh:mm a').format(job.dateTime)),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.location_on),
                        title: const Text('Location'),
                        subtitle: Text(job.location),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                if (job.status == 'Pending') 
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Decline simply pops the screen without accepting
                            Navigator.pop(context);
                          },
                          child: const Text('Decline'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            provider.updateRequestStatus(job.id, 'Accepted');
                            Navigator.pop(context);
                          },
                          child: const Text('Accept Job'),
                        ),
                      ),
                    ],
                  )
                else
                   SizedBox(
                     width: double.infinity,
                     child: ElevatedButton(
                       onPressed: () => Navigator.pop(context),
                       child: const Text('Go Back'),
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