import 'package:stacked/stacked.dart';

class PriceComparatorViewModel extends BaseViewModel {
  String selectedRegion = "Abidjan, CI";
  String searchQuery = "";
  String currentProduct = "Riz (Sac 50kg)";
  
  // Simulation de données B2C
  final Map<String, dynamic> intelligentSummary = {
    "bestPrice": "24 000 F",
    "avgPrice": "25 500 F",
    "savings": "1 500 F",
    "recommendation": "Fournisseur A (à 2km)"
  };

  final List<Map<String, dynamic>> suppliers = [
    {"name": "Grossiste Market", "price": "24 000 F", "distance": "2.1 km", "match": 98},
    {"name": "Boutique Centrale", "price": "24 500 F", "distance": "0.8 km", "match": 85},
    {"name": "Super U", "price": "25 000 F", "distance": "5.0 km", "match": 75},
  ];

  void setRegion(String region) {
    selectedRegion = region;
    notifyListeners();
  }

  void search(String query) {
    searchQuery = query;
    notifyListeners();
    // Ici on fera l'appel à pgvector via l'API plus tard
  }
}
