import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test Information Card
            _buildSectionCard(
              context,
              'Test Information',
              [
                _buildInfoRowWithIcon(context, Icons.assignment, 'Test Name', testResult.title),
                _buildInfoRowWithIcon(context, Icons.calendar_today, 'Date', _formatDate(testResult.dateTaken)),
                _buildInfoRowWithIcon(context, Icons.local_hospital, 'Provider', testResult.labName ?? 'HealthCare Labs'),
                _buildInfoRowWithIcon(context, Icons.science, 'Test Type', testResult.testType ?? 'Diagnostic'),
                _buildInfoRowWithIcon(context, Icons.person, 'Patient Name', testResult.patientName ?? 'Not specified'),
                if (testResult.uploaderName != null)
                  _buildInfoRowWithIcon(context, Icons.upload, 'Uploaded By', testResult.uploaderName!),
              ],
            ),
            const SizedBox(height: 24),

            // Summary & Status Card
            _buildSectionCard(
              context,
              'Summary & Status',
              [
                // Summary Text
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    testResult.summaryText ?? 'Test results show normal values within expected ranges. All key indicators are functioning properly with no immediate concerns detected.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                
                // Overall Wellness Score
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Wellness Score',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: (testResult.wellnessScore ?? 95) / 100,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getWellnessColor(testResult.wellnessScore ?? 95),
                            ),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${testResult.wellnessScore ?? 95}%',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getWellnessColor(testResult.wellnessScore ?? 95),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Status Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.getStatusColor(testResult.status),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '${testResult.status} Result',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Additional Notes Card
            _buildSectionCard(
              context,
              'Additional Notes',
              [
                Text(
                  testResult.additionalNotes ?? 'Continue maintaining a healthy lifestyle. Schedule regular check-ups as recommended by your healthcare provider. Contact your doctor if you experience any unusual symptoms.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Column(
              children: [
                // Download File Button (if file exists)
                if (testResult.fileUrl != null) ..[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _downloadFile(context, testResult.fileUrl!),
                      icon: const Icon(Icons.download),
                      label: const Text('Download Test Result File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Share Result Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Share Result - Coming Soon!')),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share Result'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Set Reminder Button (Primary)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Set Reminder - Coming Soon!')),
                      );
                    },
                    icon: const Icon(Icons.notifications),
                    label: const Text('Set Reminder'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lavenderAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Return to Dashboard Button
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Return to Dashboard'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGrey,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRowWithIcon(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppTheme.lavenderAccent,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getWellnessColor(int score) {
    if (score >= 90) return AppTheme.softGreen;
    if (score >= 70) return AppTheme.softOrange;
    return AppTheme.softRed;
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

  Future<void> _downloadFile(BuildContext context, String fileUrl) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Downloading file...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Launch the file URL - this will open in browser or download
      final Uri uri = Uri.parse(fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to download file'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}