import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../models/analytics.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).loadAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Analytics'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final analytics = adminProvider.analytics;
          if (analytics == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No analytics data available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => adminProvider.loadAnalytics(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // System Overview
                  _buildSectionTitle('System Overview'),
                  Row(
                    children: [
                      Expanded(child: _buildMetricCard('Total Users', analytics.totalUsers.toString(), Icons.people, Colors.blue)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricCard('Total Labs', analytics.totalLabs.toString(), Icons.science, Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildMetricCard('Test Results', analytics.totalTestResults.toString(), Icons.assignment, Colors.orange)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricCard('Recent Activity', analytics.recentTestUploads.toString(), Icons.trending_up, Colors.purple)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // User Analytics
                  _buildSectionTitle('User Analytics'),
                  _buildProgressCard(
                    'User Activation Rate',
                    '${analytics.userActivationRate.toStringAsFixed(1)}%',
                    analytics.userActivationRate / 100,
                    Colors.green,
                    '${analytics.activeUsers} active of ${analytics.totalUsers} total',
                  ),
                  const SizedBox(height: 12),
                  _buildUserTypeBreakdown(analytics),
                  const SizedBox(height: 24),

                  // Lab Analytics
                  _buildSectionTitle('Lab Analytics'),
                  _buildProgressCard(
                    'Lab Approval Rate',
                    '${analytics.labApprovalRate.toStringAsFixed(1)}%',
                    analytics.labApprovalRate / 100,
                    Colors.blue,
                    '${analytics.activeLabs} approved of ${analytics.totalLabs} total',
                  ),
                  const SizedBox(height: 24),

                  // Test Results Analytics
                  _buildSectionTitle('Test Results Analytics'),
                  if (analytics.testResultsByStatus.isNotEmpty)
                    _buildStatusBreakdown(analytics),
                  const SizedBox(height: 12),
                  if (analytics.testResultsByLab.isNotEmpty)
                    _buildLabBreakdown(analytics),
                  const SizedBox(height: 24),

                  // Recent Activity
                  _buildSectionTitle('Recent Activity (30 days)'),
                  Row(
                    children: [
                      Expanded(child: _buildMetricCard('New Users', analytics.recentRegistrations.toString(), Icons.person_add, Colors.teal)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricCard('Test Uploads', analytics.recentTestUploads.toString(), Icons.upload, Colors.indigo)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(String title, String percentage, double progress, Color color, String subtitle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(percentage, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTypeBreakdown(SystemAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Users by Type', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...analytics.usersByType.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatUserType(entry.key)),
                  Text(entry.value.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBreakdown(SystemAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Test Results by Status', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...analytics.testResultsByStatus.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatStatus(entry.key)),
                  Text(entry.value.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildLabBreakdown(SystemAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Test Results by Lab (Anonymized)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...analytics.testResultsByLab.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key),
                  Text(entry.value.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  String _formatUserType(String type) {
    switch (type.toLowerCase()) {
      case 'patient':
        return 'Patients';
      case 'lab':
        return 'Lab Users';
      case 'caregiver':
        return 'Caregivers';
      case 'admin':
        return 'Admins';
      default:
        return type;
    }
  }

  String _formatStatus(String status) {
    return status.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1).toLowerCase()
    ).join(' ');
  }
}