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

  List<Product> _promoAds = [];
  List<Product> get promoAds => _promoAds;

  List<Product> _offerAds = [];
  List<Product> get offerAds => _offerAds;

  List<Product> _customAds = [];
  List<Product> get customAds => _customAds;

  List<Product> _gridAds = [];
  List<Product> get gridAds => _gridAds;

  List<Product> _searchAds = [];
  List<Product> get searchAds => _searchAds;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  /// Nouvelle architecture: Requête ciblée par section
  Future<List<Product>> _fetchAdsFromEndpoint(String endpoint) async {
    try {
      final response = await http.get(Uri.parse(endpoint)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        dynamic jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> results = [];
        if (jsonData is List) {
          results = jsonData;
        } else if (jsonData is Map && jsonData.containsKey('results')) {
          results = jsonData['results'];
        }
        return results.map((data) => Product.fromJson(data)).toList();
      }
    } catch (e) {
      print("❌ [AdService] Erreur fetch : $e");
    }
    return [];
  }

  /// Fetch all ads via 4 requêtes ciblées distinctes
  Future<void> loadAds() async {
    print("📡 [AdService] Récupération ciblée des annonces par rayon...");
    _isLoaded = false;
    
    // 1. Produits en Promotion (Les 4 plus récents)
    _promoAds = await _fetchAdsFromEndpoint(ApiConstants.adsEndpoint);

    // 2. Meilleures offres (Simulation: on saute les 4 premiers pour éviter les doublons)
    _offerAds = await _fetchAdsFromEndpoint(ApiConstants.adsEndpoint);
    if (_offerAds.length > 4) {
      _offerAds = _offerAds.skip(4).toList();
    }

    // 3. Sélection sur-mesure (Simulation: on mélange pour un rendu dynamique)
    _customAds = await _fetchAdsFromEndpoint(ApiConstants.adsEndpoint);
    _customAds.shuffle();

    // 4. Grille de fin (Simulation: on saute les 8 premiers et on mélange)
    _gridAds = await _fetchAdsFromEndpoint(ApiConstants.adsEndpoint);
    if (_gridAds.length > 8) {
      _gridAds = _gridAds.skip(8).toList();
    }
    _gridAds.shuffle();

    // On garde _ads plein pour la compatibilité avec le cache et la recherche
    _ads = [..._promoAds, ..._offerAds, ..._customAds, ..._gridAds];
    _isLoaded = true;
    
    try {
      // Sauvegarde d'un extrait dans le cache
      await _localStorageService.saveJson(_adsCacheKey, _ads.take(20).toList());
    } catch (e) {
      print("❌ [AdService] Erreur de cache : $e");
    }
  }

  /// Load ads from local storage
  Future<void> loadCachedAds() async {
    try {
      print("📦 [AdService] Chargement des annonces depuis le cache local...");
      final cachedData = await _localStorageService.getJson(_adsCacheKey);
      if (cachedData != null && cachedData is List) {
        _ads = cachedData.map((data) => Product.fromJson(data)).toList().reversed.toList();
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

  /// Recherche textuelle locale en temps réel (met à jour la liste searchAds)
  void searchAdsByText(String query) {
    if (query.isEmpty) {
      _searchAds = [];
    } else {
      final q = query.toLowerCase();
      _searchAds = _ads.where((ad) {
        return ad.name.toLowerCase().contains(q) || 
               ad.description.toLowerCase().contains(q);
      }).toList();
    }
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
