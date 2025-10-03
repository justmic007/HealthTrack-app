import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';
import '../models/reminders.dart';
import '../utils/app_theme.dart';
import 'create_reminder_screen.dart';

class RemindersListScreen extends StatefulWidget {
  const RemindersListScreen({super.key});

  @override
  State<RemindersListScreen> createState() => _RemindersListScreenState();
}

class _RemindersListScreenState extends State<RemindersListScreen> {
  bool _showCompleted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReminderProvider>().loadReminders(includeCompleted: _showCompleted);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reminders'),
        backgroundColor: AppTheme.lavenderAccent,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'toggle_completed') {
                setState(() {
                  _showCompleted = !_showCompleted;
                });
                context.read<ReminderProvider>().loadReminders(includeCompleted: _showCompleted);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_completed',
                child: Row(
                  children: [
                    Icon(_showCompleted ? Icons.visibility_off : Icons.visibility),
                    const SizedBox(width: 8),
                    Text(_showCompleted ? 'Hide Completed' : 'Show Completed'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<ReminderProvider>(
        builder: (context, reminderProvider, child) {
          if (reminderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (reminderProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading reminders',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reminderProvider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => reminderProvider.loadReminders(includeCompleted: _showCompleted),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final reminders = reminderProvider.reminders;

          if (reminders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.alarm, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No reminders yet',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create your first reminder to get started',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToCreateReminder(),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Reminder'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => reminderProvider.loadReminders(includeCompleted: _showCompleted),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                return _buildReminderCard(context, reminder);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateReminder,
        backgroundColor: AppTheme.lavenderAccent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, Reminder reminder) {
    final isOverdue = reminder.dueDateTime.isBefore(DateTime.now()) && !reminder.isCompleted;
    final reminderColor = _getReminderColor(reminder.reminderType);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: reminder.isCompleted 
              ? Colors.grey 
              : (isOverdue ? AppTheme.softRed : reminderColor),
          child: Icon(
            _getReminderIcon(reminder.reminderType),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          reminder.title,
          style: TextStyle(
            decoration: reminder.isCompleted ? TextDecoration.lineThrough : null,
            color: reminder.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reminder.description != null && reminder.description!.isNotEmpty)
              Text(reminder.description!),
            const SizedBox(height: 4),
            Text(
              _formatDateTime(reminder.dueDateTime),
              style: TextStyle(
                color: isOverdue ? AppTheme.softRed : AppTheme.darkGrey.withOpacity(0.7),
                fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (reminder.recurrenceType != 'none')
              Text(
                'Repeats ${reminder.recurrenceType}',
                style: TextStyle(
                  color: AppTheme.darkGrey.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: reminder.isCompleted
            ? const Icon(Icons.check_circle, color: Colors.green)
            : PopupMenuButton<String>(
                onSelected: (value) => _handleReminderAction(context, reminder, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'complete',
                    child: Row(
                      children: [
                        Icon(Icons.check),
                        SizedBox(width: 8),
                        Text('Mark Complete'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _handleReminderAction(BuildContext context, Reminder reminder, String action) async {
    final reminderProvider = context.read<ReminderProvider>();

    try {
      switch (action) {
        case 'complete':
          await reminderProvider.markCompleted(reminder.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reminder marked as complete')),
            );
          }
          break;
        case 'edit':
          // TODO: Navigate to edit screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Edit functionality - Coming Soon!')),
          );
          break;
        case 'delete':
          final confirmed = await _showDeleteConfirmation(context);
          if (confirmed == true) {
            await reminderProvider.deleteReminder(reminder.id);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reminder deleted')),
              );
            }
          }
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: const Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _navigateToCreateReminder() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateReminderScreen(),
      ),
    );
  }

  Color _getReminderColor(String type) {
    switch (type.toLowerCase()) {
      case 'medication':
        return AppTheme.softPink;
      case 'follow_up':
        return AppTheme.softOrange;
      case 'custom':
        return AppTheme.softPurple;
      default:
        return AppTheme.lavender;
    }
  }

  IconData _getReminderIcon(String type) {
    switch (type.toLowerCase()) {
      case 'medication':
        return Icons.medication;
      case 'follow_up':
        return Icons.assignment;
      case 'custom':
        return Icons.alarm;
      default:
        return Icons.notifications;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.inDays == 0) {
      if (dateTime.isBefore(now)) {
        return 'Overdue - ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else {
        return 'Today ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
      }
    } else if (difference.inDays == 1) {
      return 'Tomorrow ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == -1) {
      return 'Yesterday ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}