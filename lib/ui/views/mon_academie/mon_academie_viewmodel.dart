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

  List<Map<String, dynamic>> _certificates = [];
  List<Map<String, dynamic>> get certificates => _certificates;

  // État du moteur de vérification des certificats
  bool _isVerifying = false;
  bool get isVerifying => _isVerifying;

  Map<String, dynamic>? _verificationResult;
  Map<String, dynamic>? get verificationResult => _verificationResult;

  /// Initialisation : On charge les cours, les tags et les certificats
  Future<void> init() async {
    await Future.wait([
      loadCourses(),
      loadTags(),
      loadCertificates(),
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
              .catchError((Object e) {
                print("Erreur pré-chargement image: $e");
                return Future<FileInfo>.error(e);
              });
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

  Future<void> loadCertificates() async {
    try {
      _certificates = await _academyService.getCertificates();
      notifyListeners();
    } catch (e) {
      print("Erreur chargement certificats ViewModel: $e");
    }
  }

  Future<void> loadAllProgress() async {
    for (var course in _courses) {
      final progress = await _academyService.getProgression(course.id);
      if (progress != null) {
        final double perc = (progress['pourcentage'] as num? ?? 0).toDouble();
        _courseProgress[course.id] = perc;
        print("📊 [MonAcademieViewModel] Progression cours ${course.id} (${course.title}): $perc%");
      }
    }
    notifyListeners();
  }

  double getProgressForCourse(String courseId) {
    return _courseProgress[courseId] ?? 0.0;
  }

  bool hasCertificate(String courseId) {
    return _certificates.any((c) => c['course_id'].toString() == courseId.toString());
  }

  Map<String, dynamic>? getCertificateForCourse(String courseId) {
    try {
      return _certificates.firstWhere((c) => c['course_id'].toString() == courseId.toString());
    } catch (_) {
      return null;
    }
  }

  Future<void> verifyCertificateCode(String code) async {
    _isVerifying = true;
    _verificationResult = null;
    notifyListeners();

    try {
      final res = await _academyService.verifyCertificate(code.trim());
      _verificationResult = res;
    } catch (e) {
      _verificationResult = {
        'valid': false,
        'error': 'Erreur de communication avec le serveur'
      };
    } finally {
      _isVerifying = false;
      notifyListeners();
    }
  }

  void resetVerification() {
    _verificationResult = null;
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

  // --- GETTERS STATISTIQUES POUR "MON ESPACE" ---

  int get startedCoursesCount {
    return _courseProgress.values.where((p) => p > 0 && p < 100).length;
  }

  int get completedCoursesCount {
    return _courseProgress.values.where((p) => p >= 100).length;
  }

  /// Retourne le dernier cours consulté/en cours d'apprentissage
  Course? get activeCourse {
    if (_courses.isEmpty) return null;
    for (var c in _courses) {
      final p = getProgressForCourse(c.id);
      if (p > 0 && p < 100) {
        return c;
      }
    }
    return null;
  }

  /// Filtre les cours en fonction de la catégorie et du niveau
  List<Course> get filteredCourses {
    if (_courses.isEmpty) return [];
    
    return _courses.where((course) {
      final categoryMatch = _selectedCategory == 'all' || 
                           course.tags.any((t) => t.title == _selectedCategory);
      
      final levelMatch = _selectedLevel == 'all' || 
                         course.level.toLowerCase() == _selectedLevel.toLowerCase();
      
      return categoryMatch && levelMatch;
    }).toList();
  }
}
