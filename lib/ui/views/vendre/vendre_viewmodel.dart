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

import 'package:promogoai/services/category_service.dart';
import 'package:promogoai/services/auth_service.dart';
import 'package:promogoai/services/local_storage_service.dart';

class VendreViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _categoryService = locator<CategoryService>();
  final _authService = locator<AuthService>();
  final _snackbarService = locator<SnackbarService>();
  final _localStorageService = locator<LocalStorageService>();
  final _imagePicker = ImagePicker();

  static const String _draftFileName = 'ad_draft.json';
  Timer? _debounceTimer;

  // Categories filtrées pour la recherche
  String _categorySearchQuery = '';
  List<Map<String, dynamic>> get categories => _categoryService.filterCategories(_categorySearchQuery);

  void init() {
    loadDraft();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
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
  
  // Bulk Price
  bool _showBulkPriceForm = false;
  bool get showBulkPriceForm => _showBulkPriceForm;
  
  String? _selectedBulkSize;
  String? get selectedBulkSize => _selectedBulkSize;
  
  List<Map<String, String>> _bulkPrices = [];
  List<Map<String, String>> get bulkPrices => _bulkPrices;

  String? _negotiation;
  String? get negotiation => _negotiation;

  String? _selectedSubscription = 'Free';
  String? get selectedSubscription => _selectedSubscription;

  // Validation
  bool get isTitleValid => _title.length >= 10;
  String get titleError => _title.isEmpty ? '' : 'post_ad.error_title';

  final List<String> bulkSizes = ['2', '5', '10', '20', '50'];
  final List<String> negotiationOptions = ['Yes', 'No', 'Not sure'];

  void setTitle(String value) {
    _title = value;
    saveDraft();
    notifyListeners();
  }

  void setCategory(Map<String, dynamic>? category) {
    if (category != null) {
      _selectedCategory = category['libele'];
      _selectedCategoryId = category['id'];
    } else {
      _selectedCategory = null;
      _selectedCategoryId = null;
    }
    saveDraft();
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    saveDraft();
    notifyListeners();
  }

  void setLocation(String value) {
    _location = value;
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

  void setSubscription(String? value) {
    _selectedSubscription = value;
    saveDraft();
    notifyListeners();
  }

  void setPrice(String value) {
    _price = value;
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

  void setBulkSize(String? value) {
    _selectedBulkSize = value;
    notifyListeners();
  }

  void addBulkPrice(String size, String price) {
    _bulkPrices.add({'size': size, 'price': price});
    _selectedBulkSize = null;
    notifyListeners();
  }

  void removeBulkPrice(int index) {
    _bulkPrices.removeAt(index);
    notifyListeners();
  }

  // SUBMIT AD
  Future<void> submitAd() async {
    // 0. Vérification Authentification
    if (!_authService.isLogged) {
      _snackbarService.showCustomSnackBar(
        message: "Veuillez vous connecter pour publier une annonce.",
        variant: SnackbarType.warning,
      );
      _navigationService.navigateToLoginView();
      return;
    }

    // 1. Validations Locales
    if (_title.isEmpty || _price.isEmpty || _location.isEmpty || _selectedCategoryId == null) {
      _snackbarService.showCustomSnackBar(
        message: "Veuillez remplir tous les champs obligatoires (Titre, Prix, Localisation, Catégorie).",
        variant: SnackbarType.warning,
      );
      return;
    }

    if (_images.isEmpty) {
      _snackbarService.showCustomSnackBar(
        message: "Veuillez ajouter au moins une photo de votre article.",
        variant: SnackbarType.warning,
      );
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

      // Images (Multipart)
      for (var file in _images) {
        request.files.add(await http.MultipartFile.fromPath('uploaded_images', file.path));
      }

      // Envoi
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        _snackbarService.showCustomSnackBar(
          message: "Annonce publiée avec succès ! 🚀",
          variant: SnackbarType.success,
        );
        clearDraft();
        _navigationService.back();
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
