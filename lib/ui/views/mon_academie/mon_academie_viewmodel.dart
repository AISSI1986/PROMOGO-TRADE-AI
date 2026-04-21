import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../../models/course_model.dart';
import 'package:easy_localization/easy_localization.dart';

class MonAcademieViewModel extends BaseViewModel {
  int _selectedTopTabIndex = 0;
  int get selectedTopTabIndex => _selectedTopTabIndex;

  String _selectedCategory = 'all';
  String get selectedCategory => _selectedCategory;

  String _selectedLevel = 'all';
  String get selectedLevel => _selectedLevel;

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
    return _mockCourses.where((course) {
      final categoryMatch = _selectedCategory == 'all' || course.category == _selectedCategory;
      final levelMatch = _selectedLevel == 'all' || course.level == _selectedLevel;
      return categoryMatch && levelMatch;
    }).toList();
  }

  final List<Course> _mockCourses = [
    Course(
      id: '1',
      title: 'Marketing Digital Avancé',
      subtitle: 'Maîtrisez les stratégies SEO, SEA, Social Media et Content...',
      shortDescription: 'Une formation complète sur les leviers du marketing digital moderne : acquisition, conversion, rétention et analyses de performance.',
      longDescription: 'Dans ce cours, vous apprendrez à bâtir une stratégie marketing globale...',
      duration: '8h',
      modulesCount: 6,
      tags: ['SEO avancé', 'Google Ads', 'Social Media'],
      gradientColors: [const Color(0xFFFF8C42), const Color(0xFFFF3E4D)],
      category: 'Marketing',
      level: 'advanced',
    ),
    Course(
      id: '2',
      title: 'E-commerce Essentials',
      subtitle: 'Lancez et développez votre boutique en ligne avec succès.',
      shortDescription: 'Apprenez les bases de la création d\'une boutique en ligne, de la sélection des produits à la gestion des stocks.',
      longDescription: 'Devenez un expert du e-commerce en quelques semaines...',
      duration: '12h',
      modulesCount: 8,
      tags: ['Shopify', 'Logistique', 'Dropshipping'],
      gradientColors: [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
      category: 'E-commerce',
      level: 'beginner',
    ),
    Course(
      id: '3',
      title: 'IA pour le Business',
      subtitle: 'Optimisez vos processus avec l\'Intelligence Artificielle.',
      shortDescription: 'Découvrez comment utiliser ChatGPT et autres outils IA pour booster votre productivité quotidienne.',
      longDescription: 'L\'IA est le futur du business. Ne restez pas à la traîne...',
      duration: '6h',
      modulesCount: 4,
      tags: ['ChatGPT', 'Automatisation', 'Prompt Design'],
      gradientColors: [const Color(0xFF667eea), const Color(0xFF764ba2)],
      category: 'IA',
      level: 'intermediate',
    ),
    Course(
      id: '4',
      title: 'Data Analytics avec Excel',
      subtitle: 'Analysez vos données comme un pro.',
      shortDescription: 'Maîtrisez les tableaux croisés dynamiques et les fonctions complexes pour piloter votre activité.',
      longDescription: 'La donnée est le nouvel or noir. Apprenez à l\'extraire...',
      duration: '10h',
      modulesCount: 5,
      tags: ['Excel', 'Data Viz', 'KPIs'],
      gradientColors: [const Color(0xFF2af598), const Color(0xFF009efd)],
      category: 'Analytics',
      level: 'beginner',
    ),
    Course(
      id: '5',
      title: 'Publicité Facebook & IG',
      subtitle: 'Créez des campagnes qui convertissent.',
      shortDescription: 'Apprenez à cibler la bonne audience et à optimiser vos budgets publicitaires sur Meta.',
      longDescription: 'Devenez un maître de la publicité sociale...',
      duration: '9h',
      modulesCount: 7,
      tags: ['Ads Manager', 'Retargeting', 'Copywriting'],
      gradientColors: [const Color(0xFFf093fb), const Color(0xFFf5576c)],
      category: 'Marketing',
      level: 'intermediate',
    ),
    Course(
      id: '6',
      title: 'Dropshipping Global',
      subtitle: 'Vendez dans le monde entier sans stock.',
      shortDescription: 'Découvrez le modèle du dropshipping et comment trouver des fournisseurs fiables à l\'international.',
      longDescription: 'Le monde est votre marché...',
      duration: '15h',
      modulesCount: 10,
      tags: ['Sourcing', 'Global Trade', 'Scale'],
      gradientColors: [const Color(0xFFf6d365), const Color(0xFFfda085)],
      category: 'E-commerce',
      level: 'advanced',
    ),
  ];
}
