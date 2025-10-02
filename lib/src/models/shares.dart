class ShareCreate {
  final String testResultId;
  final String caregiverEmail;

  ShareCreate({
    required this.testResultId,
    required this.caregiverEmail,
  });

  Map<String, dynamic> toJson() {
    return {
      'test_result_id': testResultId,
      'caregiver_email': caregiverEmail,
    };
  }
}

class Share {
  final String id;
  final String testResultId;
  final String patientId;
  final String caregiverId;
  final DateTime dateShared;
  final bool isActive;
  final String testResultTitle;
  final String caregiverName;
  final String? caregiverLicenseType;
  final String? caregiverLicenseNumber;
  final bool? caregiverLicenseVerified;

  Share({
    required this.id,
    required this.testResultId,
    required this.patientId,
    required this.caregiverId,
    required this.dateShared,
    required this.isActive,
    required this.testResultTitle,
    required this.caregiverName,
    this.caregiverLicenseType,
    this.caregiverLicenseNumber,
    this.caregiverLicenseVerified,
  });

  factory Share.fromJson(Map<String, dynamic> json) {
    return Share(
      id: json['id'],
      testResultId: json['test_result_id'],
      patientId: json['patient_id'],
      caregiverId: json['caregiver_id'],
      dateShared: DateTime.parse(json['date_shared']),
      isActive: json['is_active'],
      testResultTitle: json['test_result_title'],
      caregiverName: json['caregiver_name'],
      caregiverLicenseType: json['caregiver_license_type'],
      caregiverLicenseNumber: json['caregiver_license_number'],
      caregiverLicenseVerified: json['caregiver_license_verified'],
    );
  }
}