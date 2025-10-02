import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sharing_provider.dart';
import '../models/shares.dart';

class MySharesScreen extends StatefulWidget {
  const MySharesScreen({Key? key}) : super(key: key);

  @override
  State<MySharesScreen> createState() => _MySharesScreenState();
}

class _MySharesScreenState extends State<MySharesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SharingProvider>().loadMyShares();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shared Results'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Consumer<SharingProvider>(
        builder: (context, sharingProvider, child) {
          if (sharingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (sharingProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${sharingProvider.errorMessage}',
                    style: TextStyle(color: Colors.red[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => sharingProvider.loadMyShares(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final shares = sharingProvider.myShares;

          if (shares.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.share_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No shared results',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You haven\'t shared any test results yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: shares.length,
            itemBuilder: (context, index) {
              final share = shares[index];
              return _buildShareCard(context, share, sharingProvider);
            },
          );
        },
      ),
    );
  }

  Widget _buildShareCard(BuildContext context, Share share, SharingProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    share.testResultTitle ?? 'Test Result',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showRevokeDialog(context, share, provider),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Shared with: ${share.caregiverName ?? 'Unknown'}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            if (share.caregiverLicenseType != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.medical_services, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${share.caregiverLicenseType} - ${share.caregiverLicenseNumber ?? 'N/A'}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  if (share.caregiverLicenseVerified == true) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.verified, size: 16, color: Colors.green),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Shared: ${_formatDate(share.dateShared)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRevokeDialog(BuildContext context, Share share, SharingProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Access'),
        content: Text(
          'Are you sure you want to stop sharing "${share.testResultTitle}" with ${share.caregiverName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await provider.revokeShare(share.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share revoked successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to revoke share: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }
}