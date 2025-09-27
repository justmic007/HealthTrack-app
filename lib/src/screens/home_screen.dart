import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../models/test_results.dart';
import '../models/reminders.dart';
import '../data/api_client.dart';
import '../utils/app_theme.dart';

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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppTheme.softPink,
                          child: Text(
                            user?.fullName?.split(' ').map((name) => name[0]).take(2).join('') ?? 'U',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                user?.fullName ?? 'User',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (user?.email != null)
                                Text(
                                  user!.email,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
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

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildActionCard(
                      context,
                      'Test Results',
                      Icons.assignment,
                      AppTheme.softGreen,
                      () => _navigateToTestResults(context),
                    ),
                    _buildActionCard(
                      context,
                      'Reminders',
                      Icons.alarm,
                      AppTheme.softOrange,
                      () => _navigateToReminders(context),
                    ),
                    _buildActionCard(
                      context,
                      'Share Results',
                      Icons.share,
                      AppTheme.softPurple,
                      () => _navigateToSharing(context),
                    ),
                    _buildActionCard(
                      context,
                      'Profile',
                      Icons.person,
                      AppTheme.lavenderAccent,
                      () => _navigateToProfile(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Recent Test Results
                Text(
                  'Recent Test Results',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                _isLoadingData
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
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.getStatusColor(test.status),
                                  child: const Icon(Icons.assignment, color: Colors.white, size: 20),
                                ),
                                title: Text(test.title),
                                subtitle: Text('${test.labName ?? 'Lab'} • ${_formatDate(test.dateTaken)}'),
                                trailing: Chip(
                                  label: Text(test.status, style: const TextStyle(fontSize: 12)),
                                  backgroundColor: AppTheme.getStatusColor(test.status).withOpacity(0.2),
                                ),
                              ),
                            )).toList(),
                          ),
                const SizedBox(height: 24),

                // Upcoming Reminders
                Text(
                  'Upcoming Reminders',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                _upcomingReminders.isEmpty
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
              ],
            ),
          );
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

  // Removed - now using AppTheme.getStatusColor()

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