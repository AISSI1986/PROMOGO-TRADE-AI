class Product {
  final String name;
  final String price;
  final String imageUrl;
  final List<String> gallery;
  final String description;
  final String sellerName;
  final double rating;
  final int reviewsCount;

  Product({
    required this.name,
    required this.price,
    required this.imageUrl,
    List<String>? gallery,
    required this.description,
    this.sellerName = 'Vendeur Certifié',
    this.rating = 4.8,
    this.reviewsCount = 124,
  }) : gallery = gallery ?? [imageUrl];
}
