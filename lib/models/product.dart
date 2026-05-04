import 'package:promogoai/models/subscription_plan.dart';
import 'package:promogoai/ui/common/api_constants.dart';

class Product {
  String name;
  final String price;
  final String imageUrl;
  final List<String> gallery;
  String description;
  final String sellerName;
  final double rating;
  final int reviewsCount;
  final SubscriptionPlan? plan; // L'abonnement du vendeur
  final String originalLanguage; 

  Product({
    required this.name,
    required this.price,
    required this.imageUrl,
    List<String>? gallery,
    required this.description,
    this.sellerName = 'Vendeur Certifié',
    this.rating = 4.8,
    this.reviewsCount = 124,
    this.plan,
    this.originalLanguage = 'fr',
  }) : gallery = gallery ?? [imageUrl];

  factory Product.fromJson(Map<String, dynamic> json) {
    String imgUrl = '';
    List<String> gal = [];
    
    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      final imagesList = json['images'] as List;
      String rawUrl = imagesList[0]['image'] as String;
      
      // Si l'URL est relative (commence par /), on ajoute le host du serveur
      if (rawUrl.startsWith('/')) {
        imgUrl = 'https://${ApiConstants.djangoServerHost}$rawUrl';
      } else {
        imgUrl = rawUrl;
      }
      
      gal = imagesList.map((img) {
        String u = img['image'] as String;
        return u.startsWith('/') ? 'https://${ApiConstants.djangoServerHost}$u' : u;
      }).toList();
    }

    String priceStr = '';
    if (json['prix'] != null) {
      priceStr = '${json['prix']} F CFA';
    }

    return Product(
      name: json['title'] ?? 'Sans Titre',
      price: priceStr,
      imageUrl: imgUrl,
      gallery: gal.isEmpty ? [''] : gal,
      description: json['description'] ?? '',
      sellerName: 'Vendeur de la plateforme', 
      originalLanguage: json['language'] ?? 'fr',
      // On pourra ajuster 'plan' plus tard en fonction de 'active_subscription'
    );
  }
}
