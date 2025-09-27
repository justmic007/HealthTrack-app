import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/test_results_provider.dart';
import '../utils/app_theme.dart';
import '../models/test_results.dart';
import 'test_result_detail_screen.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  @override
  void initState() {
    super.initState();
    // Load test results when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TestResultsProvider>().loadTestResults();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Upload Test Result - Coming Soon!')),
              );
            },
          ),
        ],
      ),
      body: Consumer<TestResultsProvider>(
        builder: (context, testResultsProvider, child) {
          if (testResultsProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (testResultsProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading test results',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    testResultsProvider.errorMessage!,
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => testResultsProvider.refreshTestResults(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final testResults = testResultsProvider.testResults;

          if (testResults.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.assignment,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Test Results',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Upload your first test result to get started',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Upload Test Result - Coming Soon!')),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Upload Test Result'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: testResultsProvider.refreshTestResults,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: testResults.length,
              itemBuilder: (context, index) {
                final testResult = testResults[index];
                return _buildTestResultCard(context, testResult);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTestResultCard(BuildContext context, TestResult testResult) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TestResultDetailScreen(testResult: testResult),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Test Type Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getTestTypeColor(testResult.title),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTestTypeIcon(testResult.title),
                  color: Colors.white,
                  size: 28,
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
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(testResult.dateTaken),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.darkGrey.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      testResult.labName ?? 'Lab Provider',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.darkGrey.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // Status and Arrow
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
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
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ],
              ),
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
}