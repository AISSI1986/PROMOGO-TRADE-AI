import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../app/app.locator.dart';
import '../../../models/course_model.dart';
import '../../../services/academy_service.dart';

class MonAcademieViewModel extends BaseViewModel {
  final _academyService = locator<AcademyService>();

  int _selectedTopTabIndex = 0;
  int get selectedTopTabIndex => _selectedTopTabIndex;

  String _selectedCategory = 'all';
  String get selectedCategory => _selectedCategory;

  String _selectedLevel = 'all';
  String get selectedLevel => _selectedLevel;

  // VOICI VOS 6 COURS MAPPÉS SUR LES IDS 1 À 6
  List<Course> _courses = [
    Course(
      id: '1',
      title: 'Marketing Digital',
      subtitle: 'Maîtrisez le SEO, SEA et les réseaux sociaux.',
      shortDescription: 'Une formation complète pour devenir expert en marketing numérique.',
      longDescription: '',
      duration: '8h',
      modulesCount: 6,
      tags: ['SEO', 'Ads', 'Social'],
      gradientColors: [const Color(0xFFFF8C42), const Color(0xFFFF3E4D)],
      category: 'Marketing',
      level: 'advanced',
    ),
    Course(
      id: '2',
      title: 'E-commerce Essentials',
      subtitle: 'Lancez et développez votre boutique en ligne.',
      shortDescription: 'Tout savoir sur Shopify, la logistique et les ventes digitales.',
      longDescription: '',
      duration: '12h',
      modulesCount: 8,
      tags: ['Shopify', 'Sales'],
      gradientColors: [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
      category: 'E-commerce',
      level: 'beginner',
    ),
    Course(
      id: '3',
      title: 'Business Intelligence',
      subtitle: 'Prenez des décisions basées sur les données.',
      shortDescription: 'Apprenez à analyser vos performances et à utiliser les outils IA.',
      longDescription: '',
      duration: '10h',
      modulesCount: 5,
      tags: ['Data', 'IA', 'Analytics'],
      gradientColors: [const Color(0xFFa18cd1), const Color(0xFFfbc2eb)],
      category: 'IA',
      level: 'intermediate',
    ),
    Course(
      id: '4',
      title: 'PAPS & Paiements',
      subtitle: 'Maîtrisez les systèmes de paiements en Afrique.',
      shortDescription: 'Comprendre le système PAPSS et la gestion des flux financiers.',
      longDescription: '',
      duration: '6h',
      modulesCount: 4,
      tags: ['Fintech', 'Paiement'],
      gradientColors: [const Color(0xFFf093fb), const Color(0xFFf5576c)],
      category: 'IA',
      level: 'advanced',
    ),
    Course(
      id: '5',
      title: 'ZLECAF : Formation',
      subtitle: 'Vendre et acheter dans la zone de libre-échange.',
      shortDescription: 'Guide complet sur la Zone de Libre-Échange Continentale Africaine.',
      longDescription: '',
      duration: '15h',
      modulesCount: 10,
      tags: ['Commerce', 'Afrique'],
      gradientColors: [const Color(0xFFf6d365), const Color(0xFFfda085)],
      category: 'Marketing',
      level: 'advanced',
    ),
    Course(
      id: '6',
      title: 'Stock & Logistique',
      subtitle: 'Optimisez votre chaîne d’approvisionnement.',
      shortDescription: 'Maîtrisez la gestion de stock et les flux logistiques modernes.',
      longDescription: '',
      duration: '7h',
      modulesCount: 5,
      tags: ['Logistique', 'Stock'],
      gradientColors: [const Color(0xFF84fab0), const Color(0xFF8fd3f4)],
      category: 'E-commerce',
      level: 'intermediate',
    ),
  ];
  
  List<Course> get courses => _courses;

  Future<void> init() async {
    notifyListeners();
  }

  void setTopTab(int index) {
    _selectedTopTabIndex = index;
    notifyListeners();
  }

  void setCategory(String categoryId) {
    _selectedCategory = categoryId;
    notifyListeners();
  }

  void setLevel(String levelId) {
    _selectedLevel = levelId;
    notifyListeners();
  }

  List<Course> get filteredCourses {
    return _courses.where((course) {
      final categoryMatch = _selectedCategory == 'all' || course.category == _selectedCategory;
      final levelMatch = _selectedLevel == 'all' || course.level == _selectedLevel;
      return categoryMatch && levelMatch;
    }).toList();
  }
}
