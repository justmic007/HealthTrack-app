class User {
  final String id;
  final String email;
  final String fullName;
  final String userType;
  final String? phoneNumber;
  final bool isActive;
  final DateTime createdAt;
  
  // Professional license fields
  final String? licenseNumber;
  final String? licenseType;
  final String? licenseState;
  final bool? licenseVerified;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.userType,
    this.phoneNumber,
    required this.isActive,
    required this.createdAt,
    this.licenseNumber,
    this.licenseType,
    this.licenseState,
    this.licenseVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      userType: json['user_type'] ?? 'patient',
      phoneNumber: json['phone_number'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      licenseNumber: json['license_number'],
      licenseType: json['license_type'],
      licenseState: json['license_state'],
      licenseVerified: json['license_verified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'user_type': userType,
      'phone_number': phoneNumber,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class UserCreate {
  final String email;
  final String password;
  final String fullName;
  final String? phoneNumber;
  
  // Professional license fields
  final String? licenseNumber;
  final String? licenseType;
  final String? licenseState;

  UserCreate({
    required this.email,
    required this.password,
    required this.fullName,
    this.phoneNumber,
    this.licenseNumber,
    this.licenseType,
    this.licenseState,
  });

  Map<String, dynamic> toJson() {
    final json = {
      'email': email,
      'password': password,
      'full_name': fullName,
      'phone_number': phoneNumber,
    };
    
    // Add license fields if provided
    if (licenseNumber != null) json['license_number'] = licenseNumber;
    if (licenseType != null) json['license_type'] = licenseType;
    if (licenseState != null) json['license_state'] = licenseState;
    
    return json;
  }
}

class PatientCreate {
  final String email;
  final String password;
  final String fullName;
  final String? phoneNumber;

  PatientCreate({
    required this.email,
    required this.password,
    required this.fullName,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'full_name': fullName,
      'phone_number': phoneNumber,
    };
  }
}

class CaregiverCreate {
  final String email;
  final String password;
  final String fullName;
  final String? phoneNumber;
  final String licenseNumber;
  final String licenseType;
  final String licenseState;

  CaregiverCreate({
    required this.email,
    required this.password,
    required this.fullName,
    this.phoneNumber,
    required this.licenseNumber,
    required this.licenseType,
    required this.licenseState,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'license_number': licenseNumber,
      'license_type': licenseType,
      'license_state': licenseState,
    };
  }
}

class UserLogin {
  final String email;
  final String password;

  UserLogin({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class Token {
  final String accessToken;
  final String tokenType;

  Token({
    required this.accessToken,
    required this.tokenType,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      accessToken: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? 'bearer',
    );
  }
}