import 'package:promogoai/models/product.dart';
import 'package:stacked/stacked.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:promogoai/ui/common/api_constants.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/app/app.router.dart';
import 'package:promogoai/app/app.bottomsheets.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:promogoai/services/auth_service.dart';
import 'package:promogoai/services/chat_service.dart';
import 'package:promogoai/ui/common/setup_snackbar_ui.dart';

class ProductDetailViewModel extends BaseViewModel {
  final Product product;
  int _selectedImageIndex = 0;
  int get selectedImageIndex => _selectedImageIndex;

  String get currentImageUrl => product.gallery[_selectedImageIndex];
  
  List<Product> _suggestedProducts = [];
  List<Product> get suggestedProducts => _suggestedProducts;

  String _suggestionTitle = "product_detail.similar_items";
  String get suggestionTitle => _suggestionTitle.tr();

  bool _loadingSuggestions = false;
  bool get loadingSuggestions => _loadingSuggestions;

  final _navigationService = locator<NavigationService>();
  final _authService = locator<AuthService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _chatService = locator<ChatService>();
  final _snackbarService = locator<SnackbarService>();
  
  ProductDetailViewModel({required this.product}) {
    fetchSuggestions();
  }

  void setSelectedImage(int index) {
    _selectedImageIndex = index;
    notifyListeners();
  }

  Future<void> fetchSuggestions() async {
    final sellerId = product.sellerId;
    final categoryId = product.categoryId;
    final currentAdId = product.id;

    if (sellerId == null && categoryId == null) return;

    _loadingSuggestions = true;
    notifyListeners();

    try {
      // 1. Essayer de charger les autres produits du vendeur
      if (sellerId != null) {
        final url = "${ApiConstants.adsEndpoint}?seller=$sellerId";
        final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
        
        if (response.statusCode == 200) {
          dynamic jsonData = jsonDecode(utf8.decode(response.bodyBytes));
          List<dynamic> results = [];
          if (jsonData is List) {
            results = jsonData;
          } else if (jsonData is Map && jsonData.containsKey('results')) {
            results = jsonData['results'] as List<dynamic>;
          }
          
          List<Product> products = results
              .map((data) => Product.fromJson(data as Map<String, dynamic>))
              .where((p) => p.id != currentAdId) // Exclure le produit actuel
              .toList();

          if (products.isNotEmpty) {
            _suggestedProducts = products;
            _suggestionTitle = "product_detail.same_seller";
            _loadingSuggestions = false;
            notifyListeners();
            return;
          }
        }
      }

      // 2. Si aucun produit du vendeur (ou échec), charger les produits similaires (même catégorie)
      if (categoryId != null) {
        final url = "${ApiConstants.adsEndpoint}?categorie=$categoryId";
        final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
        
        if (response.statusCode == 200) {
          dynamic jsonData = jsonDecode(utf8.decode(response.bodyBytes));
          List<dynamic> results = [];
          if (jsonData is List) {
            results = jsonData;
          } else if (jsonData is Map && jsonData.containsKey('results')) {
            results = jsonData['results'] as List<dynamic>;
          }
          
          List<Product> products = results
              .map((data) => Product.fromJson(data as Map<String, dynamic>))
              .where((p) => p.id != currentAdId) // Exclure le produit actuel
              .toList();

          if (products.isNotEmpty) {
            _suggestedProducts = products;
            _suggestionTitle = "product_detail.similar_items";
            _loadingSuggestions = false;
            notifyListeners();
            return;
          }
        }
      }
    } catch (e) {
      print("❌ [ProductDetailViewModel] Erreur chargement suggestions: $e");
    }

    _suggestedProducts = [];
    _loadingSuggestions = false;
    notifyListeners();
  }

  Future<void> onChatWithSeller() async {
    if (!_authService.isLogged) {
      final response = await _bottomSheetService.showCustomSheet(
        variant: BottomSheetType.authRequired,
      );
      if (response?.confirmed == true) {
        _navigationService.navigateToLoginView();
      }
      return;
    }

    final sellerId = product.sellerId;
    if (sellerId == null) {
      print("⚠️ [ProductDetail] Aucun sellerId trouvé sur ce produit");
      return;
    }

    setBusy(true);
    try {
      // Vérifier le produit précédemment discuté avec ce vendeur dans le cache local
      bool productChanged = false;
      final cachedRooms = await _chatService.loadCachedRooms();
      for (var r in cachedRooms) {
        if (r.sellerId == sellerId || r.buyerId == sellerId) {
          // Si le salon existant pointait vers un produit différent de l'actuel
          if (r.adId != product.id) {
            productChanged = true;
          }
          break;
        }
      }

      final room = await _chatService.getOrCreateRoom(sellerId, product.id);
      setBusy(false);

      if (room != null) {
        // Envoyer le message d'intérêt si c'est un nouveau salon OU si l'acheteur a changé de produit
        if (room.lastMessageContent == null || productChanged) {
          final initMessage = "product_detail.interest_message".tr(args: [product.name]) +
              "|[AD_INFO:${product.imageUrl}|${product.price}]";
          await _chatService.sendChatMessage(room.id, initMessage);
        }
        _navigationService.navigateToChatView(chatRoom: room);
      } else {
        print("❌ [ProductDetail] Échec de la création/récupération du salon de chat");
        _snackbarService.showCustomSnackBar(
          variant: SnackbarType.error,
          message: "chat.offline_error".tr(),
        );
      }
    } catch (e) {
      setBusy(false);
      print("❌ [ProductDetail] Exception onChatWithSeller: $e");
      _snackbarService.showCustomSnackBar(
        variant: SnackbarType.error,
        message: "chat.offline_error".tr(),
      );
    }
  }
}
