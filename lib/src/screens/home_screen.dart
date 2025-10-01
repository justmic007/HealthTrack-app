import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../models/test_results.dart';
import '../models/reminders.dart';
import '../data/api_client.dart';
import '../utils/app_theme.dart';
import 'upload_test_result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiClient _apiClient = ApiClient();
  List<TestResult> _recentTests = [];
  List<Reminder> _upcomingReminders = [];
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoadingData = true);
    
    try {
      // Load recent test results (last 3)
      final tests = await _apiClient.getTestResults();
      _recentTests = tests.take(3).toList();
      
      // Load upcoming reminders (next 3)
      final reminders = await _apiClient.getReminders();
      _upcomingReminders = reminders
          .where((r) => r.isActive && !r.isCompleted && r.dueDateTime.isAfter(DateTime.now()))
          .take(3)
          .toList();
    } catch (e) {
      // Handle errors silently for dashboard
    }
    
    setState(() => _isLoadingData = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthTrack - Dashboard'),
        backgroundColor: AppTheme.lavenderAccent,
        foregroundColor: Colors.white,
        actions: [
          // Notification Bell
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications - Coming Soon!')),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppTheme.softRed,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          // Profile Avatar
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final user = authProvider.currentUser;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.softPink,
                  child: Text(
                    user?.fullName?.split(' ').map((name) => name[0]).take(2).join('') ?? 'U',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
          // Logout Menu
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search tests or conditions...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Search functionality - Coming Soon!')),
                      );
                    },
                  ),
                ),

                // Welcome Section with Date
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome ${user?.fullName?.split(' ').first ?? 'User'}!',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkGrey,
                        ),
                      ),
                      Text(
                        _getCurrentDate(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.darkGrey.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Your Health Snapshot
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Your Health Snapshot',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSnapshotCard(
                          context,
                          'Active Alerts',
                          Icons.warning_amber,
                          '2',
                          'Requires attention',
                          AppTheme.softRed,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSnapshotCard(
                          context,
                          'Appointments',
                          Icons.calendar_today,
                          '3',
                          'Upcoming next week',
                          AppTheme.softPurple,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),



                // Your Recent Test Results
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Your Recent Test Results',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _isLoadingData
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        )
                      : _recentTests.isEmpty
                          ? Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    const Icon(Icons.assignment, size: 48, color: Colors.grey),
                                    const SizedBox(height: 8),
                                    Text('No test results yet', style: Theme.of(context).textTheme.bodyLarge),
                                    Text('Upload your first test result to get started', 
                                         style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                                         textAlign: TextAlign.center),
                                  ],
                                ),
                              ),
                            )
                          : Column(
                              children: _recentTests.map((test) => Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      // Test Type Icon
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: _getTestTypeColor(test.title),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          _getTestTypeIcon(test.title),
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
                                              test.title,
                                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _formatDate(test.dateTaken),
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: AppTheme.darkGrey.withOpacity(0.7),
                                              ),
                                            ),
                                            Text(
                                              test.labName ?? 'Lab Provider',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: AppTheme.darkGrey.withOpacity(0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Status and Result
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppTheme.getStatusColor(test.status),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              test.status,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _getResultValue(test.status),
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.getStatusColor(test.status),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )).toList(),
                            ),
                ),
                const SizedBox(height: 24),

                // Upcoming Reminders
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Upcoming Reminders',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _upcomingReminders.isEmpty
                      ? Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const Icon(Icons.alarm, size: 48, color: Colors.grey),
                                const SizedBox(height: 8),
                                Text('No upcoming reminders', style: Theme.of(context).textTheme.bodyLarge),
                                Text('Set reminders for medications or appointments', 
                                     style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                                     textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          children: _upcomingReminders.map((reminder) => Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.getReminderTypeColor(reminder.reminderType),
                                child: Icon(_getReminderIcon(reminder.reminderType), color: Colors.white, size: 20),
                              ),
                              title: Text(reminder.title),
                              subtitle: Text('${reminder.description ?? ''} • ${_formatDateTime(reminder.dueDateTime)}'),
                              trailing: const Icon(Icons.chevron_right),
                            ),
                          )).toList(),
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          
          // Only show upload button for active lab users
          if (user?.userType == 'lab' && user?.isActive == true) {
            return FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const UploadTestResultScreen(),
                  ),
                );
              },
              backgroundColor: AppTheme.lavenderAccent,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Test'),
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToTestResults(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test Results - Coming Soon!')),
    );
  }

  void _navigateToReminders(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reminders - Coming Soon!')),
    );
  }

  void _navigateToSharing(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share Results - Coming Soon!')),
    );
  }

  void _navigateToProfile(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile - Coming Soon!')),
    );
  }

  // Helper methods for enhanced dashboard
  String _getCurrentDate() {
    final now = DateTime.now();
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
                   'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  Widget _buildSnapshotCard(
    BuildContext context,
    String title,
    IconData icon,
    String count,
    String subtitle,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  count,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.darkGrey.withOpacity(0.7),
              ),
            ),
          ],
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

  String _getResultValue(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'reviewed':
        return 'Normal';
      case 'pending':
        return 'Pending';
      case 'failed':
      case 'needs attention':
        return 'High';
      default:
        return 'Borderline';
    }
  }

  IconData _getReminderIcon(String type) {
    switch (type.toLowerCase()) {
      case 'medication':
        return Icons.medication;
      case 'appointment':
        return Icons.calendar_today;
      case 'test':
        return Icons.assignment;
      default:
        return Icons.alarm;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now).inDays;
    
    if (difference == 0) {
      return 'Today ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference == 1) {
      return 'Tomorrow ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}