import 'package:promogoai/models/subscription_plan.dart';

class Product {
  final String name;
  final String price;
  final String imageUrl;
  final List<String> gallery;
  final String description;
  final String sellerName;
  final double rating;
  final int reviewsCount;
  final SubscriptionPlan? plan; // L'abonnement du vendeur

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
  }) : gallery = gallery ?? [imageUrl];

  factory Product.fromJson(Map<String, dynamic> json) {
    String imgUrl = '';
    List<String> gal = [];
    
    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      final imagesList = json['images'] as List;
      // Django peut renvoyer une URL relative (ex: /media/ads_images/...) ou absolue.
      // Il faut s'assurer que c'est une URL complète. Le host sera ajouté dans le service si besoin,
      // mais en général, Django REST framework renvoie l'URL absolue si la requête a le bon host.
      imgUrl = imagesList[0]['image'] as String;
      gal = imagesList.map((img) => img['image'] as String).toList();
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
      // On pourra ajuster 'plan' plus tard en fonction de 'active_subscription'
    );
  }
}
