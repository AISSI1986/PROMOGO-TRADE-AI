import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../models/course_model.dart';
import '../../../services/academy_service.dart';

class LessonViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _academyService = locator<AcademyService>();
  
  Lesson _currentLesson;
  final List<Lesson> allLessons;
  final String moduleTitle;
  final String courseId;
  
  LessonViewModel({
    required Lesson initialLesson, 
    required this.allLessons, 
    required this.moduleTitle,
    required this.courseId,
  }) : _currentLesson = initialLesson;

  Lesson get currentLesson => _currentLesson;
  
  int get currentLessonIndex => allLessons.indexOf(_currentLesson);
  bool get hasNextLesson => currentLessonIndex < allLessons.length - 1;

  Future<void> nextLesson() async {
    // Marquer la leçon actuelle comme terminée au moment de passer à la suivante
    setBusy(true);
    await _academyService.markLessonAsCompleted(courseId, _currentLesson.id);
    setBusy(false);

    if (hasNextLesson) {
      _currentLesson = allLessons[currentLessonIndex + 1];
      notifyListeners();
    } else {
      // Signaler que le module est terminé pour permettre la navigation auto
      _navigationService.back(result: true);
    }
  }

  void goBack() {
    _navigationService.back();
  }
}
