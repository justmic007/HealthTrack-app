import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/test_results_provider.dart';
import '../models/test_results.dart';
import '../utils/app_theme.dart';
import 'test_result_detail_screen.dart';

class TestResultsListScreen extends StatefulWidget {
  const TestResultsListScreen({super.key});

  @override
  State<TestResultsListScreen> createState() => _TestResultsListScreenState();
}

class _TestResultsListScreenState extends State<TestResultsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'All';
  
  final List<String> _statusOptions = ['All', 'Normal', 'Abnormal', 'Borderline', 'Pending'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TestResultsProvider>(context, listen: false).loadTestResults();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Results'),
        backgroundColor: AppTheme.lavenderAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search test results...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),

          // Filter Chips
          if (_selectedStatus != 'All')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Chip(
                    label: Text(_selectedStatus),
                    onDeleted: () => setState(() => _selectedStatus = 'All'),
                    backgroundColor: AppTheme.getStatusColor(_selectedStatus.toLowerCase()),
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

          // Test Results List
          Expanded(
            child: Consumer<TestResultsProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${provider.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.loadTestResults(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredResults = _filterTestResults(provider.testResults);

                if (filteredResults.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.assignment, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || _selectedStatus != 'All'
                              ? 'No test results match your filters'
                              : 'No test results found',
                          style: const TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        if (_searchQuery.isNotEmpty || _selectedStatus != 'All')
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _selectedStatus = 'All';
                              });
                            },
                            child: const Text('Clear Filters'),
                          ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadTestResults(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filteredResults.length,
                    itemBuilder: (context, index) {
                      final testResult = filteredResults[index];
                      return _buildTestResultCard(testResult);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<TestResult> _filterTestResults(List<TestResult> results) {
    return results.where((result) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final matchesSearch = result.title.toLowerCase().contains(_searchQuery) ||
            (result.labName?.toLowerCase().contains(_searchQuery) ?? false) ||
            (result.summaryText?.toLowerCase().contains(_searchQuery) ?? false);
        if (!matchesSearch) return false;
      }

      // Status filter
      if (_selectedStatus != 'All') {
        if (result.status.toLowerCase() != _selectedStatus.toLowerCase()) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Widget _buildTestResultCard(TestResult testResult) {
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Results'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _statusOptions.map((status) {
                  return FilterChip(
                    label: Text(status),
                    selected: _selectedStatus == status,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = selected ? status : 'All';
                      });
                      Navigator.of(context).pop();
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => _selectedStatus = 'All');
                Navigator.of(context).pop();
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}