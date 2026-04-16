import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/request_provider.dart';

class RequestStatusScreen extends StatelessWidget {
  const RequestStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String jobId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Status'),
      ),
      body: Consumer<RequestProvider>(
        builder: (context, provider, child) {
          final requests = provider.requests;
          final requestIndex = requests.indexWhere((r) => r.id == jobId);

          if (requestIndex == -1) {
            return const Center(child: Text('Request not found.'));
          }

          final request = requests[requestIndex];
          
          bool isAccepted = request.status == 'Accepted';
          bool isCancelled = request.status == 'Cancelled';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Standard Header
                const Text(
                  'Request Status',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tracking your relocation journey through the heart of Pune.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),

                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CURRENT PHASE',
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              isCancelled ? Icons.cancel : Icons.circle,
                              color: isCancelled ? Colors.red : Colors.blue,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              request.status,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            const Icon(Icons.local_shipping, color: Colors.blue, size: 32),
                          ],
                        ),
                        const Divider(height: 32),
                        Text('Request ID:  ${request.id}'),
                        const SizedBox(height: 8),
                        const Text('Service Type:  Shifting'),
                        const SizedBox(height: 16),
                        const Text(
                          '"A professional is assigned to your request"',
                          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Activity Timeline',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.check_circle, color: Colors.blue),
                        title: const Text('Request Submitted', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Waiting for worker...'),
                      ),
                      ListTile(
                        leading: Icon(
                          isAccepted ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: isAccepted ? Colors.blue : Colors.grey.shade400,
                        ),
                        title: const Text('Worker Assigned', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Awaiting professional confirmation'),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                if (!isCancelled)
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        provider.updateRequestStatus(request.id, 'Cancelled');
                      },
                      child: const Text(
                        'Cancel Request',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
}