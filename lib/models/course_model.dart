import 'package:flutter/material.dart';
import '../ui/common/api_constants.dart';

class Tag {
  final int id;
  final String title;

  Tag({required this.id, required this.title});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
    );
  }
}

class Lesson {
  final int id;
  final String title;
  final String? description;
  final String? contenuUrl;
  final String duree;
  final String type;
  final int ordreAffichage;

  Lesson({
    required this.id,
    required this.title,
    this.description,
    this.contenuUrl,
    required this.duree,
    required this.type,
    required this.ordreAffichage,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      contenuUrl: json['contenu_url'] as String?,
      duree: json['duree'] as String? ?? '00:00',
      type: json['type'] as String? ?? 'TEXT',
      ordreAffichage: json['ordre_affichage'] as int? ?? 1,
    );
  }
}

class AcademyModule {
  final int id;
  final String title;
  final String description;
  final int ordreAffichage;
  final List<Lesson> lecons;
  final dynamic quiz; // À typer plus tard si besoin

  AcademyModule({
    required this.id,
    required this.title,
    required this.description,
    required this.ordreAffichage,
    this.lecons = const [],
    this.quiz,
  });

  factory AcademyModule.fromJson(Map<String, dynamic> json) {
    return AcademyModule(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      ordreAffichage: json['ordre_affichage'] as int? ?? 1,
      lecons: (json['lecons'] as List?)
              ?.map((l) => Lesson.fromJson(l as Map<String, dynamic>))
              .toList() ??
          [],
      quiz: json['quiz'],
    );
  }
}

class Course {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String? imageCouverture;
  final String level;
  final String language;
  final DateTime? datePublication;
  final List<Tag> tags;
  final int modulesCount;
  final String duration;
  final List<AcademyModule> modules;
  final String visibility;
  
  // Couleurs de secours si pas d'image
  final List<Color>? gradientColors;

  Course({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    this.imageCouverture,
    required this.level,
    required this.language,
    this.datePublication,
    this.tags = const [],
    required this.modulesCount,
    required this.duration,
    this.modules = const [],
    required this.visibility,
    this.gradientColors,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    final imageRaw = json['image_couverture'];
    String? imageFullUrl;
    
    if (imageRaw != null && imageRaw.toString().isNotEmpty) {
      if (imageRaw.toString().startsWith('http')) {
        imageFullUrl = imageRaw.toString();
      } else {
        imageFullUrl = '${ApiConstants.djangoRootUrl}$imageRaw';
      }
    }

    return Course(
      id: json['id'].toString(),
      title: json['titre'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageCouverture: imageFullUrl,
      level: json['level'] as String? ?? 'BEGINNER',
      language: json['language'] as String? ?? 'fr',
      datePublication: json['date_publication'] != null 
          ? DateTime.tryParse(json['date_publication'].toString()) 
          : null,
      tags: (json['tags'] as List?)
              ?.map((t) => Tag.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      modulesCount: json['nombre_modules'] as int? ?? 0,
      duration: json['total_heures']?.toString() ?? '',
      modules: (json['modules'] as List?)
              ?.map((m) => AcademyModule.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      visibility: json['visibility'] as String? ?? 'BOTH',
    );
  }

  // Helper pour obtenir les labels lisibles
  String get levelLabel {
    switch (level) {
      case 'BEGINNER': return 'Débutant';
      case 'INTERMEDIATE': return 'Intermédiaire';
      case 'ADVANCED': return 'Avancé';
      default: return level;
    }
  }
}
