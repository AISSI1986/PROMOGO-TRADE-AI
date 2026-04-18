import 'package:promogoai/models/product.dart';
import 'package:stacked/stacked.dart';

class ProductDetailViewModel extends BaseViewModel {
  final Product product;
  int _selectedImageIndex = 0;
  int get selectedImageIndex => _selectedImageIndex;

  String get currentImageUrl => product.gallery[_selectedImageIndex];
  
  ProductDetailViewModel({required this.product});

  void setSelectedImage(int index) {
    _selectedImageIndex = index;
    notifyListeners();
  }

  void onChatWithSeller() {
    // Sera implémenté plus tard comme demandé
    print('Discuter avec le vendeur: ${product.sellerName}');
  }
}
