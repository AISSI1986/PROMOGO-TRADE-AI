import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../models/rfq_recommendation_model.dart';
import 'package:promogoai/ui/views/demande_devis/form_devis_view.dart';

class DemandeDevisViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  String _rfqText = '';
  String get rfqText => _rfqText;

  bool _isAiEnabled = true;
  bool get isAiEnabled => _isAiEnabled;

  void updateRfqText(String value) {
    _rfqText = value;
    notifyListeners();
  }

  void toggleAi(bool? value) {
    _isAiEnabled = value ?? false;
    notifyListeners();
  }

  void goBack() => _navigationService.back();

  void navigateToForm(BuildContext context) {
    print('Navigating to FormDevisView using standard Navigator...');
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const FormDevisView()),
    );
  }

  final List<RfqRecommendation> historyRecommendations = [
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

  final List<RfqRecommendation> suggestedRecommendations = [
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
