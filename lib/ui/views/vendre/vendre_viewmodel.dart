import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/ui/common/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:promogoai/app/app.router.dart';
import 'package:promogoai/ui/common/setup_snackbar_ui.dart';

import 'package:promogoai/services/local_storage_service.dart';
import 'package:promogoai/services/subscription_service.dart';
import 'package:promogoai/services/category_service.dart';
import 'package:promogoai/services/auth_service.dart';
import 'package:promogoai/models/subscription_plan.dart';

class VendreViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _categoryService = locator<CategoryService>();
  final _authService = locator<AuthService>();
  final _snackbarService = locator<SnackbarService>();
  final _localStorageService = locator<LocalStorageService>();
  final _subscriptionService = locator<SubscriptionService>();
  final _imagePicker = ImagePicker();
 
   // Contrôleurs pour l'UI (pour afficher les brouillons)
   final titleController = TextEditingController();
   final priceController = TextEditingController();
   final locationController = TextEditingController();
   final descriptionController = TextEditingController();
   final videoController = TextEditingController();

  static const String _draftFileName = 'ad_draft.json';
  Timer? _debounceTimer;

  // Categories filtrées pour la recherche
  String _categorySearchQuery = '';
  List<Map<String, dynamic>> get categories => _categoryService.filterCategories(_categorySearchQuery);

  void init() async {
    loadDraft();
    if (_subscriptionService.cachedPlans == null) {
      try {
        await _subscriptionService.fetchPlans();
        // After fetching, try to map the draft subscription name to a plan object
        _syncSelectedPlanFromDraft();
        notifyListeners();
      } catch (e) {
        debugPrint("❌ [VendreViewModel] Erreur fetchPlans: $e");
      }
    } else {
      _syncSelectedPlanFromDraft();
    }
  }

  void _syncSelectedPlanFromDraft() {
    if (_selectedSubscription != null && _subscriptionService.cachedPlans != null) {
      _selectedPlan = _subscriptionService.cachedPlans!.firstWhere(
        (p) => p.nom == _selectedSubscription,
        orElse: () => _subscriptionService.cachedPlans!.first,
      );
      _selectedSubscription = _selectedPlan?.nom;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    titleController.dispose();
    priceController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    videoController.dispose();
    super.dispose();
  }

  // --- PERSISTENCE LOGIC (BROUILLON) ---

  void saveDraft() {
    // On annule le timer précédent s'il existe
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    // On lance un nouveau timer de 500ms
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final draftData = {
          'title': _title,
          'price': _price,
          'location': _location,
          'description': _description,
          'videoLink': _videoLink,
          'selectedCategoryId': _selectedCategoryId,
          'selectedCategory': _selectedCategory,
          'negotiation': _negotiation,
          'selectedSubscription': _selectedSubscription,
          'bulkPrices': _bulkPrices,
          'imagePaths': _images.map((f) => f.path).toList(),
        };
        await _localStorageService.saveData(_draftFileName, jsonEncode(draftData));
        print("💾 [VendreViewModel] Brouillon sauvegardé (Debounced)");
      } catch (e) {
        debugPrint("❌ [VendreViewModel] Erreur saveDraft: $e");
      }
    });
  }

  Future<void> loadDraft() async {
    try {
      final draftJson = await _localStorageService.getData(_draftFileName);
      if (draftJson != null) {
        final Map<String, dynamic> data = jsonDecode(draftJson);
        _title = data['title'] ?? '';
        _price = data['price'] ?? '';
        _location = data['location'] ?? '';
        _description = data['description'] ?? '';
        _videoLink = data['videoLink'] ?? '';
        _selectedCategoryId = data['selectedCategoryId'];
        _selectedCategory = data['selectedCategory'];
        _negotiation = data['negotiation'];
        _selectedSubscription = data['selectedSubscription'] ?? 'Free';
        
        final List<dynamic> savedBulk = data['bulkPrices'] ?? [];
        _bulkPrices = savedBulk.map((item) => Map<String, String>.from(item as Map)).toList();
        
        // Mettre à jour les contrôleurs pour l'UI
        titleController.text = _title;
        priceController.text = _price;
        locationController.text = _location;
        descriptionController.text = _description;
        videoController.text = _videoLink;
        
        final List<dynamic> paths = data['imagePaths'] ?? [];
        _images = paths.map((p) => File(p as String)).where((f) => f.existsSync()).toList();
        
        notifyListeners();
        print("📂 [VendreViewModel] Brouillon restauré avec succès.");
      }
    } catch (e) {
      debugPrint("❌ [VendreViewModel] Erreur loadDraft: $e");
    }
  }

  Future<void> clearDraft() async {
    await _localStorageService.clearData(_draftFileName);
    _images.clear();
    _title = '';
    _price = '';
    _location = '';
    _description = '';
    _videoLink = '';
    _selectedCategory = null;
    _selectedCategoryId = null;

    // Vider les contrôleurs
    titleController.clear();
    priceController.clear();
    locationController.clear();
    descriptionController.clear();
    videoController.clear();

    notifyListeners();
  }

  void setSearchQuery(String query) {
    _categorySearchQuery = query;
    notifyListeners();
  }

  // Form Fields
  String _title = '';
  String get title => _title;
  
  String? _selectedCategory; // Libellé pour l'UI
  String? get selectedCategory => _selectedCategory;
  
  int? _selectedCategoryId; // ID pour le Backend
  int? get selectedCategoryId => _selectedCategoryId;

  List<File> _images = [];
  List<File> get images => _images;

  String _videoLink = '';
  String get videoLink => _videoLink;

  String _location = ''; // Texte libre
  String get location => _location;

  // Dynamic Fields simplified
  String _description = '';
  String get description => _description;

  String _price = '';
  String get price => _price;
  
  // Bulk Price Visibility
  bool _showBulkPriceForm = false;
  bool get showBulkPriceForm => _showBulkPriceForm;

  String? _negotiation;
  String? get negotiation => _negotiation;

  String? _selectedSubscription = 'BASIC'; // Changed from 'Free' to match API
  String? get selectedSubscription => _selectedSubscription;

  SubscriptionPlan? _selectedPlan;
  SubscriptionPlan? get selectedPlan => _selectedPlan;

  List<SubscriptionPlan> get subscriptionPlans => _subscriptionService.cachedPlans ?? [];

  bool get isPaidPlan => _selectedPlan != null && _selectedPlan!.prix > 0;

  String get submitButtonText => isPaidPlan ? 'post_ad.btn_pay_submit' : 'post_ad.btn_submit';

  // --- ÉTATS D'ERREUR POUR LA VALIDATION VISUELLE ---
  bool _titleHasError = false;
  bool get titleHasError => _titleHasError;

  bool _categoryHasError = false;
  bool get categoryHasError => _categoryHasError;

  bool _priceHasError = false;
  bool get priceHasError => _priceHasError;

  bool _locationHasError = false;
  bool get locationHasError => _locationHasError;

  bool _descriptionHasError = false;
  bool get descriptionHasError => _descriptionHasError;

  bool _bulkPricesHasError = false;
  bool get bulkPricesHasError => _bulkPricesHasError;

  bool _imagesHasError = false;
  bool get imagesHasError => _imagesHasError;

  bool _shouldScrollToError = false;
  bool get shouldScrollToError => _shouldScrollToError;

  void clearScrollSignal() {
    _shouldScrollToError = false;
  }

  // Validation
  bool get isTitleValid => _title.length >= 10;
  String get titleError => _title.isEmpty ? '' : 'post_ad.error_title';

  final List<String> negotiationOptions = ['Yes', 'No', 'Not sure'];

  void setTitle(String value) {
    _title = value;
    _titleHasError = false; // Reset error when user types
    saveDraft();
    notifyListeners();
  }

  void setCategory(Map<String, dynamic>? category) {
    if (category != null) {
      _selectedCategory = category['libele'];
      _selectedCategoryId = category['id'];
      _categoryHasError = false; // Reset error
    } else {
      _selectedCategory = null;
      _selectedCategoryId = null;
    }
    saveDraft();
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    _descriptionHasError = false; // Reset error
    saveDraft();
    notifyListeners();
  }

  void setLocation(String value) {
    _location = value;
    _locationHasError = false; // Reset error
    saveDraft();
    notifyListeners();
  }

  void setVideoLink(String value) {
    _videoLink = value;
    saveDraft();
    notifyListeners();
  }

  void setNegotiation(String? value) {
    _negotiation = value;
    saveDraft();
    notifyListeners();
  }

  void setSubscription(SubscriptionPlan? plan) {
    if (plan != null) {
      _selectedPlan = plan;
      _selectedSubscription = plan.nom;
      saveDraft();
      notifyListeners();
    }
  }

  void setPrice(String value) {
    _price = value;
    _priceHasError = false; // Reset error
    saveDraft();
    notifyListeners();
  }


  // Image Picking
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        _images.add(File(image.path));
        _imagesHasError = false; // Reset error
        saveDraft();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void removeImage(int index) {
    _images.removeAt(index);
    saveDraft();
    notifyListeners();
  }

  void reorderImages(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final File item = _images.removeAt(oldIndex);
    _images.insert(newIndex, item);
    saveDraft();
    notifyListeners();
  }

  // Bulk Price Actions
  void toggleBulkPriceForm() {
    _showBulkPriceForm = !_showBulkPriceForm;
    notifyListeners();
  }

  // --- LOGIQUE PRIX EN GROS (DÉGRESSIF) ---
  final List<String> bulkSizes = ['2', '5', '10', '20', '50', '100'];
  List<Map<String, String>> _bulkPrices = [];
  List<Map<String, String>> get bulkPrices => _bulkPrices;

  bool get canAddBulkPriceRow {
    if (_bulkPrices.isEmpty) return true;
    final lastRow = _bulkPrices.last;
    return lastRow['size']!.isNotEmpty && lastRow['price']!.isNotEmpty;
  }

  void addBulkPriceRow() {
    if (!canAddBulkPriceRow) return;
    _bulkPrices.add({'size': '', 'price': ''});
    notifyListeners();
  }

  void updateBulkPriceRow(int index, String key, String value) {
    if (index >= 0 && index < _bulkPrices.length) {
      _bulkPrices[index][key] = value;
      _bulkPricesHasError = false; // Reset error on change
      notifyListeners();
    }
  }

  void removeBulkPrice(int index) {
    _bulkPrices.removeAt(index);
    notifyListeners();
  }

  // SUBMIT AD
  Future<void> submitAd(String languageCode) async {
    // 0. Vérification Authentification
    if (!_authService.isLogged) {
      _snackbarService.showCustomSnackBar(
        message: "Veuillez vous connecter pour publier une annonce.",
        variant: SnackbarType.warning,
      );
      _navigationService.navigateToLoginView();
      return;
    }

    // 1. Validations Locales avec signalement visuel
    bool hasLocalErrors = false;

    if (_title.isEmpty || _title.length < 10) {
      _titleHasError = true;
      hasLocalErrors = true;
    }
    if (_selectedCategoryId == null) {
      _categoryHasError = true;
      hasLocalErrors = true;
    }
    if (_price.isEmpty) {
      _priceHasError = true;
      hasLocalErrors = true;
    }
    if (_location.isEmpty) {
      _locationHasError = true;
      hasLocalErrors = true;
    }
    if (_description.isEmpty) {
      _descriptionHasError = true;
      hasLocalErrors = true;
    }

    // Validation des prix en gros (si activé)
    if (_showBulkPriceForm && _bulkPrices.isNotEmpty) {
      bool incompleteRow = _bulkPrices.any((row) => row['size']!.isEmpty || row['price']!.isEmpty);
      if (incompleteRow) {
        _bulkPricesHasError = true;
        hasLocalErrors = true;
      }
    }

    if (_images.isEmpty) {
      _imagesHasError = true;
      hasLocalErrors = true;
    }

    if (hasLocalErrors) {
      _shouldScrollToError = true;
      _snackbarService.showCustomSnackBar(
        message: "Veuillez remplir correctement tous les champs obligatoires.",
        variant: SnackbarType.warning,
      );
      notifyListeners(); // Déclenche l'affichage des bordures rouges et le scroll
      return;
    }

    setBusy(true);

    try {
      final request = http.MultipartRequest('POST', Uri.parse(ApiConstants.addAdEndpoint));
      
      // Headers
      final token = _authService.accessToken;
      request.headers['Authorization'] = 'Bearer $token';

      // Fields
      request.fields['title'] = _title;
      request.fields['prix'] = _price.replaceAll(RegExp(r'[^0-9]'), ''); 
      request.fields['location'] = _location;
      request.fields['categorie'] = _selectedCategoryId.toString();
      request.fields['description'] = _description;
      request.fields['lien_video'] = _videoLink;
      request.fields['language'] = languageCode; // <--- AJOUT DE LA LANGUE AUTOMATIQUE

      // Images (Multipart)
      for (var file in _images) {
        request.files.add(await http.MultipartFile.fromPath('uploaded_images', file.path));
      }

      // Envoi
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final adData = jsonDecode(response.body);
        final int adId = adData['id'];

        // --- ENVOI DES PRIX EN GROS (MÉTHODE INDÉPENDANTE) ---
        if (_showBulkPriceForm && _bulkPrices.isNotEmpty) {
          try {
            await http.post(
              Uri.parse(ApiConstants.getBulkPricesEndpoint(adId)),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({'bulk_prices': _bulkPrices}),
            );
            print("📦 [SubmitAd] Prix en gros enregistrés avec succès.");
          } catch (e) {
            print("⚠️ [SubmitAd] Erreur lors de l'envoi des prix en gros: $e");
            // On ne bloque pas le succès de l'annonce car elle est déjà créée
          }
        }

        _snackbarService.showCustomSnackBar(
          message: "Annonce publiée avec succès ! 🚀",
          variant: SnackbarType.success,
        );
        clearDraft();
        // Petit délai pour laisser le temps de lire le message de succès
        await Future.delayed(const Duration(seconds: 2));
        _navigationService.replaceWithSavedView();
      } else if (response.statusCode == 401) {
        // Session expirée
        _snackbarService.showCustomSnackBar(
          message: "Votre session a expiré. Veuillez vous reconnecter.",
          variant: SnackbarType.error,
        );
        clearDraft();
        _authService.logout(); 
        _navigationService.navigateToLoginView();
      } else {
        print("❌ [SubmitAd] Erreur ${response.statusCode}: ${response.body}");
        _snackbarService.showCustomSnackBar(
          message: "Erreur lors de la publication. Veuillez réessayer.",
          variant: SnackbarType.error,
        );
      }
    } catch (e) {
      print("❌ [SubmitAd] Erreur réseau: $e");
      _snackbarService.showCustomSnackBar(
        message: "Erreur de connexion. Vérifiez votre réseau.",
        variant: SnackbarType.error,
      );
    } finally {
      setBusy(false);
    }
  }

  void navigateToKyc() {
    // Legacy mapping if needed
  }
}
