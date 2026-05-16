import 'package:stacked/stacked.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/services/auth_service.dart';
import 'package:promogoai/ui/common/api_constants.dart';
import 'package:promogoai/models/product.dart';

class SavedViewModel extends BaseViewModel {
  final _authService = locator<AuthService>();

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  List<dynamic> _myAds = [];
  List<dynamic> get myAds => _myAds;

  void setIndex(int index) {
    _currentIndex = index;
    if (_currentIndex == 0 && _myAds.isEmpty) {
      fetchMyAds();
    }
    notifyListeners();
  }

  Future<void> fetchMyAds() async {
    if (!_authService.isLogged) return;

    setBusy(true);
    try {
      final token = _authService.accessToken;
      final response = await http.get(
        Uri.parse(ApiConstants.myAdsEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is Map && data.containsKey('results')) {
          _myAds = data['results'];
        } else if (data is List) {
          _myAds = data;
        } else {
          _myAds = [];
        }
      } else if (response.statusCode == 401) {
        print("🔄 [SavedViewModel] Session expirée (401). Tentative de rafraîchissement...");
        bool refreshed = await _authService.refreshAccessToken();
        
        if (refreshed) {
          print("🔄 [SavedViewModel] Token rafraîchi, nouvelle tentative...");
          return await fetchMyAds(); // Retentative
        } else {
          print("❌ [SavedViewModel] Échec du rafraîchissement. Déconnexion.");
          await _authService.logout();
          notifyListeners();
        }
      } else {
        print("❌ [SavedViewModel] Erreur ${response.statusCode}");
      }
    } catch (e) {
      print("❌ [SavedViewModel] Erreur réseau: $e");
    } finally {
      setBusy(false);
    }
  }

  // Helper pour convertir une annonce API en modèle Product
  Product mapToProduct(Map<String, dynamic> ad) {
    String imageUrl = 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500&q=80'; // Fallback
    
    if (ad['images'] != null && ad['images'].isNotEmpty) {
      imageUrl = ad['images'][0]['image'];
      // Si l'URL est relative, on ajoute le domaine
      if (!imageUrl.startsWith('http')) {
        imageUrl = '${ApiConstants.djangoRootUrl}$imageUrl';
      }
    }

    return Product(
      name: ad['title'] ?? 'Sans titre',
      price: '${ad['prix']} F CFA',
      imageUrl: imageUrl,
      description: ad['description'] ?? '',
      gallery: [],
    );
  }
}
