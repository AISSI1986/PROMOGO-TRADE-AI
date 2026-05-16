import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:promogoai/ui/common/api_constants.dart';
import 'package:promogoai/services/local_storage_service.dart';
import 'package:promogoai/app/app.locator.dart';

class CategoryService {
  static const String _categoriesCacheKey = 'cached_categories.json';
  final _localStorageService = locator<LocalStorageService>();
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> get categories => _categories;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  /// Charge les catégories depuis l'API (à appeler au startup)
  Future<void> loadCategories() async {
    if (_isLoaded) return;

    try {
      print("📂 [CategoryService] Chargement des catégories depuis l'API...");
      final response = await http.get(Uri.parse(ApiConstants.categoriesEndpoint)).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final dynamic jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> results = [];

        if (jsonData is List) {
          results = jsonData;
        } else if (jsonData is Map && jsonData.containsKey('results')) {
          results = jsonData['results'];
        }

        _setCategories(results);
        
        // Save to cache
        await _localStorageService.saveJson(_categoriesCacheKey, results);
        
        _isLoaded = true;
        print("📂 [CategoryService] ${_categories.length} catégories chargées et cachées.");
      } else {
        print("📂 [CategoryService] Erreur API : ${response.statusCode}");
        await loadCachedCategories();
      }
    } catch (e) {
      print("📂 [CategoryService] Erreur lors du chargement: $e");
      await loadCachedCategories();
    }
  }

  /// Load categories from local storage
  Future<void> loadCachedCategories() async {
    try {
      print("📦 [CategoryService] Chargement des catégories depuis le cache local...");
      final cachedData = await _localStorageService.getJson(_categoriesCacheKey);
      if (cachedData != null && cachedData is List) {
        _setCategories(cachedData);
        _isLoaded = true;
        print("✅ [CategoryService] ${_categories.length} catégories chargées depuis le cache.");
      }
    } catch (e) {
      print("❌ [CategoryService] Erreur chargement cache catégories: $e");
    }
  }

  void _setCategories(List<dynamic> results) {
    // On garde l'objet complet {id, libele}
    _categories = results
        .map((cat) => {
              'id': cat['id'],
              'libele': cat['libele'] as String,
            })
        .where((cat) => !(cat['libele'] as String).contains('Ã'))
        .toList();
        
    // Tri alphabétique par libellé
    _categories.sort((a, b) => (a['libele'] as String).compareTo(b['libele'] as String));
  }

  /// Filtre les catégories localement pour la recherche
  List<Map<String, dynamic>> filterCategories(String query) {
    if (query.isEmpty) return _categories;
    return _categories
        .where((cat) => (cat['libele'] as String).toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
