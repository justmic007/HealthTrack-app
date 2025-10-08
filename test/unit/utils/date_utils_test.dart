import 'package:flutter_test/flutter_test.dart';

// Create a DateUtils class for testing
class DateUtils {
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }

  static String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  static String formatDateForDisplay(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years} year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months} month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && 
           date.month == yesterday.month && 
           date.day == yesterday.day;
  }

  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  static DateTime parseApiDate(String dateString) {
    // Handle different API date formats
    try {
      // Try ISO 8601 format first
      return DateTime.parse(dateString);
    } catch (e) {
      // Try other common formats
      final formats = [
        RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$'),
        RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$'),
        RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$'),
      ];
      
      for (final format in formats) {
        if (format.hasMatch(dateString)) {
          return DateTime.parse(dateString);
        }
      }
      
      throw FormatException('Unable to parse date: $dateString');
    }
  }

  static String formatForApi(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String();
  }

  static int daysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static List<DateTime> getDaysInMonth(int year, int month) {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    
    final days = <DateTime>[];
    for (int day = 1; day <= lastDay.day; day++) {
      days.add(DateTime(year, month, day));
    }
    
    return days;
  }
}

void main() {
  group('Date Formatting Tests', () {
    test('should format date correctly', () {
      final date = DateTime(2024, 1, 15);
      expect(DateUtils.formatDate(date), '2024-01-15');
    });

    test('should format date with single digits correctly', () {
      final date = DateTime(2024, 3, 5);
      expect(DateUtils.formatDate(date), '2024-03-05');
    });

    test('should format time correctly', () {
      final dateTime = DateTime(2024, 1, 15, 14, 30);
      expect(DateUtils.formatTime(dateTime), '14:30');
    });

    test('should format time with single digits correctly', () {
      final dateTime = DateTime(2024, 1, 15, 9, 5);
      expect(DateUtils.formatTime(dateTime), '09:05');
    });

    test('should format datetime correctly', () {
      final dateTime = DateTime(2024, 1, 15, 14, 30);
      expect(DateUtils.formatDateTime(dateTime), '2024-01-15 14:30');
    });

    test('should format date for display correctly', () {
      final date = DateTime(2024, 1, 15);
      expect(DateUtils.formatDateForDisplay(date), 'Jan 15, 2024');
    });

    test('should format all months correctly', () {
      final expectedMonths = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];

      for (int month = 1; month <= 12; month++) {
        final date = DateTime(2024, month, 15);
        final formatted = DateUtils.formatDateForDisplay(date);
        expect(formatted, contains(expectedMonths[month - 1]));
      }
    });
  });

  group('Relative Time Tests', () {
    test('should return "Just now" for recent times', () {
      final now = DateTime.now();
      final recent = now.subtract(const Duration(seconds: 30));
      expect(DateUtils.getRelativeTime(recent), 'Just now');
    });

    test('should return minutes ago correctly', () {
      final now = DateTime.now();
      final fiveMinutesAgo = now.subtract(const Duration(minutes: 5));
      expect(DateUtils.getRelativeTime(fiveMinutesAgo), '5 minutes ago');
      
      final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
      expect(DateUtils.getRelativeTime(oneMinuteAgo), '1 minute ago');
    });

    test('should return hours ago correctly', () {
      final now = DateTime.now();
      final twoHoursAgo = now.subtract(const Duration(hours: 2));
      expect(DateUtils.getRelativeTime(twoHoursAgo), '2 hours ago');
      
      final oneHourAgo = now.subtract(const Duration(hours: 1));
      expect(DateUtils.getRelativeTime(oneHourAgo), '1 hour ago');
    });

    test('should return days ago correctly', () {
      final now = DateTime.now();
      final threeDaysAgo = now.subtract(const Duration(days: 3));
      expect(DateUtils.getRelativeTime(threeDaysAgo), '3 days ago');
      
      final oneDayAgo = now.subtract(const Duration(days: 1));
      expect(DateUtils.getRelativeTime(oneDayAgo), '1 day ago');
    });

    test('should return months ago correctly', () {
      final now = DateTime.now();
      final twoMonthsAgo = now.subtract(const Duration(days: 60));
      expect(DateUtils.getRelativeTime(twoMonthsAgo), '2 months ago');
    });

    test('should return years ago correctly', () {
      final now = DateTime.now();
      final twoYearsAgo = now.subtract(const Duration(days: 730));
      expect(DateUtils.getRelativeTime(twoYearsAgo), '2 years ago');
    });
  });

  group('Date Comparison Tests', () {
    test('should correctly identify today', () {
      final now = DateTime.now();
      expect(DateUtils.isToday(now), true);
      
      final yesterday = now.subtract(const Duration(days: 1));
      expect(DateUtils.isToday(yesterday), false);
    });

    test('should correctly identify yesterday', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      expect(DateUtils.isYesterday(yesterday), true);
      
      expect(DateUtils.isYesterday(now), false);
    });

    test('should correctly identify this week', () {
      final now = DateTime.now();
      expect(DateUtils.isThisWeek(now), true);
      
      final lastWeek = now.subtract(const Duration(days: 8));
      expect(DateUtils.isThisWeek(lastWeek), false);
    });

    test('should correctly identify this month', () {
      final now = DateTime.now();
      expect(DateUtils.isThisMonth(now), true);
      
      final lastMonth = DateTime(now.year, now.month - 1, now.day);
      expect(DateUtils.isThisMonth(lastMonth), false);
    });

    test('should correctly identify same day', () {
      final date1 = DateTime(2024, 1, 15, 10, 30);
      final date2 = DateTime(2024, 1, 15, 14, 45);
      expect(DateUtils.isSameDay(date1, date2), true);
      
      final date3 = DateTime(2024, 1, 16, 10, 30);
      expect(DateUtils.isSameDay(date1, date3), false);
    });
  });

  group('API Date Parsing Tests', () {
    test('should parse ISO 8601 dates correctly', () {
      final dateStrings = [
        '2024-01-15T10:30:00Z',
        '2024-01-15T10:30:00.000Z',
        '2024-01-15T10:30:00+00:00',
      ];

      for (final dateString in dateStrings) {
        final parsed = DateUtils.parseApiDate(dateString);
        expect(parsed, isA<DateTime>());
        expect(parsed.year, 2024);
        expect(parsed.month, 1);
        expect(parsed.day, 15);
      }
    });

    test('should throw FormatException for invalid dates', () {
      final invalidDates = [
        'invalid-date',
        'not-a-date',
        '',
      ];

      for (final dateString in invalidDates) {
        expect(() => DateUtils.parseApiDate(dateString), 
               throwsA(isA<FormatException>()));
      }
    });

    test('should format for API correctly', () {
      final dateTime = DateTime(2024, 1, 15, 10, 30, 0);
      final formatted = DateUtils.formatForApi(dateTime);
      
      expect(formatted, contains('2024-01-15'));
      expect(formatted, contains('T'));
      expect(formatted, endsWith('Z'));
    });
  });

  group('Date Utility Functions Tests', () {
    test('should calculate days between dates correctly', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 11);
      expect(DateUtils.daysBetween(start, end), 10);
    });

    test('should get start of day correctly', () {
      final dateTime = DateTime(2024, 1, 15, 14, 30, 45);
      final startOfDay = DateUtils.startOfDay(dateTime);
      
      expect(startOfDay.year, 2024);
      expect(startOfDay.month, 1);
      expect(startOfDay.day, 15);
      expect(startOfDay.hour, 0);
      expect(startOfDay.minute, 0);
      expect(startOfDay.second, 0);
    });

    test('should get end of day correctly', () {
      final dateTime = DateTime(2024, 1, 15, 14, 30, 45);
      final endOfDay = DateUtils.endOfDay(dateTime);
      
      expect(endOfDay.year, 2024);
      expect(endOfDay.month, 1);
      expect(endOfDay.day, 15);
      expect(endOfDay.hour, 23);
      expect(endOfDay.minute, 59);
      expect(endOfDay.second, 59);
    });

    test('should get days in month correctly', () {
      final januaryDays = DateUtils.getDaysInMonth(2024, 1);
      expect(januaryDays.length, 31);
      expect(januaryDays.first, DateTime(2024, 1, 1));
      expect(januaryDays.last, DateTime(2024, 1, 31));
      
      final februaryDays = DateUtils.getDaysInMonth(2024, 2); // Leap year
      expect(februaryDays.length, 29);
      
      final february2023Days = DateUtils.getDaysInMonth(2023, 2); // Non-leap year
      expect(february2023Days.length, 28);
    });
  });
}