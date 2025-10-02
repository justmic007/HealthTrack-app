import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../models/users.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).loadInactiveUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (adminProvider.inactiveUsers.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No inactive users',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => adminProvider.loadInactiveUsers(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: adminProvider.inactiveUsers.length,
              itemBuilder: (context, index) {
                final user = adminProvider.inactiveUsers[index];
                return _buildUserCard(user, adminProvider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserCard(User user, AdminProvider adminProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getUserTypeColor(user.userType),
                  child: Icon(
                    _getUserTypeIcon(user.userType),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getUserTypeColor(user.userType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getUserTypeDisplay(user.userType),
                    style: TextStyle(
                      color: _getUserTypeColor(user.userType),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // User details
            if (user.phoneNumber != null)
              _buildDetailRow('Phone', user.phoneNumber!),
            _buildDetailRow('Status', user.isActive ? 'Active' : 'Inactive'),
            _buildDetailRow('Registered', _formatDate(user.createdAt)),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showActivationDialog(user, adminProvider, true),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Activate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showActivationDialog(user, adminProvider, false),
                    icon: const Icon(Icons.block),
                    label: const Text('Keep Inactive'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Color _getUserTypeColor(String userType) {
    switch (userType.toLowerCase()) {
      case 'lab':
        return Colors.blue;
      case 'caregiver':
        return Colors.purple;
      case 'admin':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  IconData _getUserTypeIcon(String userType) {
    switch (userType.toLowerCase()) {
      case 'lab':
        return Icons.science;
      case 'caregiver':
        return Icons.medical_services;
      case 'admin':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  String _getUserTypeDisplay(String userType) {
    switch (userType.toLowerCase()) {
      case 'lab':
        return 'Lab User';
      case 'caregiver':
        return 'Caregiver';
      case 'admin':
        return 'Admin';
      default:
        return 'Patient';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showActivationDialog(User user, AdminProvider adminProvider, bool activate) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(activate ? 'Activate User' : 'Keep User Inactive'),
          content: Text(
            activate
                ? 'Are you sure you want to activate "${user.fullName}"? They will be able to access all features.'
                : 'Are you sure you want to keep "${user.fullName}" inactive? They will have limited access.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                final success = activate
                    ? await adminProvider.activateUser(user.id)
                    : await adminProvider.deactivateUser(user.id);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'User ${activate ? 'activated' : 'kept inactive'} successfully'
                            : 'Failed to update user status',
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: activate ? Colors.green : Colors.grey,
                foregroundColor: Colors.white,
              ),
              child: Text(activate ? 'Activate' : 'Confirm'),
            ),
          ],
        );
      },
    );
  }
}