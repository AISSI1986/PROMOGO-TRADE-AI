import 'package:flutter/material.dart';

class CourseModule {
  final int id;
  final int order;
  final String title_fr;
  final String? content_fr;

  CourseModule({
    required this.id,
    required this.order,
    required this.title_fr,
    this.content_fr,
  });

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    return CourseModule(
      id: int.tryParse(json['id'].toString()) ?? 0,
      order: int.tryParse(json['order']?.toString() ?? '1') ?? 1,
      title_fr: json['title_fr'] ?? '',
      content_fr: json['content_fr'],
    );
  }
}

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
  
  // Backend specific fields
  final String title_fr;
  final List<CourseModule> modules;

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
    this.title_fr = '',
    this.modules = const [],
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'].toString(),
      title: json['title_fr'] ?? '',
      subtitle: json['subtitle_fr'] ?? '',
      shortDescription: json['short_description_fr'] ?? '',
      longDescription: '',
      duration: json['duration'] ?? '',
      modulesCount: (json['modules'] as List?)?.length ?? 0,
      tags: [],
      gradientColors: [const Color(0xFF2af598), const Color(0xFF009efd)], // Default
      category: json['category'] ?? '',
      level: json['level'] ?? '',
      title_fr: json['title_fr'] ?? '',
      modules: (json['modules'] as List?)
              ?.map((m) => CourseModule.fromJson(m))
              .toList() ??
          [],
    );
  }
}
