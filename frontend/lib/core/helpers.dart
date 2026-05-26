import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helpers {
  static String formatDateTime(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  static String formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  static String formatTime(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('HH:mm').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Conférence':
        return const Color(0xFF1565C0);
      case 'Atelier':
        return const Color(0xFF2E7D32);
      case 'Compétition':
        return const Color(0xFFE65100);
      case 'Formation':
        return const Color(0xFF6A1B9A);
      case 'Culturel':
        return const Color(0xFFC62828);
      case 'Sportif':
        return const Color(0xFF00838F);
      case 'Social':
        return const Color(0xFFF9A825);
      default:
        return const Color(0xFF546E7A);
    }
  }

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Conférence':
        return Icons.mic;
      case 'Atelier':
        return Icons.build;
      case 'Compétition':
        return Icons.emoji_events;
      case 'Formation':
        return Icons.school;
      case 'Culturel':
        return Icons.public;
      case 'Sportif':
        return Icons.sports_soccer;
      case 'Social':
        return Icons.people;
      default:
        return Icons.event;
    }
  }
}
