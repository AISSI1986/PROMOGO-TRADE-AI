import 'package:flutter/material.dart';

class Course {
  final String id;
  final String title;
  final String subtitle;
  final String shortDescription;
  final String longDescription;
  final String duration;
  final int modulesCount;
  final List<String> tags;
  final List<Color> gradientColors;
  final String category;
  final String level;

  Course({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.shortDescription,
    required this.longDescription,
    required this.duration,
    required this.modulesCount,
    required this.tags,
    required this.gradientColors,
    required this.category,
    required this.level,
  });
}
