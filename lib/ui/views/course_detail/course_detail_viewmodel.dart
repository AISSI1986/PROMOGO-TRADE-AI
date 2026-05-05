import 'package:stacked/stacked.dart';
import '../../../app/app.locator.dart';
import '../../../models/course_model.dart';
import '../../../services/academy_service.dart';

class CourseDetailViewModel extends BaseViewModel {
  final _academyService = locator<AcademyService>();
  final String courseId;

  Course? _course;
  Course? get course => _course;

  int _currentModuleIndex = 0;
  int get currentModuleIndex => _currentModuleIndex;

  CourseDetailViewModel({required this.courseId});

  Future<void> init() async {
    print("APPEL BACKEND : Récupération du cours ID $courseId");
    setBusy(true);
    _course = await _academyService.getCourseDetail(courseId);
    setBusy(false);
    notifyListeners();
  }

  void selectModule(int index) {
    _currentModuleIndex = index;
    notifyListeners();
  }
}
