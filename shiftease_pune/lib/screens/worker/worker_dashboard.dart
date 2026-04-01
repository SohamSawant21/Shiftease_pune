import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/request.dart';
import '../../services/request_provider.dart';
import '../../utils/app_theme.dart';
import 'package:intl/intl.dart';

class WorkerDashboard extends StatelessWidget {
  const WorkerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Worker Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<RequestProvider>(
        builder: (context, provider, child) {
          final pendingJobs = provider.pendingRequests;
          final acceptedJobs = provider.acceptedRequests;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'Available Jobs',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.onSurface,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All Jobs', isActive: true),
                        _buildFilterChip('Koregaon Park'),
                        _buildFilterChip('Baner'),
                        _buildFilterChip('Kothrud'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Expanded(
                    child: ListView(
                      children: [
                        // ── Accepted / Active Jobs section ──────────────────
                        if (acceptedJobs.isNotEmpty) ...[
                          _buildSectionLabel('MY ACTIVE JOBS', AppTheme.primary),
                          const SizedBox(height: 12),
                          ...acceptedJobs.map(
                            (job) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildAcceptedJobCard(context, job),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],

                        // ── Pending / Available Jobs section ────────────────
                        if (pendingJobs.isEmpty && acceptedJobs.isEmpty)
                          _buildEmptyState()
                        else if (pendingJobs.isEmpty)
                          _buildNoMoreJobsChip()
                        else ...[
                          if (acceptedJobs.isNotEmpty) ...[
                            _buildSectionLabel('OPEN REQUESTS', AppTheme.onSurfaceVariant),
                            const SizedBox(height: 12),
                          ],
                          ...pendingJobs.map(
                            (job) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildJobCard(context, job),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionLabel(String label, Color color) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: color,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_off, size: 64, color: AppTheme.outlineVariant),
            const SizedBox(height: 16),
            const Text(
              'No available jobs at the moment.',
              style: TextStyle(color: AppTheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoMoreJobsChip() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainer,
            borderRadius: BorderRadius.circular(32),
          ),
          child: const Text(
            'No more open requests',
            style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primary : AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? AppTheme.onPrimary : AppTheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  // ── Pending job card ─────────────────────────────────────────────────────
  Widget _buildJobCard(BuildContext context, Request job) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.local_shipping, color: AppTheme.primary, size: 32),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: AppTheme.outline),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            job.location,
                            style: const TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: AppTheme.outline),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM dd, hh:mm a').format(job.dateTime),
                          style: const TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PAYMENT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: AppTheme.primary,
                    ),
                  ),
                  Text(
                    '₹${job.payment.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/job_details', arguments: job.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('View Job', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Accepted job card ────────────────────────────────────────────────────
  Widget _buildAcceptedJobCard(BuildContext context, Request job) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryContainer.withAlpha(40),
        borderRadius: BorderRadius.circular(16),
        border: const Border(left: BorderSide(color: AppTheme.primary, width: 4)),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, color: AppTheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  job.location,
                  style: const TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${job.payment.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primary,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Accepted',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
