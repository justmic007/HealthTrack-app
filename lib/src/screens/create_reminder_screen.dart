import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';
import '../models/reminders.dart';
import '../models/test_results.dart';
import '../utils/app_theme.dart';

class CreateReminderScreen extends StatefulWidget {
  final TestResult? testResult;
  
  const CreateReminderScreen({super.key, this.testResult});

  @override
  State<CreateReminderScreen> createState() => _CreateReminderScreenState();
}

class _CreateReminderScreenState extends State<CreateReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedType = 'medication';
  String _selectedRecurrence = 'none';
  DateTime _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
  bool _isLoading = false;

  final List<Map<String, dynamic>> _reminderTypes = [
    {'value': 'medication', 'label': 'Medication', 'icon': Icons.medication},
    {'value': 'follow_up', 'label': 'Follow-up', 'icon': Icons.assignment},
    {'value': 'custom', 'label': 'Custom', 'icon': Icons.alarm},
  ];

  final List<Map<String, String>> _recurrenceOptions = [
    {'value': 'none', 'label': 'One-time'},
    {'value': 'daily', 'label': 'Daily'},
    {'value': 'weekly', 'label': 'Weekly'},
    {'value': 'monthly', 'label': 'Monthly'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeFromTestResult();
  }

  void _initializeFromTestResult() {
    if (widget.testResult != null) {
      _titleController.text = 'Follow-up for ${widget.testResult!.title}';
      _descriptionController.text = 'Follow-up appointment or retest for ${widget.testResult!.title} from ${widget.testResult!.labName ?? "lab"}';
      _selectedType = 'follow_up';
      // Set reminder for 30 days from test date
      _selectedDateTime = widget.testResult!.dateTaken.add(const Duration(days: 30));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Reminder'),
        backgroundColor: AppTheme.lavenderAccent,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Reminder Title',
                  hintText: 'e.g., Take morning medication',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Additional details about this reminder',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Reminder type selection
              Text(
                'Reminder Type',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _reminderTypes.map((type) {
                  final isSelected = _selectedType == type['value'];
                  return FilterChip(
                    selected: isSelected,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          type['icon'] as IconData,
                          size: 16,
                          color: isSelected ? Colors.white : AppTheme.darkGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(type['label'] as String),
                      ],
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedType = type['value'] as String;
                        });
                      }
                    },
                    selectedColor: AppTheme.lavenderAccent,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.darkGrey,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Date and time selection
              Text(
                'Date & Time',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text(_formatDateTime(_selectedDateTime)),
                  subtitle: const Text('Tap to change'),
                  onTap: _selectDateTime,
                ),
              ),
              const SizedBox(height: 24),

              // Recurrence selection
              Text(
                'Repeat',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRecurrence,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.repeat),
                ),
                items: _recurrenceOptions.map((option) {
                  return DropdownMenuItem(
                    value: option['value'],
                    child: Text(option['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRecurrence = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 32),

              // Create button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createReminder,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create Reminder'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _createReminder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final reminderData = ReminderCreate(
        reminderType: _selectedType,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        dueDateTime: _selectedDateTime,
        recurrenceType: _selectedRecurrence,
        testResultId: widget.testResult?.id,
      );

      await context.read<ReminderProvider>().createReminder(reminderData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder created successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating reminder: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now).inDays;
    
    String dateStr;
    if (difference == 0) {
      dateStr = 'Today';
    } else if (difference == 1) {
      dateStr = 'Tomorrow';
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
    
    final timeStr = '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$dateStr at $timeStr';
  }
}