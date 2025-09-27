import 'package:flutter/material.dart';

class AppTheme {
  // Vibrant but soft color palette
  static const Color lavender = Color(0xFF9C88FF);        // More vibrant lavender
  static const Color lavenderAccent = Color(0xFF8B7CF6);  // Rich purple-lavender
  static const Color softPink = Color(0xFFFF6B9D);        // Vibrant pink
  static const Color softYellow = Color(0xFFFFC107);      // Bright yellow
  static const Color lightGrey = Color(0xFFF8F9FA);
  static const Color darkGrey = Color(0xFF374151);        // Darker for better contrast
  static const Color white = Color(0xFFFFFFFF);
  
  // Status colors (vibrant but health-appropriate)
  static const Color softGreen = Color(0xFF10B981);       // Fresh green
  static const Color softOrange = Color(0xFFFF8A00);      // Vibrant orange
  static const Color softRed = Color(0xFFFF5757);         // Bright red
  static const Color softPurple = Color(0xFFAB7DF6);      // Rich purple

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: lavenderAccent,
        brightness: Brightness.light,
        primary: lavenderAccent,
        secondary: softPink,
        tertiary: softYellow,
        surface: white,
        background: lightGrey,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: lavenderAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        color: white,
        elevation: 4,
        shadowColor: lavender.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lavenderAccent,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: lavender.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lavender),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lavender.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lavenderAccent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkGrey,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: darkGrey,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: darkGrey,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: darkGrey,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: darkGrey,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: darkGrey,
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: lavenderAccent,
        unselectedItemColor: darkGrey,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: softYellow,
        labelStyle: const TextStyle(
          color: darkGrey,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
  
  // Helper method to get status colors
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'normal':
      case 'reviewed':
        return softGreen;
      case 'pending':
      case 'borderline':
        return softOrange;
      case 'failed':
      case 'needs attention':
      case 'high':
        return softRed;
      default:
        return softPurple;
    }
  }
  
  // Helper method to get reminder type colors
  static Color getReminderTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'medication':
        return softPink;
      case 'appointment':
        return lavender;
      case 'test':
        return softYellow;
      default:
        return softPurple;
    }
  }
}