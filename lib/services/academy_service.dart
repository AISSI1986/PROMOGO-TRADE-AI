import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';
import '../ui/common/api_constants.dart';
import 'package:promogoai/services/local_storage_service.dart';
import 'package:promogoai/services/auth_service.dart';
import 'package:promogoai/app/app.locator.dart';

class AcademyService {
  static const String _coursesCacheKey = 'v2_cached_academy_courses.json';
  final _localStorageService = locator<LocalStorageService>();
  final _authService = locator<AuthService>();

  String _getProgressionKey(String courseId) => 'academy_progress_$courseId.json';

  /// Récupère la liste des cours (depuis API ou Cache)
  Future<List<Course>> getCourses() async {
    try {
      print("📡 [AcademyService] Récupération des cours...");
      final response = await http.get(
        Uri.parse(ApiConstants.academyCoursesEndpoint),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        
        List data = [];
        if (decoded is Map && decoded.containsKey('results')) {
          data = decoded['results'];
        } else if (decoded is List) {
          data = decoded;
        }

        // Sauvegarde dans le cache pour usage hors-ligne
        await _localStorageService.saveJson(_coursesCacheKey, data);

        return data.map((c) => Course.fromJson(c)).toList();
      }
      
      // Si erreur serveur, on tente le cache
      return await loadCachedCourses();
    } catch (e) {
      print("❌ [AcademyService] Erreur API : $e");
      return await loadCachedCourses();
    }
  }

  /// Récupère la liste de tous les tags disponibles
  Future<List<Tag>> getTags() async {
    try {
      print("📡 [AcademyService] Récupération des tags...");
      final response = await http.get(
        Uri.parse(ApiConstants.academyTagsEndpoint),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        List data = [];
        if (decoded is Map && decoded.containsKey('results')) {
          data = decoded['results'];
        } else if (decoded is List) {
          data = decoded;
        }
        return data.map((t) => Tag.fromJson(t)).toList();
      }
    } catch (e) {
      print("❌ [AcademyService] Erreur tags : $e");
    }
    return [];
  }

  /// Charge les cours depuis le stockage local (Mode Hors-ligne)
  Future<List<Course>> loadCachedCourses() async {
    try {
      print("📦 [AcademyService] Chargement du cache local...");
      final cachedData = await _localStorageService.getJson(_coursesCacheKey);
      if (cachedData != null && cachedData is List) {
        return cachedData.map((c) => Course.fromJson(c)).toList();
      }
    } catch (e) {
      print("❌ [AcademyService] Erreur cache : $e");
    }
    return [];
  }

  /// Récupère le détail complet d'un cours (Modules, Leçons, Quiz)
  Future<Course?> getCourseDetail(String id) async {
    try {
      print("📡 [AcademyService] Récupération du détail du cours $id...");
      final response = await http.get(
        Uri.parse(ApiConstants.getAcademyCourseDetailEndpoint(id)),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        return Course.fromJson(decoded);
      }
      return null;
    } catch (e) {
      print("❌ [AcademyService] Erreur détail cours : $e");
      return null;
    }
  }

  /// Récupère la progression de l'utilisateur pour un cours (Network + Cache fallback)
  Future<Map<String, dynamic>?> getProgression(String courseId) async {
    final cacheKey = _getProgressionKey(courseId);
    
    try {
      final token = _authService.accessToken;
      if (token == null) return await loadCachedProgression(courseId);

      print("📡 [AcademyService] GET Progress for course $courseId (Token: ${token.substring(0, 10)}...)");
      
      final response = await http.get(
        Uri.parse("${ApiConstants.djangoBaseUrl}/academy/courses/$courseId/progress/"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final serverData = json.decode(utf8.decode(response.bodyBytes));
        
        // CORRECTION : Mapper le champ du backend vers le nom utilisé par le mobile
        if (serverData.containsKey('pourcentage_completion')) {
          serverData['pourcentage'] = serverData['pourcentage_completion'];
        }

        // FUSION INTELLIGENTE : On garde le meilleur des deux mondes
        final localData = await loadCachedProgression(courseId);
        if (localData != null) {
          final Set<int> combinedLecons = {};
          combinedLecons.addAll(List<int>.from(serverData['lecons_terminees'] ?? []));
          combinedLecons.addAll(List<int>.from(localData['lecons_terminees'] ?? []));
          
          serverData['lecons_terminees'] = combinedLecons.toList();
          // On garde le pourcentage le plus élevé
          serverData['pourcentage'] = (serverData['pourcentage'] ?? 0) > (localData['pourcentage'] ?? 0) 
              ? serverData['pourcentage'] 
              : localData['pourcentage'];
        }

        await _localStorageService.saveJson(cacheKey, serverData);
        return serverData;
      } else if (response.statusCode == 401) {
        print("🔑 [AcademyService] 401 détecté sur GET Progress. Tentative de refresh...");
        final refreshed = await _authService.refreshAccessToken();
        if (refreshed) {
          return await getProgression(courseId); // Réessayer
        }
      }
      
      print("❌ [AcademyService] Erreur GET Progress (Status: ${response.statusCode}). Utilisation du cache.");
      return await loadCachedProgression(courseId);
    } catch (e) {
      print("❌ [AcademyService] Erreur progression réseau : $e. Utilisation du cache.");
      return await loadCachedProgression(courseId);
    }
  }

  /// Charge la progression depuis le cache local
  Future<Map<String, dynamic>?> loadCachedProgression(String courseId) async {
    try {
      final cacheKey = _getProgressionKey(courseId);
      final data = await _localStorageService.getJson(cacheKey);
      if (data != null) {
        print("📦 [AcademyService] Progression chargée depuis le cache pour le cours $courseId");
        return data as Map<String, dynamic>;
      }
    } catch (e) {
      print("❌ [AcademyService] Erreur lecture cache progression : $e");
    }
    return null;
  }

  /// Marque une leçon comme terminée (Network + Mise à jour cache optimiste)
  Future<bool> markLessonAsCompleted(String courseId, int lessonId) async {
    final cacheKey = _getProgressionKey(courseId);
    
    // MISE À JOUR OPTIMISTE DU CACHE LOCAL
    try {
      Map<String, dynamic>? cached = await loadCachedProgression(courseId);
      if (cached != null) {
        List<int> completed = List<int>.from(cached['lecons_terminees'] ?? []);
        if (!completed.contains(lessonId)) {
          completed.add(lessonId);
          cached['lecons_terminees'] = completed;
          await _localStorageService.saveJson(cacheKey, cached);
          print("💾 [AcademyService] Cache mis à jour localement pour la leçon $lessonId");
        }
      } else {
        // Si pas de cache, on en crée un minimal
        await _localStorageService.saveJson(cacheKey, {
          'lecons_terminees': [lessonId],
          'pourcentage': 0 // Sera mis à jour par le serveur plus tard
        });
      }
    } catch (e) {
      print("⚠️ [AcademyService] Erreur mise à jour cache optimiste : $e");
    }

    try {
      final token = _authService.accessToken;
      if (token == null) return false;

      final body = json.encode({'lecon_id': lessonId});
      print("📡 [AcademyService] POST Progress - Course: $courseId, Lesson: $lessonId");
      
      final response = await http.post(
        Uri.parse("${ApiConstants.djangoBaseUrl}/academy/courses/$courseId/progress/"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final serverData = json.decode(utf8.decode(response.bodyBytes));
        if (serverData.containsKey('pourcentage_completion')) {
          serverData['pourcentage'] = serverData['pourcentage_completion'];
        }
        await _localStorageService.saveJson(cacheKey, serverData);
        print("✅ [AcademyService] Leçon $lessonId validée et progression mise à jour.");
        return true;
      } else if (response.statusCode == 401) {
        print("🔑 [AcademyService] 401 détecté sur POST Progress. Tentative de refresh...");
        final refreshed = await _authService.refreshAccessToken();
        if (refreshed) {
          return await markLessonAsCompleted(courseId, lessonId); // Réessayer
        }
      }

      print("❌ [AcademyService] Erreur POST Progress (Status: ${response.statusCode})");
      return false;
    } catch (e) {
      print("❌ [AcademyService] Erreur validation leçon réseau : $e");
      // On retourne quand même true car le cache local a été mis à jour (Optimisme)
      return true; 
    }
  }
}
