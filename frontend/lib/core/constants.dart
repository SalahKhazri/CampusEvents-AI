import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  static const String appName = "CampusEvents AI";
  static const Duration apiTimeout = Duration(seconds: 30);

  static String get baseUrl {
    if (kIsWeb) {
      final host = Uri.base.host;
      return 'http://$host:8000';
    }
    if (Platform.isAndroid) return 'http://192.168.188.177:8000';
    return 'http://localhost:8000';
  }

  static const String adminEmail = "admin@campus.ma";
  static const String adminPassword = "admin123";
  static const String studentEmail = "etudiant@campus.ma";
  static const String studentPassword = "etudiant123";

  static const List<String> eventCategories = [
    "Conférence",
    "Atelier",
    "Compétition",
    "Formation",
    "Culturel",
    "Sportif",
    "Social",
    "Autre",
  ];
}
