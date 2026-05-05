import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';
import '../ui/common/api_constants.dart';

class AcademyService {
  Future<List<Course>> getCourses() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.academyCoursesEndpoint));
      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        
        List data = [];
        if (decoded is Map && decoded.containsKey('results')) {
          data = decoded['results'];
        } else if (decoded is List) {
          data = decoded;
        }

        return data.map((c) => Course.fromJson(c)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching courses: $e");
      return [];
    }
  }

  Future<Course?> getCourseDetail(String id) async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.getAcademyCourseDetailEndpoint(id)));
      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        
        dynamic courseData;
        if (decoded is Map && decoded.containsKey('results')) {
          // Si jamais le détail est aussi paginé (cas rare mais possible)
          List results = decoded['results'];
          if (results.isNotEmpty) courseData = results.first;
        } else if (decoded is List) {
          if (decoded.isNotEmpty) courseData = decoded.first;
        } else {
          courseData = decoded;
        }

        if (courseData != null) {
          return Course.fromJson(courseData);
        }
      }
      return null;
    } catch (e) {
      print("Error fetching course detail: $e");
      return null;
    }
  }
}
