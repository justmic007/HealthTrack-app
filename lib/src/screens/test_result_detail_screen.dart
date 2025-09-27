import 'package:flutter/material.dart';
import '../models/test_results.dart';
import '../utils/app_theme.dart';

class TestResultDetailScreen extends StatelessWidget {
  final TestResult testResult;

  const TestResultDetailScreen({
    super.key,
    required this.testResult,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Result Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share Test Result - Coming Soon!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _getTestTypeColor(testResult.title),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _getTestTypeIcon(testResult.title),
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            testResult.title,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.getStatusColor(testResult.status),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              testResult.status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Test Information
            _buildSectionTitle(context, 'Test Information'),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(context, 'Test Date', _formatDate(testResult.dateTaken)),
                    const Divider(),
                    _buildInfoRow(context, 'Upload Date', _formatDate(testResult.dateUploaded)),
                    const Divider(),
                    _buildInfoRow(context, 'Lab Provider', testResult.labName ?? 'Not specified'),
                    const Divider(),
                    _buildInfoRow(context, 'Patient', testResult.patientName ?? 'Not specified'),
                    const Divider(),
                    _buildInfoRow(context, 'Status', testResult.status),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Test Summary
            if (testResult.summaryText != null) ...[
              _buildSectionTitle(context, 'Summary'),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    testResult.summaryText!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Test File
            if (testResult.fileUrl != null) ...[
              _buildSectionTitle(context, 'Test File'),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.softPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  title: const Text('Test Result Document'),
                  subtitle: const Text('Tap to view or download'),
                  trailing: const Icon(Icons.download),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Download File - Coming Soon!')),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Actions
            _buildSectionTitle(context, 'Actions'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Share with Doctor - Coming Soon!')),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share with Doctor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lavenderAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Export PDF - Coming Soon!')),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Export PDF'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.darkGrey.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTestTypeColor(String testTitle) {
    if (testTitle.toLowerCase().contains('cholesterol')) return AppTheme.softPurple;
    if (testTitle.toLowerCase().contains('blood')) return AppTheme.softRed;
    if (testTitle.toLowerCase().contains('glucose')) return AppTheme.softOrange;
    return AppTheme.softGreen;
  }

  IconData _getTestTypeIcon(String testTitle) {
    if (testTitle.toLowerCase().contains('cholesterol')) return Icons.favorite;
    if (testTitle.toLowerCase().contains('blood')) return Icons.bloodtype;
    if (testTitle.toLowerCase().contains('glucose')) return Icons.local_hospital;
    return Icons.assignment;
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}