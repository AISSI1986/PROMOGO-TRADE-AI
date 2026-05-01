import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:promogoai/ui/common/api_constants.dart';

class CategoryService {
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> get categories => _categories;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  /// Charge les catégories depuis l'API (à appeler au startup)
  Future<void> loadCategories() async {
    if (_isLoaded) return;

    try {
      print("📂 [CategoryService] Chargement des catégories...");
      final response = await http.get(Uri.parse(ApiConstants.categoriesEndpoint));
      
      if (response.statusCode == 200) {
        final dynamic jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> results = [];

        if (jsonData is List) {
          results = jsonData;
        } else if (jsonData is Map && jsonData.containsKey('results')) {
          results = jsonData['results'];
        }

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
        
        _isLoaded = true;
        print("📂 [CategoryService] ${_categories.length} catégories chargées avec succès.");
      }
    } catch (e) {
      print("📂 [CategoryService] Erreur lors du chargement: $e");
    }
  }

  /// Filtre les catégories localement pour la recherche
  List<Map<String, dynamic>> filterCategories(String query) {
    if (query.isEmpty) return _categories;
    return _categories
        .where((cat) => (cat['libele'] as String).toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
