import 'dart:async';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/models/product.dart';
import 'package:promogoai/services/ad_service.dart';
import 'package:promogoai/ui/views/product_detail/product_detail_view.dart';

class TopRankingViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _adService = AdService();

  String _selectedCategory = "Tous";
  String get selectedCategory => _selectedCategory;

  // Filtre actif : 0 = Tous, 1 = Ventes à la Une, 2 = Les plus populaires, 3 = Mieux notés
  int _activeFilterIndex = 0;
  int get activeFilterIndex => _activeFilterIndex;

  bool _isFiltering = false;
  bool get isFiltering => _isFiltering;

  List<Product> get allAds => _adService.ads;

  List<Product> get filteredAds {
    List<Product> list = List.from(allAds);

    // 1. Filtrage par catégorie
    if (_selectedCategory != "Tous" && _selectedCategory.isNotEmpty) {
      list = list.where((ad) => 
        ad.name.toLowerCase().contains(_selectedCategory.toLowerCase()) || 
        ad.description.toLowerCase().contains(_selectedCategory.toLowerCase())
      ).toList();
    }

    // 2. Filtrage par onglet (simulation intelligente de tri/filtrage premium)
    if (_activeFilterIndex == 1) {
      // Ventes à la Une
      list = list.where((ad) => ad.imageUrl.isNotEmpty).toList();
      if (list.length > 2) {
        // Inversion pour simuler une sélection à la une différente
        list = list.reversed.toList();
      }
    } else if (_activeFilterIndex == 2) {
      // Les plus populaires
      list.sort((a, b) => a.name.compareTo(b.name));
    } else if (_activeFilterIndex == 3) {
      // Mieux notés
      list.sort((a, b) => b.name.length.compareTo(a.name.length));
    }

    return list;
  }

  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _triggerShimmer();
  }

  void setFilterIndex(int index) {
    if (_activeFilterIndex == index) return;
    _activeFilterIndex = index;
    _triggerShimmer();
  }

  void _triggerShimmer() {
    _isFiltering = true;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 300), () {
      _isFiltering = false;
      notifyListeners();
    });
  }

  void navigateToProductDetail(Product product) {
    _navigationService.navigateWithTransition(
      ProductDetailView(product: product),
      transitionStyle: Transition.fade,
    );
  }

  void navigateBack() {
    _navigationService.back();
  }
}
