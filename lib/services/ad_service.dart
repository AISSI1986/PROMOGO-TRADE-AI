import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:promogoai/ui/common/api_constants.dart';
import 'package:promogoai/models/product.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  List<Product> _ads = [];
  List<Product> get ads => _ads;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  /// Fetch all ads from Django backend
  Future<void> loadAds() async {
    try {
      print("📡 [AdService] Récupération des annonces depuis l'API...");
      final response = await http.get(Uri.parse(ApiConstants.adsEndpoint));
      
      if (response.statusCode == 200) {
        final dynamic jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> results = [];

        if (jsonData is List) {
          results = jsonData;
        } else if (jsonData is Map && jsonData.containsKey('results')) {
          results = jsonData['results'];
        }

        _ads = results.map((data) => Product.fromJson(data)).toList();
        _isLoaded = true;
        print("✅ [AdService] ${_ads.length} annonces récupérées avec succès.");
      } else {
        print("❌ [AdService] Erreur API : ${response.statusCode}");
      }
    } catch (e) {
      print("❌ [AdService] Exception lors du chargement : $e");
    }
  }

  /// Filtre les annonces localement pour la recherche (en attendant la vraie recherche backend)
  List<Product> filterAds(String query) {
    if (query.isEmpty) return _ads;
    return _ads
        .where((ad) => ad.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Filtre les annonces par catégorie
  List<Product> getAdsByCategory(String categoryName) {
    if (categoryName == 'Tous' || categoryName.isEmpty) return _ads;
    // La recherche par catégorie nécessite que l'objet catégorie soit retourné
    // Pour l'instant, on filtre sur le titre car le seeding met le nom de la catégorie dans le titre
    return _ads
        .where((ad) => ad.name.toLowerCase().contains(categoryName.toLowerCase()))
        .toList();
  }

  /// Recherche les annonces via un vecteur d'IA
  Future<void> searchAdsByVector(List<dynamic> vector) async {
    try {
      _ads = []; // On vide la liste pour forcer l'affichage du loader dans l'UI
      print("📡 [AdService] Recherche vectorielle en cours via Django...");
      final response = await http.post(
        Uri.parse('${ApiConstants.adsEndpoint}search/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"vector": vector}),
      );

      if (response.statusCode == 200) {
        final dynamic jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> results = [];

        if (jsonData is List) {
          results = jsonData;
        } else if (jsonData is Map && jsonData.containsKey('results')) {
          results = jsonData['results'];
        }

        _ads = results.map((data) => Product.fromJson(data)).toList();
        print("✅ [AdService] ${_ads.length} annonces trouvées via l'IA.");
      } else {
        print("❌ [AdService] Erreur API Recherche Vectorielle : ${response.statusCode}");
      }
    } catch (e) {
      print("❌ [AdService] Exception lors de la recherche vectorielle : $e");
    }
  }
}
