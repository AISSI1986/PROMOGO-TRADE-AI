import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../models/rfq_recommendation_model.dart';
import '../../../services/ad_service.dart';
import '../../../services/local_storage_service.dart';
import 'package:promogoai/ui/views/demande_devis/form_devis_view.dart';

class DemandeDevisViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _adService = locator<AdService>();
  final _localStorageService = locator<LocalStorageService>();

  List<RfqRecommendation> _historyRecommendations = [];
  List<RfqRecommendation> get historyRecommendations => _historyRecommendations;

  List<RfqRecommendation> _suggestedRecommendations = [];
  List<RfqRecommendation> get suggestedRecommendations => _suggestedRecommendations;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  void goBack() => _navigationService.back();

  Future<void> init() async {
    if (_isInitialized) return;
    setBusy(true);
    try {
      // 1. Charger les annonces réelles via AdService
      if (!_adService.isLoaded) {
        await _adService.loadAds();
      }
      
      // 2. Charger l'historique des devis créés par l'utilisateur
      await loadRfqHistory();
    } catch (e) {
      print("⚠️ [DemandeDevisViewModel] Erreur init: $e");
      _loadStaticFallbacks();
    } finally {
      _isInitialized = true;
      setBusy(false);
    }
  }

  Future<void> loadRfqHistory() async {
    try {
      final List<RfqRecommendation> list = [];
      
      // Essayer de lire le fichier d'historique local
      final data = await _localStorageService.getJson('rfq_history.json');
      if (data != null && data is List) {
        for (var item in data) {
          list.add(RfqRecommendation(
            productName: item['productName'] ?? 'Devis sans titre',
            suppliersCount: item['suppliersCount'] ?? 12,
            customizationTypes: List<String>.from(item['customizationTypes'] ?? ['Personnalisé']),
            imageUrl: item['imageUrl'] ?? 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500&q=80',
          ));
        }
      }

      // Compléter l'historique avec les annonces du AdService si l'historique est court
      final realAds = _adService.ads;
      if (realAds.isNotEmpty) {
        // Prendre les 2 premiers produits réels pour l'historique de recommandations
        final realRecs = realAds.take(2).map((ad) => RfqRecommendation(
          productName: ad.name,
          suppliersCount: (ad.rating * 250).toInt(),
          customizationTypes: ['Logo', 'Emballage', 'Couleurs'],
          imageUrl: ad.imageUrl.isNotEmpty ? ad.imageUrl : 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500&q=80',
        )).toList();
        list.addAll(realRecs);
      }

      _historyRecommendations = list.isEmpty ? _staticHistory : list;

      // Suggestions : prendre les produits suivants du AdService
      if (realAds.length > 2) {
        _suggestedRecommendations = realAds.skip(2).take(4).map((ad) => RfqRecommendation(
          productName: ad.name,
          suppliersCount: (ad.rating * 400).toInt(),
          customizationTypes: ['Dimensions', 'Matériaux', 'Marquage'],
          imageUrl: ad.imageUrl.isNotEmpty ? ad.imageUrl : 'https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=500&q=80',
        )).toList();
      } else {
        _suggestedRecommendations = _staticSuggestions;
      }
    } catch (e) {
      print("⚠️ [DemandeDevisViewModel] Erreur loadRfqHistory: $e");
      _loadStaticFallbacks();
    }
    notifyListeners();
  }

  void _loadStaticFallbacks() {
    _historyRecommendations = _staticHistory;
    _suggestedRecommendations = _staticSuggestions;
  }

  void navigateToForm(BuildContext context, {String? initialDescription, String? initialUnit, int? initialQuantity, String? initialCustomizationType}) {
    print('Navigating to FormDevisView with arguments...');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FormDevisView(
          initialDescription: initialDescription,
          initialUnit: initialUnit,
          initialQuantity: initialQuantity,
          initialCustomizationType: initialCustomizationType,
        ),
      ),
    ).then((_) {
      // Recharger l'historique quand on revient du formulaire
      loadRfqHistory();
    });
  }

  void navigateToFormWithRequest(BuildContext context, String requestType) {
    String description = "";
    String? customType;
    if (requestType.contains("design") || requestType.contains("Design")) {
      description = "Demande de devis pour la personnalisation complète du design de nos produits. Nous recherchons une conception sur-mesure adaptée à notre marque. Veuillez indiquer vos capacités de prototypage et de design 3D.";
      customType = "design";
    } else if (requestType.contains("logo") || requestType.contains("Logo")) {
      description = "Demande de devis pour l'impression de notre logo d'entreprise sur une série de produits. Le logo sera fourni au format vectoriel haute définition (.ai, .svg). Veuillez indiquer les méthodes de marquage disponibles (sérigraphie, broderie, gravure, etc.).";
      customType = "logo";
    } else if (requestType.contains("lot") || requestType.contains("Lot")) {
      description = "Demande de devis pour l'approvisionnement en gros d'un lot important de produits. Nous recherchons des tarifs dégressifs compétitifs avec des délais de livraison rapides.";
      customType = "lot";
    }

    navigateToForm(
      context, 
      initialDescription: description,
      initialQuantity: requestType.contains("lot") || requestType.contains("Lot") ? 500 : 100,
      initialCustomizationType: customType,
    );
  }

  void navigateToFormWithProduct(BuildContext context, RfqRecommendation recommendation) {
    final String description = "Demande de devis concernant : ${recommendation.productName}.\n\nNous souhaitons recevoir des propositions de prix pour la personnalisation suivante :\n- Types requis : ${recommendation.customizationTypes.join(', ')}.\n- Quantité souhaitée : 100 unités.\n\nMerci de spécifier vos délais de fabrication et conditions de livraison.";
    navigateToForm(
      context, 
      initialDescription: description,
      initialQuantity: 100,
      initialCustomizationType: recommendation.customizationTypes.contains('Logo') ? 'logo' : 'design',
    );
  }

  // Fallbacks Statiques
  final List<RfqRecommendation> _staticHistory = [
    RfqRecommendation(
      productName: 'Smartphone 5G',
      suppliersCount: 1715,
      customizationTypes: ['Logo personnalisé', 'Emballage...'],
      imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500&q=80',
    ),
    RfqRecommendation(
      productName: 'Projecteurs',
      suppliersCount: 2412,
      customizationTypes: ['Résolution', 'RAM', 'ROM', 'Plug'],
      imageUrl: 'https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=500&q=80',
    ),
  ];

  final List<RfqRecommendation> _staticSuggestions = [
    RfqRecommendation(
      productName: 'Moulage par injection',
      suppliersCount: 1163,
      customizationTypes: ['Plastique', 'Modèle', 'Fixing'],
      imageUrl: 'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?w=500&q=80',
    ),
    RfqRecommendation(
      productName: 'Stations d\'énergie',
      suppliersCount: 17430,
      customizationTypes: ['Capacité', 'Type de batterie'],
      imageUrl: 'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?w=500&q=80',
    ),
    RfqRecommendation(
      productName: 'Boîtiers équipements',
      suppliersCount: 1871,
      customizationTypes: ['Taille externe', 'Couleur'],
      imageUrl: 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=500&q=80',
    ),
    RfqRecommendation(
      productName: 'Joints d\'étanchéité',
      suppliersCount: 1039,
      customizationTypes: ['Matériel', 'Épaisseur'],
      imageUrl: 'https://images.unsplash.com/photo-1589793463357-5fb8da34f230?w=500&q=80',
    ),
  ];
}
