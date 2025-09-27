class TestResult {
  final String id;
  final String patientId;
  final String labId;
  final String title;
  final DateTime dateTaken;
  final DateTime dateUploaded;
  final String? fileUrl;
  final String status;
  final String? summaryText;
  final Map<String, dynamic>? rawData;
  final String? labName;
  final String? patientName;
  final String? patientEmail;

  TestResult({
    required this.id,
    required this.patientId,
    required this.labId,
    required this.title,
    required this.dateTaken,
    required this.dateUploaded,
    this.fileUrl,
    required this.status,
    this.summaryText,
    this.rawData,
    this.labName,
    this.patientName,
    this.patientEmail,
  });

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      id: json['id'],
      patientId: json['patient_id'],
      labId: json['lab_id'],
      title: json['title'],
      dateTaken: DateTime.parse(json['date_taken']),
      dateUploaded: DateTime.parse(json['date_uploaded']),
      fileUrl: json['file_url'],
      status: json['status'],
      summaryText: json['summary_text'],
      rawData: json['raw_data'],
      labName: json['lab_name'],
      patientName: json['patient_name'],
      patientEmail: json['patient_email'],
    );
  }
}

class TestResultCreate {
  final String patientEmail;
  final String title;
  final DateTime dateTaken;
  final String status;
  final String summaryText;
  final Map<String, dynamic>? rawData;

  TestResultCreate({
    required this.patientEmail,
    required this.title,
    required this.dateTaken,
    required this.status,
    required this.summaryText,
    this.rawData,
  });

  Map<String, dynamic> toJson() {
    return {
      'patient_email': patientEmail,
      'title': title,
      'date_taken': dateTaken.toIso8601String(),
      'status': status,
      'summary_text': summaryText,
      'raw_data': rawData,
    };
  }
}