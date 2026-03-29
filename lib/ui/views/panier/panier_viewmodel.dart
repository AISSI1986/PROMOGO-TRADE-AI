import 'package:stacked/stacked.dart';

class CartItem {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String storeName;
  int quantity;
  bool isSelected;

  CartItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.storeName,
    this.quantity = 1,
    this.isSelected = true,
  });
}

class Product {
  final String id;
  final String name;
  final String imageUrl;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
  });
}

class PanierViewModel extends BaseViewModel {
  List<CartItem> _cartItems = [
    CartItem(
      id: '1',
      name: 'iPhone 15 Pro Max - 256GB - Titanium Blue',
      imageUrl: 'https://images.unsplash.com/photo-1696446701796-da61225697cc?w=400',
      price: 1199.00,
      storeName: 'Apple Official Store',
      quantity: 1,
      isSelected: true,
    ),
    CartItem(
      id: '2',
      name: 'MacBook Air M2 - 13 inch - Space Gray',
      imageUrl: 'https://images.unsplash.com/photo-1611186871348-b1ec696e52c9?w=400',
      price: 999.00,
      storeName: 'Apple Official Store',
      quantity: 1,
      isSelected: true,
    ),
    CartItem(
      id: '3',
      name: 'Samsung Galaxy Watch 6 classic',
      imageUrl: 'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=400',
      price: 299.00,
      storeName: 'Samsung Electronics',
      quantity: 2,
      isSelected: false,
    ),
    CartItem(
      id: '4',
      name: 'Nike Air Max 270 - White/Volt/Black',
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
      price: 150.00,
      storeName: 'Nike Sportswear',
      quantity: 1,
      isSelected: true,
    ),
  ];

  List<Product> _savedItems = [
    Product(
      id: 's1',
      name: 'AirPods Pro (2nd Generation)',
      imageUrl: 'https://images.unsplash.com/photo-1588423770110-b1d702306790?w=400',
      price: 249.00,
    ),
    Product(
      id: 's2',
      name: 'iPad Pro 11-inch M2 Chip',
      imageUrl: 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400',
      price: 799.00,
    ),
  ];

  List<CartItem> get cartItems => _cartItems;
  List<Product> get savedItems => _savedItems;

  bool get isAllSelected => _cartItems.every((item) => item.isSelected);

  double get totalPrice {
    return _cartItems
        .where((item) => item.isSelected)
        .fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  int get selectedCount => _cartItems.where((item) => item.isSelected).length;

  void toggleItemSelection(String id) {
    final index = _cartItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      _cartItems[index].isSelected = !_cartItems[index].isSelected;
      notifyListeners();
    }
  }

  void toggleAllSelection(bool? value) {
    if (value != null) {
      for (var item in _cartItems) {
        item.isSelected = value;
      }
      notifyListeners();
    }
  }

  void updateQuantity(String id, int delta) {
    final index = _cartItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      final newQuantity = _cartItems[index].quantity + delta;
      if (newQuantity >= 1) {
        _cartItems[index].quantity = newQuantity;
        notifyListeners();
      }
    }
  }

  void removeItem(String id) {
    _cartItems.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void moveToCart(String id) {
    final index = _savedItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      final product = _savedItems[index];
      _cartItems.add(CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: product.name,
        imageUrl: product.imageUrl,
        price: product.price,
        storeName: 'Unknown Store',
      ));
      _savedItems.removeAt(index);
      notifyListeners();
    }
  }

  void deleteSavedItem(String id) {
    _savedItems.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}
