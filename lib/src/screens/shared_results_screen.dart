import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sharing_provider.dart';
import '../models/test_results.dart';
import '../utils/app_theme.dart';
import 'test_result_detail_screen.dart';

class SharedResultsScreen extends StatefulWidget {
  const SharedResultsScreen({super.key});

  @override
  State<SharedResultsScreen> createState() => _SharedResultsScreenState();
}

class _SharedResultsScreenState extends State<SharedResultsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SharingProvider>(context, listen: false).loadSharedResults();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Results'),
        backgroundColor: AppTheme.lavenderAccent,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SharingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${provider.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadSharedResults(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final sharedResults = provider.sharedResults;

          if (sharedResults.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.share, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No shared results',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Patients haven\'t shared any test results with you yet.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadSharedResults(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: sharedResults.length,
              itemBuilder: (context, index) {
                final testResult = sharedResults[index];
                return _buildSharedResultCard(testResult);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSharedResultCard(TestResult testResult) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TestResultDetailScreen(testResult: testResult),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Test Type Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getTestTypeColor(testResult.title),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getTestTypeIcon(testResult.title),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Test Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          testResult.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(testResult.dateTaken),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        if (testResult.labName != null)
                          Text(
                            testResult.labName!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.getStatusColor(testResult.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      testResult.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Patient Info
              if (testResult.patientName != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person, color: Colors.blue[600], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Patient: ${testResult.patientName}',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Summary (if available)
              if (testResult.summaryText?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Text(
                  testResult.summaryText!,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // File attachment indicator
              if (testResult.fileUrl != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.attach_file, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'File attached',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
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
    return '${date.day}/${date.month}/${date.year}';
  }
  
  String _formatProfessionalName(String name, String? licenseType, bool? verified) {
    if (licenseType == null) return name;
    
    String credentials = '$name, $licenseType';
    if (verified == true) {
      credentials += ' ✓';
    }
    return credentials;
  }
}