import 'dart:convert';
import 'dart:collection';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/app/app.router.dart';
import 'package:promogoai/services/auth_service.dart';
import 'package:promogoai/ui/common/api_constants.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class PreLiveSetupViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _authService = locator<AuthService>();
  
  CameraController? cameraController;
  bool isCameraInitialized = false;

  String liveTitle = "";
  List<Map<String, dynamic>> selectedProducts = [];
  
  final List<String> categories = ["Mode", "Électronique", "Beauté", "Maison", "Divers"];
  String selectedCategory = "Divers";

  final ImagePicker _picker = ImagePicker();

  Future<void> init() async {
    setBusy(true);
    await setupCamera();
    setBusy(false);
  }

  bool _isFrontCamera = true; // Frontale par défaut

  Future<void> setupCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      CameraDescription targetCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == (_isFrontCamera ? CameraLensDirection.front : CameraLensDirection.back),
        orElse: () => cameras.first,
      );

      cameraController = CameraController(
        targetCamera,
        ResolutionPreset.medium,
        enableAudio: true,
      );

      await cameraController!.initialize();
      isCameraInitialized = true;
      notifyListeners();
    } catch (e) {
      print("Erreur Caméra Aperçu: $e");
    }
  }

  void switchCamera() async {
    if (cameraController != null) {
      isCameraInitialized = false;
      notifyListeners();
      await cameraController!.dispose();
    }
    _isFrontCamera = !_isFrontCamera;
    await setupCamera();
  }

  void updateTitle(String value) {
    liveTitle = value;
    notifyListeners();
  }

  void updateCategory(String? value) {
    if (value != null) {
      selectedCategory = value;
      notifyListeners();
    }
  }

  List<dynamic> myCatalogProducts = [];

  Future<void> fetchMyCatalogProducts() async {
    setBusy(true);
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.myAdsEndpoint),
        headers: {
          'Authorization': 'Bearer ${_authService.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is Map && decoded.containsKey('results')) {
          myCatalogProducts = decoded['results'] as List<dynamic>;
        } else if (decoded is List) {
          myCatalogProducts = decoded;
        } else {
          myCatalogProducts = [];
        }
      } else if (response.statusCode == 401) {
        if (await _authService.refreshAccessToken()) {
          return await fetchMyCatalogProducts();
        }
      }
    } catch (e) {
      print("Erreur fetch catalog: $e");
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  void toggleCatalogProduct(Map<String, dynamic> p) {
    final existingIndex = selectedProducts.indexWhere((item) => item['id'] == p['id'].toString());
    if (existingIndex >= 0) {
      selectedProducts.removeAt(existingIndex);
    } else {
      String? imageUrl;
      if (p['images'] != null && p['images'] is List && (p['images'] as List).isNotEmpty) {
        imageUrl = p['images'][0]['image'] as String?;
      } else if (p['image'] != null) {
        imageUrl = p['image'] as String?;
      }

      selectedProducts.add({
        "id": p['id'].toString(),
        "name": p['titre'] ?? p['title'] ?? "Produit",
        "price": "${p['prix'] ?? 200} GHS",
        "image": imageUrl,
        "isFlash": false,
      });
    }
    notifyListeners();
  }

  bool isProductSelected(String id) {
    return selectedProducts.any((item) => item['id'] == id);
  }

  Future<void> selectProducts() async {
    await fetchMyCatalogProducts();
  }

  Future<void> takeFlashPhoto() async {
    // 1. Choix de la source
    final sourceResponse = await _dialogService.showDialog(
      title: "Nouvel Article",
      description: "Prendre une photo ou choisir dans la galerie ?",
      buttonTitle: "Appareil",
      cancelTitle: "Galerie",
    );

    // Si l'utilisateur clique en dehors de la popup pour annuler, on arrête !
    if (sourceResponse == null) return;

    final ImageSource source = (sourceResponse.confirmed) 
        ? ImageSource.camera 
        : ImageSource.gallery;

    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    
    if (image != null) {
      selectedProducts.add({
        "id": "flash_${DateTime.now().millisecondsSinceEpoch}",
        "name": "Produit Flash #${selectedProducts.length + 1}", 
        "price": "200", 
        "imagePath": image.path,
        "isFlash": true,
      });
      notifyListeners();
    }
  }

  Future<void> startLive() async {
    if (liveTitle.isEmpty) {
      await _dialogService.showDialog(title: "Erreur", description: "Veuillez donner un titre à votre live.");
      return;
    }

    setBusy(true);
    try {
      // 1. VÉRIFICATION DE LA SESSION (Auto-refresh)
      // On utilise fetchUserProfile qui a déjà la logique de rafraîchissement automatique intégrée
      bool sessionValid = await _authService.fetchUserProfile();
      
      if (!sessionValid) {
        setBusy(false);
        if (!_authService.isLogged) {
          await _dialogService.showDialog(
            title: "Session expirée",
            description: "Votre session a expiré. Veuillez vous reconnecter pour continuer.",
          );
          // Redirection vers l'écran de login
          _navigationService.clearStackAndShow<dynamic>(Routes.loginView);
        } else {
          await _dialogService.showDialog(
            title: "Erreur Connexion",
            description: "Impossible de joindre le serveur. Veuillez vérifier votre connexion Internet.",
          );
        }
        return;
      }

      // 2. CRÉATION ATOMIQUE (Live + Produits + Images en une seule fois)
      final uri = Uri.parse(ApiConstants.createLiveEndpoint);
      var request = CustomMultipartRequest('POST', uri);
      
      request.headers['Authorization'] = 'Bearer ${_authService.accessToken}';
      
      // Infos du Live
      request.fields['title'] = liveTitle;
      request.fields['description'] = "Live Commerce via PROMOGO";
      request.fields['status'] = "PLANNED";

      final catalogProducts = selectedProducts.where((p) => !p['id'].toString().startsWith('flash_')).toList();
      final flashProducts = selectedProducts.where((p) => p['id'].toString().startsWith('flash_')).toList();

      // Ajout des IDs du catalogue
      for (var p in catalogProducts) {
        request.fields['product_ids'] = p['id'].toString(); 
      }

      // Ajout des produits FLASH avec leurs images
      for (int i = 0; i < flashProducts.length; i++) {
        final p = flashProducts[i];
        request.fields['flash_name_$i'] = (p['name'] as String?) ?? "Produit Flash";
        // Si le prix est "À négocier" ou vide, on envoie "0"
        final String price = ((p['price'] as String?) ?? "0").replaceAll(RegExp(r'[^0-9.]'), '');
        request.fields['flash_price_$i'] = price.isEmpty ? "0" : price;
        
        if (p['imagePath'] != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'flash_image_$i',
            p['imagePath'] as String,
          ));
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final liveData = jsonDecode(response.body);
        final String realLiveId = liveData['id'].toString();

        // On récupère les produits officiels retournés par le serveur
        List<Map<String, dynamic>> officialProducts = [];
        if (liveData['products'] != null) {
          final List<dynamic> prodList = liveData['products'] as List<dynamic>;
          officialProducts = prodList.map((item) {
             final Map<String, dynamic> p = Map<String, dynamic>.from(item as Map);
             if (p['product'] != null && p['product_details'] != null) {
                 final details = p['product_details'] as Map<String, dynamic>;
                 final images = details['images'] as List<dynamic>;
                 return {
                    "id": p['product'].toString(),
                    "name": details['title'] as String?,
                    "price": details['prix'].toString(),
                    "image": images.isNotEmpty ? images[0]['image'] as String? : null,
                    "isFlash": false,
                 };
             } else {
                 return {
                    "id": p['id'].toString(),
                    "name": p['name'] as String?,
                    "price": p['price'].toString(),
                    "image": p['image'] as String?, 
                    "isFlash": true,
                 };
             }
          }).cast<Map<String, dynamic>>().toList();
        }

        print("🚀 Live créé atomiquement avec succès ! ID: $realLiveId");

        // 3. FERMETURE DE LA CAMERA LOCALE POUR LIBÉRER LE MATÉRIEL
        if (cameraController != null) {
          isCameraInitialized = false;
          notifyListeners();
          await cameraController!.dispose();
          cameraController = null;
          // IMPORTANT: Délai indispensable pour que le système d'exploitation Android libère physiquement le capteur
          await Future<void>.delayed(const Duration(milliseconds: 600));
        }

        // 4. NAVIGATION VERS LE BROADCASTER (Remplacement pour ne pas empiler)
        await _navigationService.replaceWithLiveBroadcasterView(
          liveId: realLiveId,
          initialProducts: officialProducts.isNotEmpty ? officialProducts : selectedProducts,
        );
      } else {
        await _dialogService.showDialog(
          title: "Erreur Serveur",
          description: "Impossible de créer le live. Détails: ${response.body}",
        );
      }
    } catch (e) {
      print("Erreur lancement live: $e");
      await _dialogService.showDialog(title: "Erreur", description: "Une erreur est survenue lors du lancement.");
    } finally {
      setBusy(false);
    }
  }

  void editProduct(int index) async {
    final product = selectedProducts[index];
    
    // On simule une saisie (Dans une version finale, on utiliserait un CustomDialog avec deux TextFields)
    final response = await _dialogService.showDialog(
      title: "Modifier le produit",
      description: "Modification de : ${product['name']}\n(Nom et Prix)",
      buttonTitle: "Enregistrer",
      cancelTitle: "Annuler",
    );

    if (response?.confirmed ?? false) {
      // Pour le test, on change juste le nom légèrement pour montrer que ça marche
      selectedProducts[index]['name'] = "${product['name']} (Modifié)";
      notifyListeners();
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }
}

class MultiValueMap extends MapBase<String, String> {
  final List<MapEntry<String, String>> _entries = [];

  @override
  String? operator [](Object? key) {
    for (var entry in _entries.reversed) {
      if (entry.key == key) return entry.value;
    }
    return null;
  }

  @override
  void operator []=(String key, String value) {
    _entries.add(MapEntry(key, value));
  }

  @override
  void clear() {
    _entries.clear();
  }

  @override
  Iterable<String> get keys => _entries.map((e) => e.key).toSet();

  @override
  String? remove(Object? key) {
    String? lastValue;
    _entries.removeWhere((entry) {
      if (entry.key == key) {
        lastValue = entry.value;
        return true;
      }
      return false;
    });
    return lastValue;
  }

  @override
  void forEach(void Function(String key, String value) action) {
    for (var entry in _entries) {
      action(entry.key, entry.value);
    }
  }

  @override
  Iterable<MapEntry<String, String>> get entries => _entries;

  @override
  int get length => _entries.length;
}

class CustomMultipartRequest extends http.MultipartRequest {
  final Map<String, String> _customFields = MultiValueMap();

  CustomMultipartRequest(String method, Uri url) : super(method, url);

  @override
  Map<String, String> get fields => _customFields;
}
