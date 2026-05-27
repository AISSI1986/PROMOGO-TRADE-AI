import 'package:promogoai/models/subscription_plan.dart';
import 'package:promogoai/ui/common/api_constants.dart';

class Product {
  final int? id;
  final int? sellerId;
  final int? categoryId;
  String name;
  final String price;
  final String imageUrl;
  final List<String> gallery;
  String description;
  final String? location;
  final String sellerName;
  final String sellerPhone;
  final double rating;
  final int reviewsCount;
  final SubscriptionPlan? plan; // L'abonnement du vendeur
  final String originalLanguage;
  final bool canShowWhatsapp;
  final bool canShowPhone;
  final bool hasPremiumVisibility;
  final String? planName;

  Product({
    this.id,
    this.sellerId,
    this.categoryId,
    required this.name,
    required this.price,
    required this.imageUrl,
    List<String>? gallery,
    required this.description,
    this.location,
    this.sellerName = 'Vendeur Certifié',
    this.sellerPhone = '',
    this.rating = 4.8,
    this.reviewsCount = 124,
    this.plan,
    this.originalLanguage = 'fr',
    this.canShowWhatsapp = false,
    this.canShowPhone = false,
    this.hasPremiumVisibility = false,
    this.planName,
  }) : gallery = gallery ?? [imageUrl];

  factory Product.fromJson(Map<String, dynamic> json) {
    String imgUrl = '';
    List<String> gal = [];
    
    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      final imagesList = json['images'] as List;
      String rawUrl = imagesList[0]['image'] as String;
      
      // Si l'URL est relative (commence par /), on ajoute le host du serveur
      if (rawUrl.startsWith('/')) {
        imgUrl = '${ApiConstants.djangoRootUrl}$rawUrl';
      } else if (rawUrl.contains('/media/')) {
        // --- NOUVEAU : Solution universelle anti-bug d'URL ---
        // Coupe n'importe quel domaine/IP erroné (10.0.2.2, 192.168, etc.) 
        // et le remplace par la racine de l'API de production.
        imgUrl = '${ApiConstants.djangoRootUrl}${rawUrl.substring(rawUrl.indexOf('/media/'))}';
      } else {
        imgUrl = rawUrl;
      }
      
      gal = imagesList.map((img) {
        String u = img['image'] as String;
        if (u.startsWith('/')) {
          return '${ApiConstants.djangoRootUrl}$u';
        } else if (u.contains('/media/')) {
          return '${ApiConstants.djangoRootUrl}${u.substring(u.indexOf('/media/'))}';
        }
        return u;
      }).toList();
    }

    String priceStr = '';
    if (json['prix'] != null) {
      priceStr = '${json['prix']} F CFA';
    }

    final sub = json['active_subscription'];
    final String? pName = sub != null ? sub['plan_details']['nom'] as String? : null;

    return Product(
      id: json['id'] as int?,
      sellerId: json['seller'] as int?,
      categoryId: json['categorie'] as int?,
      name: json['title'] ?? 'Sans Titre',
      price: priceStr,
      imageUrl: imgUrl,
      gallery: gal.isEmpty ? [''] : gal,
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      sellerName: json['seller_name'] ?? json['seller_username'] ?? 'Vendeur de la plateforme',
      sellerPhone: json['seller_phone'] ?? '',
      originalLanguage: json['language'] ?? 'fr',
      canShowWhatsapp: json['can_show_whatsapp'] ?? false,
      canShowPhone: json['can_show_phone'] ?? false,
      hasPremiumVisibility: json['has_premium_visibility'] ?? false,
      planName: pName,
    );
  }
}
