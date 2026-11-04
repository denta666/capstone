import 'package:flutter/material.dart';

class GuideStep {
  const GuideStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.checklist,
    required this.tips,
    this.warning,
  });

  final String title;
  final String description;
  final IconData icon;
  final List<String> checklist;
  final List<String> tips;
  final String? warning;
}

class Guide {
  const Guide({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.difficulty,
    required this.duration,
    required this.icon,
    required this.tools,
    required this.steps,
    this.imagePath,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String difficulty;
  final String duration; // indikatif, bukan angka pasti
  final IconData icon;
  final List<String> tools;
  final List<GuideStep> steps;

  /// Path aset lokal (opsional). Kalau null, tampil placeholder.
  final String? imagePath;
}