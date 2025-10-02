class Lab {
  final String id;
  final String name;
  final String cliaNumber;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String phoneNumber;
  final String status;
  final DateTime createdAt;

  Lab({
    required this.id,
    required this.name,
    required this.cliaNumber,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.phoneNumber,
    required this.status,
    required this.createdAt,
  });

  factory Lab.fromJson(Map<String, dynamic> json) {
    return Lab(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      cliaNumber: json['clia_number'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zip_code'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending Approval';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'suspended':
        return 'Suspended';
      default:
        return status;
    }
  }

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
}

class LabApprovalRequest {
  final String status;

  LabApprovalRequest({required this.status});

  Map<String, dynamic> toJson() {
    return {'status': status};
  }
}

class UserActivationRequest {
  final bool isActive;

  UserActivationRequest({required this.isActive});

  Map<String, dynamic> toJson() {
    return {'is_active': isActive};
  }
}

class LabRegistrationRequest {
  final String labName;
  final String cliaNumber;
  final String address;
  final String? phone;
  final String labEmail;
  final String? website;
  final String userName;
  final String userEmail;
  final String password;

  LabRegistrationRequest({
    required this.labName,
    required this.cliaNumber,
    required this.address,
    this.phone,
    required this.labEmail,
    this.website,
    required this.userName,
    required this.userEmail,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'lab_name': labName,
      'clia_number': cliaNumber,
      'address': address,
      'phone': phone,
      'lab_email': labEmail,
      'website': website,
      'user_name': userName,
      'user_email': userEmail,
      'password': password,
    };
  }
}