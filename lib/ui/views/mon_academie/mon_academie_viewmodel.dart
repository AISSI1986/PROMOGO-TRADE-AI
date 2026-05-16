import 'package:stacked/stacked.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
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

  List<Course> _courses = [];
  List<Course> get courses => _courses;

  List<Tag> _tags = [];
  List<Tag> get tags => _tags;

  Map<String, double> _courseProgress = {};
  Map<String, double> get courseProgress => _courseProgress;

  /// Initialisation : On charge les cours et les tags depuis l'API
  Future<void> init() async {
    await Future.wait([
      loadCourses(),
      loadTags(),
    ]);
    await loadAllProgress();
  }

  Future<void> loadCourses() async {
    setBusy(true);
    try {
      _courses = await _academyService.getCourses();
      
      // Pré-chargement des images en arrière-plan via le CacheManager
      for (var course in _courses) {
        if (course.imageCouverture != null) {
          DefaultCacheManager().downloadFile(course.imageCouverture!)
              .catchError((e) => print("Erreur pré-chargement image: $e"));
        }
      }
    } catch (e) {
      print("Erreur chargement cours ViewModel: $e");
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> loadTags() async {
    try {
      _tags = await _academyService.getTags();
      notifyListeners();
    } catch (e) {
      print("Erreur chargement tags ViewModel: $e");
    }
  }

  Future<void> loadAllProgress() async {
    for (var course in _courses) {
      final progress = await _academyService.getProgression(course.id);
      if (progress != null) {
        // Le backend renvoie un double ou int dans 'pourcentage'
        final double perc = (progress['pourcentage'] ?? 0).toDouble();
        _courseProgress[course.id] = perc;
        print("📊 [MonAcademieViewModel] Progression cours ${course.id} (${course.title}): $perc%");
      }
    }
    notifyListeners();
  }

  double getProgressForCourse(String courseId) {
    return _courseProgress[courseId] ?? 0.0;
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

  /// Filtre les cours en fonction de la catégorie et du niveau
  List<Course> get filteredCourses {
    if (_courses.isEmpty) return [];
    
    return _courses.where((course) {
      // Pour les catégories, on compare avec les tags pour le moment ou le champ category du backend
      // Si ton backend n'a pas encore de champ "category", on peut filtrer par Tags
      final categoryMatch = _selectedCategory == 'all' || 
                           course.tags.any((t) => t.title == _selectedCategory);
      
      final levelMatch = _selectedLevel == 'all' || 
                         course.level.toLowerCase() == _selectedLevel.toLowerCase();
      
      return categoryMatch && levelMatch;
    }).toList();
  }
}
