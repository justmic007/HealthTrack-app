import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../models/labs.dart';

class LabManagementScreen extends StatefulWidget {
  const LabManagementScreen({super.key});

  @override
  State<LabManagementScreen> createState() => _LabManagementScreenState();
}

class _LabManagementScreenState extends State<LabManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).loadPendingLabs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Management'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (adminProvider.pendingLabs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.science, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No pending lab registrations',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => adminProvider.loadPendingLabs(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: adminProvider.pendingLabs.length,
              itemBuilder: (context, index) {
                final lab = adminProvider.pendingLabs[index];
                return _buildLabCard(lab, adminProvider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabCard(Lab lab, AdminProvider adminProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lab header
            Row(
              children: [
                Icon(Icons.science, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    lab.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    lab.statusDisplay,
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Lab details
            _buildDetailRow('CLIA Number', lab.cliaNumber),
            _buildDetailRow('Phone', lab.phoneNumber),
            _buildDetailRow('Address', '${lab.address}, ${lab.city}, ${lab.state} ${lab.zipCode}'),
            _buildDetailRow('Registered', _formatDate(lab.createdAt)),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showApprovalDialog(lab, adminProvider, true),
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showApprovalDialog(lab, adminProvider, false),
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
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
            width: 100,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showApprovalDialog(Lab lab, AdminProvider adminProvider, bool approve) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(approve ? 'Approve Lab' : 'Reject Lab'),
          content: Text(
            approve
                ? 'Are you sure you want to approve "${lab.name}"? This will allow them to upload test results.'
                : 'Are you sure you want to reject "${lab.name}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                final success = approve
                    ? await adminProvider.approveLab(lab.id)
                    : await adminProvider.rejectLab(lab.id);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Lab ${approve ? 'approved' : 'rejected'} successfully'
                            : 'Failed to ${approve ? 'approve' : 'reject'} lab',
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: approve ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(approve ? 'Approve' : 'Reject'),
            ),
          ],
        );
      },
    );
  }
}