class SystemAnalytics {
  final int totalTestResults;
  final Map<String, int> testResultsByStatus;
  final Map<String, int> testResultsByLab;
  final Map<String, int> monthlyTestTrends;
  
  final int totalLabs;
  final int activeLabs;
  final int pendingLabs;
  
  final int totalUsers;
  final Map<String, int> usersByType;
  final int activeUsers;
  final int inactiveUsers;
  
  final int recentRegistrations;
  final int recentTestUploads;

  SystemAnalytics({
    required this.totalTestResults,
    required this.testResultsByStatus,
    required this.testResultsByLab,
    required this.monthlyTestTrends,
    required this.totalLabs,
    required this.activeLabs,
    required this.pendingLabs,
    required this.totalUsers,
    required this.usersByType,
    required this.activeUsers,
    required this.inactiveUsers,
    required this.recentRegistrations,
    required this.recentTestUploads,
  });

  factory SystemAnalytics.fromJson(Map<String, dynamic> json) {
    return SystemAnalytics(
      totalTestResults: json['total_test_results'] ?? 0,
      testResultsByStatus: Map<String, int>.from(json['test_results_by_status'] ?? {}),
      testResultsByLab: Map<String, int>.from(json['test_results_by_lab'] ?? {}),
      monthlyTestTrends: Map<String, int>.from(json['monthly_test_trends'] ?? {}),
      totalLabs: json['total_labs'] ?? 0,
      activeLabs: json['active_labs'] ?? 0,
      pendingLabs: json['pending_labs'] ?? 0,
      totalUsers: json['total_users'] ?? 0,
      usersByType: Map<String, int>.from(json['users_by_type'] ?? {}),
      activeUsers: json['active_users'] ?? 0,
      inactiveUsers: json['inactive_users'] ?? 0,
      recentRegistrations: json['recent_registrations'] ?? 0,
      recentTestUploads: json['recent_test_uploads'] ?? 0,
    );
  }

  // Helper getters for display
  double get labApprovalRate {
    if (totalLabs == 0) return 0.0;
    return (activeLabs / totalLabs) * 100;
  }

  double get userActivationRate {
    if (totalUsers == 0) return 0.0;
    return (activeUsers / totalUsers) * 100;
  }

  int get completedTestResults {
    return testResultsByStatus['completed'] ?? 0;
  }

  int get pendingTestResults {
    return testResultsByStatus['pending'] ?? 0;
  }
}