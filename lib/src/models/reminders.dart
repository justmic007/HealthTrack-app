class Reminder {
  final String id;
  final String userId;
  final String? testResultId;
  final String reminderType;
  final String title;
  final String? description;
  final DateTime dueDateTime;
  final String recurrenceType;
  final Map<String, dynamic>? recurrenceData;
  final bool isCompleted;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reminder({
    required this.id,
    required this.userId,
    this.testResultId,
    required this.reminderType,
    required this.title,
    this.description,
    required this.dueDateTime,
    required this.recurrenceType,
    this.recurrenceData,
    required this.isCompleted,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      userId: json['user_id'],
      testResultId: json['test_result_id'],
      reminderType: json['reminder_type'],
      title: json['title'],
      description: json['description'],
      dueDateTime: DateTime.parse(json['due_datetime']),
      recurrenceType: json['recurrence_type'],
      recurrenceData: json['recurrence_data'],
      isCompleted: json['is_completed'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class ReminderCreate {
  final String? testResultId;
  final String reminderType;
  final String title;
  final String? description;
  final DateTime dueDateTime;
  final String recurrenceType;
  final Map<String, dynamic>? recurrenceData;

  ReminderCreate({
    this.testResultId,
    required this.reminderType,
    required this.title,
    this.description,
    required this.dueDateTime,
    required this.recurrenceType,
    this.recurrenceData,
  });

  Map<String, dynamic> toJson() {
    return {
      'test_result_id': testResultId,
      'reminder_type': reminderType,
      'title': title,
      'description': description,
      'due_datetime': dueDateTime.toIso8601String(),
      'recurrence_type': recurrenceType,
      'recurrence_data': recurrenceData,
    };
  }
}

class ReminderUpdate {
  final String? title;
  final String? description;
  final DateTime? dueDateTime;
  final String? recurrenceType;
  final Map<String, dynamic>? recurrenceData;

  ReminderUpdate({
    this.title,
    this.description,
    this.dueDateTime,
    this.recurrenceType,
    this.recurrenceData,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (dueDateTime != null) data['due_datetime'] = dueDateTime!.toIso8601String();
    if (recurrenceType != null) data['recurrence_type'] = recurrenceType;
    if (recurrenceData != null) data['recurrence_data'] = recurrenceData;
    return data;
  }
}