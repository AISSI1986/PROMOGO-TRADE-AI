import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../lesson/lesson_view.dart';
import '../../../app/app.locator.dart';
import '../../../models/course_model.dart';
import '../../../services/academy_service.dart';

class CourseDetailViewModel extends BaseViewModel {
  final _academyService = locator<AcademyService>();
  final _navigationService = locator<NavigationService>();

  final String courseId;
  Course? _course;
  Course? get course => _course;

  int _currentModuleIndex = 0;
  int get currentModuleIndex => _currentModuleIndex;

  List<int> _completedLessonIds = [];
  List<Lesson> _allLessonsGlobal = [];

  CourseDetailViewModel({required this.courseId});

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> init() async {
    setBusy(true);
    _errorMessage = null;
    try {
      _course = await _academyService.getCourseDetail(courseId);
      if (_course != null) {
        // Aplatir toutes les leçons pour gérer l'ordre global
        _allLessonsGlobal = _course!.modules.expand((m) => m.lecons).toList();
        await loadProgression();
      } else {
        _errorMessage = "Réessayer plus tard";
      }
    } catch (e) {
      _errorMessage = "Erreur de chargement";
    }
    setBusy(false);
    notifyListeners();
  }

  Future<void> loadProgression() async {
    if (_course == null) return;
    final progress = await _academyService.getProgression(_course!.id);
    if (progress != null && progress['lecons_terminees'] != null) {
      _completedLessonIds = List<int>.from(progress['lecons_terminees']);
      notifyListeners();
    }
  }

  bool isLessonLocked(Lesson lesson) {
    if (_course == null) return true;
    
    // Trouver l'index global de cette leçon
    int globalIndex = _allLessonsGlobal.indexWhere((l) => l.id == lesson.id);
    
    // La première leçon du cours est toujours déverrouillée
    if (globalIndex == 0) return false;
    
    // Si elle est déjà terminée, elle est déverrouillée
    if (_completedLessonIds.contains(lesson.id)) return false;

    // Sinon, elle est déverrouillée SEULEMENT si la leçon PRÉCÉDENTE est terminée
    final previousLesson = _allLessonsGlobal[globalIndex - 1];
    return !_completedLessonIds.contains(previousLesson.id);
  }

  bool isModuleCompleted(int moduleIndex) {
    if (_course == null || moduleIndex < 0 || moduleIndex >= _course!.modules.length) return false;
    final moduleLecons = _course!.modules[moduleIndex].lecons;
    if (moduleLecons.isEmpty) return true;
    return moduleLecons.every((l) => _completedLessonIds.contains(l.id));
  }

  bool isModuleLocked(int index) {
    if (_course == null || index < 0) return true;
    if (index == 0) return false; // Premier module toujours ouvert
    
    // SÉCURITÉ : Si l'utilisateur a déjà commencé ce module (au moins une leçon finie), 
    // alors on le laisse ouvert quoi qu'il arrive pour éviter l'incohérence du cadenas.
    final currentModuleLecons = _course!.modules[index].lecons;
    bool hasStartedThisModule = currentModuleLecons.any((l) => _completedLessonIds.contains(l.id));
    if (hasStartedThisModule) return false;

    // Logique standard : Un module est verrouillé si le module PRÉCÉDENT n'est pas terminé à 100%
    return !isModuleCompleted(index - 1);
  }

  void selectModule(int index) {
    _currentModuleIndex = index;
    notifyListeners();
  }

  Future<void> navigateToLesson(Lesson lecon) async {
    final result = await _navigationService.navigateToView(
      LessonView(
        lesson: lecon, 
        allLessons: _course!.modules[_currentModuleIndex].lecons,
        moduleTitle: _course!.modules[_currentModuleIndex].title,
        courseId: _course!.id,
      ),
    );
    
    // Si le module a été signalé comme terminé, on force l'état local immédiatement (Optimistic UI)
    if (result == true) {
      final currentModuleLecons = _course!.modules[_currentModuleIndex].lecons;
      for (var l in currentModuleLecons) {
        if (!_completedLessonIds.contains(l.id)) {
          _completedLessonIds.add(l.id);
        }
      }
      notifyListeners();
    }

    await loadProgression(); // Recharger quand même depuis le serveur pour confirmer
    
    // Navigation automatique vers le module suivant
    if (result == true) {
      if (_currentModuleIndex < _course!.modules.length - 1) {
        final nextIndex = _currentModuleIndex + 1;
        selectModule(nextIndex);
        
        // Navigation automatique vers la première leçon du module suivant
        final nextModule = _course!.modules[nextIndex];
        if (nextModule.lecons.isNotEmpty) {
          await navigateToLesson(nextModule.lecons[0]);
        }
      }
    }
  }
}
