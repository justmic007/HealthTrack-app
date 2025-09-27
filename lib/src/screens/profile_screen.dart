import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _dataBackupEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit Profile - Coming Soon!')),
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Profile Avatar
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppTheme.lavenderAccent,
                          child: Text(
                            user?.fullName?.split(' ').map((name) => name[0]).take(2).join('') ?? 'U',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // User Name
                        Text(
                          user?.fullName ?? 'User Name',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        
                        // User Email
                        Text(
                          user?.email ?? 'user@example.com',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.darkGrey.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Member Since
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.softPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Member since ${_formatMemberSince(user?.createdAt)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.softPurple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Account Settings Card
                _buildSettingsCard(
                  context,
                  'Account Settings',
                  [
                    _buildSettingsTile(
                      context,
                      Icons.person_outline,
                      'Personal Information',
                      'Update your profile details',
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Personal Information - Coming Soon!')),
                        );
                      },
                    ),
                    _buildSettingsTile(
                      context,
                      Icons.security,
                      'Privacy & Security',
                      'Manage your privacy settings',
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Privacy & Security - Coming Soon!')),
                        );
                      },
                    ),
                    _buildSettingsTile(
                      context,
                      Icons.lock_outline,
                      'Change Password',
                      'Update your account password',
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Change Password - Coming Soon!')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // App Preferences Card
                _buildSettingsCard(
                  context,
                  'App Preferences',
                  [
                    _buildSwitchTile(
                      context,
                      Icons.notifications_outlined,
                      'Push Notifications',
                      'Receive health reminders and updates',
                      _notificationsEnabled,
                      (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                    ),
                    _buildSwitchTile(
                      context,
                      Icons.fingerprint,
                      'Biometric Login',
                      'Use fingerprint or face ID to login',
                      _biometricEnabled,
                      (value) {
                        setState(() {
                          _biometricEnabled = value;
                        });
                      },
                    ),
                    _buildSwitchTile(
                      context,
                      Icons.cloud_upload_outlined,
                      'Data Backup',
                      'Automatically backup your health data',
                      _dataBackupEnabled,
                      (value) {
                        setState(() {
                          _dataBackupEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Health Data Card
                _buildSettingsCard(
                  context,
                  'Health Data',
                  [
                    _buildSettingsTile(
                      context,
                      Icons.file_download_outlined,
                      'Export Data',
                      'Download your health records',
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Export Data - Coming Soon!')),
                        );
                      },
                    ),
                    _buildSettingsTile(
                      context,
                      Icons.share_outlined,
                      'Share with Doctor',
                      'Share your data with healthcare providers',
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Share with Doctor - Coming Soon!')),
                        );
                      },
                    ),
                    _buildSettingsTile(
                      context,
                      Icons.delete_outline,
                      'Delete Health Data',
                      'Permanently remove your health records',
                      () {
                        _showDeleteDataDialog(context);
                      },
                      isDestructive: true,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Support Card
                _buildSettingsCard(
                  context,
                  'Support',
                  [
                    _buildSettingsTile(
                      context,
                      Icons.help_outline,
                      'Help Center',
                      'Get help and support',
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Help Center - Coming Soon!')),
                        );
                      },
                    ),
                    _buildSettingsTile(
                      context,
                      Icons.feedback_outlined,
                      'Send Feedback',
                      'Help us improve the app',
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Send Feedback - Coming Soon!')),
                        );
                      },
                    ),
                    _buildSettingsTile(
                      context,
                      Icons.info_outline,
                      'About',
                      'App version and information',
                      () {
                        _showAboutDialog(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showLogoutDialog(context, authProvider),
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.softRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

  Widget _buildSettingsTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppTheme.softRed : AppTheme.lavenderAccent,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppTheme.softRed : null,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.lavenderAccent,
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.lavenderAccent,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await authProvider.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.softRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Health Data'),
        content: const Text(
          'This will permanently delete all your health records. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delete Health Data - Coming Soon!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.softRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'HealthTrack',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppTheme.lavenderAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.health_and_safety,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: [
        const Text('A comprehensive health tracking application to manage your medical records and wellness data.'),
      ],
    );
  }

  String _formatMemberSince(DateTime? createdAt) {
    if (createdAt == null) return 'Recently';
    final now = DateTime.now();
    final difference = now.difference(createdAt).inDays;
    
    if (difference < 30) {
      return 'Recently';
    } else if (difference < 365) {
      final months = (difference / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }
}