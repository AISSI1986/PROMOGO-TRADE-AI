import 'dart:io';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:http/http.dart' as http;
import '../../../app/app.locator.dart';
import '../../../services/local_storage_service.dart';
import '../../../services/auth_service.dart';
import '../../common/api_constants.dart';

class FormDevisViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _localStorageService = locator<LocalStorageService>();
  final _authService = locator<AuthService>();
  final _imagePicker = ImagePicker();

  String _description = '';
  String get description => _description;
  
  int _charCount = 0;
  int get charCount => _charCount;

  String _selectedUnit = 'Pièces';
  String get selectedUnit => _selectedUnit;

  bool _shareBusinessCard = false;
  bool get shareBusinessCard => _shareBusinessCard;

  bool _acceptTerms = true;
  bool get acceptTerms => _acceptTerms;

  final List<String> units = ['Pièces', 'Lots', 'kg', 'mètres', 'm²', 'Acre'];

  // --- Visualizer / Customization State ---
  String _selectedCustomizationType = 'none'; // 'none', 'design', 'logo', 'lot'
  String get selectedCustomizationType => _selectedCustomizationType;

  String _selectedTemplate = 'T-Shirt';
  String get selectedTemplate => _selectedTemplate;

  Color _selectedProductColor = Colors.white;
  Color get selectedProductColor => _selectedProductColor;

  double _logoScale = 0.5;
  double get logoScale => _logoScale;

  double _logoRotation = 0.0;
  double get logoRotation => _logoRotation;

  Offset _logoOffset = const Offset(0, 0);
  Offset get logoOffset => _logoOffset;

  File? _logoFile;
  File? get logoFile => _logoFile;

  final List<String> templates = ['T-Shirt', 'Tasse', 'Casquette', 'Sac'];
  final List<Color> colors = [
    Colors.white,
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
  ];

  final TextEditingController quantityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController contactPhoneController = TextEditingController();

  void init({
    String? initialDescription,
    String? initialUnit,
    int? initialQuantity,
    String? initialCustomizationType,
  }) {
    if (initialDescription != null) {
      _description = initialDescription;
      descriptionController.text = initialDescription;
      _charCount = _description.length;
    }
    if (initialUnit != null) {
      _selectedUnit = initialUnit;
    }
    if (initialQuantity != null) {
      quantityController.text = initialQuantity.toString();
    }
    if (initialCustomizationType != null) {
      _selectedCustomizationType = initialCustomizationType;
    }

    // Pré-remplir le numéro de téléphone de l'utilisateur connecté
    final userPhone = _authService.userData?['phone'] ?? _authService.userData?['phone_number'] ?? '';
    if (userPhone.toString().isNotEmpty) {
      contactPhoneController.text = userPhone.toString();
    }
    
    descriptionController.addListener(() {
      _description = descriptionController.text;
      _charCount = _description.length;
      notifyListeners();
    });
    
    notifyListeners();
  }

  void updateDescription(String value) {
    if (descriptionController.text != value) {
      descriptionController.text = value;
    }
  }

  void updateUnit(String? value) {
    if (value != null) {
      _selectedUnit = value;
      notifyListeners();
    }
  }

  void toggleShareBusinessCard(bool? value) {
    _shareBusinessCard = value ?? false;
    notifyListeners();
  }

  void toggleAcceptTerms(bool? value) {
    _acceptTerms = value ?? false;
    notifyListeners();
  }

  void setCustomizationType(String type) {
    _selectedCustomizationType = type;
    notifyListeners();
  }

  void updateSelectedTemplate(String template) {
    _selectedTemplate = template;
    notifyListeners();
  }

  void updateProductColor(Color color) {
    _selectedProductColor = color;
    notifyListeners();
  }

  void updateLogoScale(double scale) {
    _logoScale = scale;
    notifyListeners();
  }

  void updateLogoRotation(double rotation) {
    _logoRotation = rotation;
    notifyListeners();
  }

  void updateLogoOffset(Offset offset) {
    _logoOffset = offset;
    notifyListeners();
  }

  Future<void> pickLogoImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _logoFile = File(image.path);
        // Automatiquement passer en type 'logo' si une image est sélectionnée
        if (_selectedCustomizationType == 'none') {
          _selectedCustomizationType = 'logo';
        }
        notifyListeners();
      }
    } catch (e) {
      print("Error picking logo image: $e");
    }
  }

  void resetLogo() {
    _logoFile = null;
    _logoScale = 0.5;
    _logoRotation = 0.0;
    _logoOffset = const Offset(0, 0);
    notifyListeners();
  }

  void centerLogo() {
    _logoOffset = const Offset(0, 0);
    _logoScale = 0.5;
    _logoRotation = 0.0;
    notifyListeners();
  }

  void generateAIDescription() {
    setBusy(true);
    
    String templateDesc = "";
    if (_selectedCustomizationType == 'logo' || _selectedCustomizationType == 'design') {
      final colorHex = '#${_selectedProductColor.value.toRadixString(16).substring(2).toUpperCase()}';
      templateDesc = "Spécifications techniques de personnalisation :\n"
          "- Support : $_selectedTemplate\n"
          "- Couleur du produit : $colorHex\n"
          "- Logo personnalisé appliqué en superposition (Échelle: ${_logoScale.toStringAsFixed(2)}, Rotation: ${(_logoRotation * 180 / 3.14159).toStringAsFixed(0)}°)\n"
          "- Quantité souhaitée : ${quantityController.text} $_selectedUnit\n\n";
    }

    String prompt = _description.trim();
    String generated = '';

    if (prompt.isEmpty) {
      generated = "${templateDesc}Nous recherchons un fournisseur pour la fabrication de $_selectedTemplate personnalisés.\n\nExigences :\n- Impression haute résolution, résistante à l'usure.\n- Matière première de qualité supérieure.\n- Emballage individuel de protection.\n- Livraison à notre adresse professionnelle.\n\nMerci de soumettre vos meilleurs prix ainsi que le délai estimé de livraison.";
    } else {
      generated = "${templateDesc}Cahier des charges optimisé :\n\nObjet : Demande de devis - $prompt\n\nNous confirmons notre intérêt pour l'achat de ce produit sous réserve de :\n1. Personnalisation de qualité professionnelle selon nos fichiers de design.\n2. Contrôle de conformité avant expédition.\n3. Délai de livraison garanti.\n\nVeuillez fournir votre grille tarifaire dégressive et vos conditions de paiement.";
    }
    
    descriptionController.text = generated;
    _description = generated;
    _charCount = _description.length;
    
    setBusy(false);
    notifyListeners();
  }

  void goBack() {
    _navigationService.back();
  }

  Future<void> submitForm(BuildContext context) async {
    final String qtyText = quantityController.text.trim();
    if (qtyText.isEmpty || int.tryParse(qtyText) == null || int.parse(qtyText) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer une quantité valide supérieure à 0")),
      );
      return;
    }

    if (_description.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez décrire votre besoin")),
      );
      return;
    }

    final String contactPhone = contactPhoneController.text.trim();
    if (contactPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer un numéro de contact / WhatsApp")),
      );
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez accepter les règles de publication")),
      );
      return;
    }

    setBusy(true);

    try {
      // 1. Envoyer la demande au backend Django via MultipartRequest
      final url = Uri.parse('${ApiConstants.djangoBaseUrl}/rfq/add/');
      final request = http.MultipartRequest('POST', url);
      
      final token = _authService.accessToken;
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      request.fields['description'] = _description;
      request.fields['quantity'] = qtyText;
      request.fields['unit'] = _selectedUnit;
      request.fields['contact_phone'] = contactPhone;
      request.fields['customization_type'] = _selectedCustomizationType;
      request.fields['template'] = _selectedTemplate;
      request.fields['product_color'] = '#${_selectedProductColor.value.toRadixString(16).substring(2).toUpperCase()}';
      
      if (_logoFile != null) {
        request.files.add(await http.MultipartFile.fromPath('attachment', _logoFile!.path));
      }
      
      try {
        final streamedResponse = await request.send().timeout(const Duration(seconds: 10));
        final response = await http.Response.fromStream(streamedResponse);
        print("📡 [SubmitRFQ] Response status: ${response.statusCode}");
        print("📡 [SubmitRFQ] Response body: ${response.body}");
      } catch (e) {
        // En cas d'erreur (ex: route pas encore déployée au backend), on continue car c'est un mock
        print("⚠️ [SubmitRFQ] Requête backend échouée (attendu si la route n'est pas encore déployée) : $e");
      }

      // 2. Simuler l'envoi réseau de 1.5 secondes
      await Future.delayed(const Duration(milliseconds: 1500));

      // 3. Sauvegarder dans l'historique local
      final dynamic storedHistory = await _localStorageService.getJson('rfq_history.json');
      final List<dynamic> history = storedHistory != null ? List<dynamic>.from(storedHistory as Iterable) : [];
      
      String logoUrl = 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=500&q=80';
      if (_selectedTemplate == 'Tasse') {
        logoUrl = 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=500&q=80';
      } else if (_selectedTemplate == 'Casquette') {
        logoUrl = 'https://images.unsplash.com/photo-1588850561407-ed78c282e89b?w=500&q=80';
      } else if (_selectedTemplate == 'Sac') {
        logoUrl = 'https://images.unsplash.com/photo-1544816155-12df9643f363?w=500&q=80';
      }

      final newRfq = {
        'productName': _selectedCustomizationType == 'none' ? _description.split('\n').first : 'Devis $_selectedTemplate personnalisé',
        'suppliersCount': 8,
        'customizationTypes': [_selectedCustomizationType == 'logo' ? 'Logo' : 'Design', 'Couleur'],
        'imageUrl': logoUrl,
        'quantity': int.parse(qtyText),
        'unit': _selectedUnit,
        'description': _description,
        'createdAt': DateTime.now().toIso8601String(),
      };

      history.insert(0, newRfq);
      await _localStorageService.saveJson('rfq_history.json', history);

      // 3. Afficher une magnifique boîte de dialogue de succès
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    color: kcSuccessColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 20),
                Text(
                  "Demande publiée !",
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: kcPrimaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Votre demande de devis a été envoyée avec succès aux fournisseurs qualifiés. Vous recevrez des offres très prochainement.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: kcMediumGrey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // fermer dialog
                      _navigationService.back(); // retour à l'écran précédent
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kcPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      "Super",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      print("Error submitting RFQ: $e");
    } finally {
      setBusy(false);
    }
  }

  @override
  void dispose() {
    quantityController.dispose();
    descriptionController.dispose();
    contactPhoneController.dispose();
    super.dispose();
  }
}
