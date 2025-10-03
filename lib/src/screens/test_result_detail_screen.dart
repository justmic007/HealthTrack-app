import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/test_results.dart';
import '../utils/app_theme.dart';
import '../providers/auth_provider.dart';
import 'share_test_result_screen.dart';
import 'create_reminder_screen.dart';

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
                if (testResult.fileUrl != null) ...[
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
                
                // Share Result Button (only for patients)
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final user = authProvider.currentUser;
                    if (user?.userType == 'patient') {
                      return SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ShareTestResultScreen(
                                  testResult: testResult,
                                ),
                              ),
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
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final user = authProvider.currentUser;
                    if (user?.userType == 'patient') {
                      return const SizedBox(height: 12);
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 12),
                
                // Set Reminder Button (Primary)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CreateReminderScreen(
                            testResult: testResult,
                          ),
                        ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.lavenderAccent,
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppTheme.lavenderAccent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getWellnessColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Future<void> _downloadFile(BuildContext context, String fileUrl) async {
    try {
      print('Original file URL: $fileUrl');
      
      // Construct full URL if it's a relative path
      String fullUrl = fileUrl;
      if (!fileUrl.startsWith('http')) {
        // Use platform-specific IP addresses
        if (Platform.isAndroid) {
          fullUrl = 'http://10.0.2.2:8000$fileUrl';
        } else {
          // For iOS simulator, use localhost
          fullUrl = 'http://localhost:8000$fileUrl';
        }
      }
      
      print('Full file URL: $fullUrl');
      
      final Uri url = Uri.parse(fullUrl);
      print('Parsed URI: $url');
      
      // Show loading indicator
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening file in browser...'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      final canLaunch = await canLaunchUrl(url);
      print('Can launch URL: $canLaunch');
      
      if (canLaunch) {
        await launchUrl(url, mode: LaunchMode.inAppWebView);
      } else {
        // Try alternative launch modes
        try {
          await launchUrl(url, mode: LaunchMode.inAppWebView);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File opened successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (e2) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File download not available in emulator. Try on a real device.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Download error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading file: $e')),
        );
      }
    }
  }
}