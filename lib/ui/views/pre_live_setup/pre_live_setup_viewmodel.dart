import 'dart:convert';
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

  Future<void> selectProducts() async {
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
        List<dynamic> data;
        
        // CORRECTION : On gère le cas où Django renvoie une Map (pagination) ou une Liste
        if (decoded is Map && decoded.containsKey('results')) {
          data = decoded['results'];
        } else if (decoded is List) {
          data = decoded;
        } else {
          data = [];
        }
        
        if (data.isEmpty) {
          await _dialogService.showDialog(
            title: "Catalogue Vide",
            description: "Vous n'avez pas de produits. Publiez-en d'abord !",
          );
          return;
        }

        // On ajoute les produits au live (on pourrait ici ouvrir une vraie liste de sélection)
        for (var p in data.take(5)) { // On prend les 5 premiers pour le test
          selectedProducts.add({
            "id": p['id'].toString(),
            "name": p['titre'] ?? "Produit",
            "price": "${p['prix']} GHS",
            "isFlash": false,
          });
        }
      } else if (response.statusCode == 401) {
        if (await _authService.refreshAccessToken()) return await selectProducts();
      }
    } catch (e) {
      print("Erreur: $e");
    } finally {
      notifyListeners();
    }
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

    final XFile? image = await _picker.pickImage(source: source);
    
    if (image != null) {
      // 2. OUVERTURE DU FORMULAIRE (Simulation de Bottom Sheet via Dialog pour le moment)
      // Je vais mettre en place une logique qui simule la saisie
      // Dans la vue, je vais ajouter un vrai champ pour cela
      
      selectedProducts.add({
        "id": "flash_${DateTime.now().millisecondsSinceEpoch}",
        "name": "Produit Flash #${selectedProducts.length + 1}", 
        "price": "À négocier",
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
        await _dialogService.showDialog(
          title: "Session expirée",
          description: "Votre session a expiré. Veuillez vous reconnecter pour continuer.",
        );
        // Redirection vers l'écran de login
        _navigationService.clearStackAndShow(Routes.loginView);
        return;
      }

      // 2. CRÉATION ATOMIQUE (Live + Produits + Images en une seule fois)
      final uri = Uri.parse(ApiConstants.createLiveEndpoint);
      var request = http.MultipartRequest('POST', uri);
      
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
        request.fields['flash_name_$i'] = p['name'] ?? "Produit Flash";
        // Si le prix est "À négocier" ou vide, on envoie "0"
        String price = (p['price'] ?? "0").replaceAll(RegExp(r'[^0-9.]'), '');
        request.fields['flash_price_$i'] = price.isEmpty ? "0" : price;
        
        if (p['imagePath'] != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'flash_image_$i',
            p['imagePath'],
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
          final List<dynamic> prodList = liveData['products'];
          officialProducts = prodList.map((item) {
             final Map<String, dynamic> p = Map<String, dynamic>.from(item);
             if (p['product'] != null && p['product_details'] != null) {
                return {
                   "id": p['product'].toString(),
                   "name": p['product_details']['title'],
                   "price": p['product_details']['prix'].toString(),
                   "image": p['product_details']['images'].isNotEmpty ? p['product_details']['images'][0]['image'] : null,
                   "isFlash": false,
                };
             } else {
                return {
                   "id": p['id'].toString(),
                   "name": p['name'],
                   "price": p['price'].toString(),
                   "image": p['image'], 
                   "isFlash": true,
                };
             }
          }).toList();
        }

        print("🚀 Live créé atomiquement avec succès ! ID: $realLiveId");

        // 3. FERMETURE DE LA CAMERA LOCALE POUR LIBÉRER LE MATÉRIEL
        if (cameraController != null) {
          isCameraInitialized = false;
          notifyListeners();
          await cameraController!.dispose();
          cameraController = null;
          // IMPORTANT: Délai indispensable pour que le système d'exploitation Android libère physiquement le capteur
          await Future.delayed(const Duration(milliseconds: 600));
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
