import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:promogoai/ui/common/api_constants.dart';
import 'package:promogoai/models/product.dart';
import 'package:promogoai/services/local_storage_service.dart';
import 'package:promogoai/app/app.locator.dart';

class AdService {
  static const String _adsCacheKey = 'cached_ads.json';
  final _localStorageService = locator<LocalStorageService>();
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  List<Product> _ads = [];
  List<Product> get ads => _ads;

  List<Product> _searchAds = [];
  List<Product> get searchAds => _searchAds;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  /// Fetch all ads from Django backend
  Future<void> loadAds() async {
    try {
      print("📡 [AdService] Récupération des annonces depuis l'API...");
      final response = await http.get(Uri.parse(ApiConstants.adsEndpoint)).timeout(const Duration(seconds: 15));
      
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
        
        // Save to cache
        await _localStorageService.saveJson(_adsCacheKey, results);
        
        print("✅ [AdService] ${_ads.length} annonces récupérées et cachées.");
      } else {
        print("❌ [AdService] Erreur API : ${response.statusCode}");
        await loadCachedAds();
      }
    } catch (e) {
      print("❌ [AdService] Exception lors du chargement : $e");
      await loadCachedAds();
    }
  }

  /// Load ads from local storage
  Future<void> loadCachedAds() async {
    try {
      print("📦 [AdService] Chargement des annonces depuis le cache local...");
      final cachedData = await _localStorageService.getJson(_adsCacheKey);
      if (cachedData != null && cachedData is List) {
        _ads = cachedData.map((data) => Product.fromJson(data)).toList();
        _isLoaded = true;
        print("✅ [AdService] ${_ads.length} annonces chargées depuis le cache.");
      } else {
        print("⚠️ [AdService] Aucun cache disponible.");
      }
    } catch (e) {
      print("❌ [AdService] Erreur lors du chargement du cache : $e");
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
    final url = ApiConstants.searchAdsEndpoint;
    try {
      _searchAds = []; // On vide uniquement les résultats de la recherche IA
      print("🚀 [AdService] APPEL DJANGO IA -> $url");
      print("📦 [AdService] Body: ${jsonEncode({"vector": "VECTEUR_CACHÉ_LONGUEUR_${vector.length}"})}");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({"vector": vector}),
      ).timeout(const Duration(seconds: 10));

      print("📡 [AdService] REPONSE DJANGO -> Status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final dynamic jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        print("📥 [AdService] Données reçues: $jsonData");

        List<dynamic> results = [];
        if (jsonData is List) {
          results = jsonData;
        } else if (jsonData is Map && jsonData.containsKey('results')) {
          results = jsonData['results'];
        }

        _searchAds = results.map((data) => Product.fromJson(data)).toList();
        print("✅ [AdService] ${_searchAds.length} annonces trouvées via l'IA.");
      } else {
        print("❌ [AdService] Erreur API Recherche: ${response.statusCode} | Body: ${response.body}");
      }
    } catch (e) {
      print("❌ [AdService] Exception lors de la recherche vectorielle : $e");
    }
  }
}
