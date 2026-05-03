import 'package:flutter/material.dart';
import 'package:promogoai/models/product.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'product_detail_viewmodel.dart';

class ProductDetailView extends StackedView<ProductDetailViewModel> {
  final Product product;
  const ProductDetailView({Key? key, required this.product}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ProductDetailViewModel viewModel,
    Widget? child,
  ) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Header avec Image (SliverAppBar)
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.45,
                backgroundColor: kcBackgroundColor,
                elevation: 0,
                pinned: true,
                stretch: true,
                leading: const SizedBox.shrink(),
                actions: const [SizedBox.shrink()], // On utilise des boutons custom dans le Stack
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                  ],
                  background: Hero(
                    tag: 'product_${product.name}',
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: viewModel.currentImageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: kcVeryLightGrey,
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                        ),
                        // Overlay dégradé pour la lisibilité
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black26, Colors.transparent, Colors.transparent],
                              stops: [0.0, 0.2, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Contenu Detail
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  transform: Matrix4.translationValues(0, -30, 0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Galerie de miniatures améliorée
                        if (product.gallery.length > 1) ...[
                          _buildMiniGallery(viewModel),
                          verticalSpaceMedium,
                        ],

                        // PRIX ET RATING
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              product.price,
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFE74C3C),
                                fontFamily: 'Outfit',
                              ),
                            ),
                            _buildRatingBadge(),
                          ],
                        ),
                        verticalSpaceTiny,
                        
                        // TITRE DU PRODUIT
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: kcPrimaryColor,
                            height: 1.2,
                          ),
                        ),
                        verticalSpaceMedium,

                        // BADGES DE CARACTERISTIQUES
                        _buildProductFeatures(),
                        verticalSpaceLarge,

                        // SECTION VENDEUR
                        _buildPremiumSellerCard(),
                        verticalSpaceLarge,

                        // DESCRIPTION
                        const Text(
                          "Détails du produit",
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.w800,
                            color: kcPrimaryColor,
                          ),
                        ),
                        verticalSpaceSmall,
                        Text(
                          product.description,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            height: 1.6,
                            letterSpacing: 0.1,
                          ),
                        ),
                        verticalSpaceLarge,

                        // SECTION REASSURANCE / GARANTIES
                        _buildTrustSection(),
                        verticalSpaceLarge,

                        // PRODUITS SIMILAIRES (Titre)
                        const Text(
                          "Vous pourriez aussi aimer",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kcPrimaryColor),
                        ),
                        verticalSpaceMedium,
                        _buildSuggestedProducts(),

                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 3. Boutons d'action supérieurs (Retour, Favoris, Partage)
          _buildTopBarActions(context),

          // 4. Actions de l'abonnement (Barre Basse)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildSubscriptionActions(context, viewModel, bottomPadding),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBarActions(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Retour
          _buildTopIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          // Actions Droite
          Row(
            children: [
              _buildTopIconButton(
                icon: Icons.share_outlined,
                onTap: () {},
              ),
              const SizedBox(width: 12),
              _buildTopIconButton(
                icon: Icons.favorite_border_rounded,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
          ],
        ),
        child: Icon(icon, color: kcPrimaryColor, size: 20),
      ),
    );
  }

  Widget _buildProductFeatures() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFeatureBadge(Icons.location_on_outlined, "Abidjan, CI"),
          const SizedBox(width: 8),
          _buildFeatureBadge(Icons.inventory_2_outlined, "Neuf"),
          const SizedBox(width: 8),
          _buildFeatureBadge(Icons.visibility_outlined, "1.2k vues"),
          const SizedBox(width: 8),
          _buildFeatureBadge(Icons.category_outlined, "Mode"),
          const SizedBox(width: 8),
          _buildFeatureBadge(Icons.balance_outlined, "Comparateur de prix"),
        ],
      ),
    );
  }

  Widget _buildFeatureBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kcVeryLightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: kcMediumGrey),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.w600, 
                color: kcMediumGrey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildTrustItem(Icons.handshake_rounded, "Relation directe Client-Vendeur"),
          const Divider(height: 24, color: Colors.black12),
          _buildTrustItem(Icons.local_shipping_rounded, "Remise en main propre & Livraison"),
          const Divider(height: 24, color: Colors.black12),
          _buildTrustItem(Icons.check_circle_outline_rounded, "Vendeur vérifié par Promogo AI"),
        ],
      ),
    );
  }

  Widget _buildTrustItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2980B9), size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2C3E50), fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestedProducts() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: kcVeryLightGrey,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(child: Icon(Icons.image_outlined, color: Colors.white)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Article Similaire", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text("5 000 F CFA", style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.w900, fontSize: 12)),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniGallery(ProductDetailViewModel viewModel) {
    return SizedBox(
      height: 64,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: product.gallery.length,
        itemBuilder: (context, index) {
          final isSelected = viewModel.selectedImageIndex == index;
          return GestureDetector(
            onTap: () => viewModel.setSelectedImage(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? kcTabIndicatorColor : Colors.grey[200]!,
                  width: 2.5,
                ),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(product.gallery[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRatingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1C40F).withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFF1C40F), size: 20),
          const SizedBox(width: 4),
          Text(
            '${product.rating}',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF7D6608)),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSellerCard() {
    const bool isVerified = true; 

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFFE9ECEF),
                child: Icon(Icons.person_rounded, color: Colors.white, size: 34),
              ),
              if (isVerified)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.verified_rounded, color: Color(0xFF3498DB), size: 20),
                  ),
                ),
            ],
          ),
          horizontalSpaceMedium,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.sellerName,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: kcPrimaryColor),
                ),
                const SizedBox(height: 2),
                Text(
                  isVerified ? "Vendeur Premium Certifié" : "Vendeur Particulier",
                  style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: kcPrimaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text("Profil", style: TextStyle(fontWeight: FontWeight.w900, color: kcPrimaryColor, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionActions(BuildContext context, ProductDetailViewModel viewModel, double bottomPadding) {
    const bool canChat = true;
    const bool canWhatsApp = true;
    const bool canCall = true;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (canCall) ...[
            _buildCircleAction(
              icon: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF3498DB), size: 26),
              color: const Color(0xFF3498DB),
              onTap: () {},
            ),
            const SizedBox(width: 12),
          ],
          if (canWhatsApp) ...[
            _buildCircleAction(
              icon: CustomPaint(
                size: const Size(28, 28),
                painter: _WhatsAppPainter(),
              ),
              color: const Color(0xFF25D366),
              onTap: () {},
              useSolidColor: true,
            ),
            const SizedBox(width: 12),
          ],
          if (canChat)
            Expanded(
              child: ElevatedButton(
                onPressed: viewModel.onChatWithSeller,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kcPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 22),
                    SizedBox(width: 10),
                    Text(
                      "Discuter", 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCircleAction({required Widget icon, required Color color, required VoidCallback onTap, bool useSolidColor = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: useSolidColor ? color : color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
          boxShadow: useSolidColor ? [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: icon,
      ),
    );
  }

  @override
  ProductDetailViewModel viewModelBuilder(BuildContext context) =>
      ProductDetailViewModel(product: product);
}

/// DESSIN VECTORIEL DU LOGO WHATSAPP OFFICIEL
class _WhatsAppPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // 1. Dessin de la bulle WhatsApp
    final path = Path();
    path.addOval(Rect.fromLTWH(size.width * 0.05, size.height * 0.05, size.width * 0.9, size.height * 0.9));
    
    // La petite pointe de la bulle
    path.moveTo(size.width * 0.25, size.height * 0.85);
    path.lineTo(size.width * 0.10, size.height * 0.95);
    path.lineTo(size.width * 0.20, size.height * 0.75);
    
    canvas.drawPath(path, paint);

    // 2. Dessin du combiné téléphonique (Silhouette WhatsApp)
    final phonePaint = Paint()
      ..color = const Color(0xFF25D366)
      ..style = PaintingStyle.fill;

    final phonePath = Path();
    // Approximation vectorielle du combiné WhatsApp
    phonePath.moveTo(size.width * 0.35, size.height * 0.35);
    phonePath.quadraticBezierTo(size.width * 0.30, size.height * 0.45, size.width * 0.45, size.height * 0.65);
    phonePath.quadraticBezierTo(size.width * 0.55, size.height * 0.75, size.width * 0.65, size.height * 0.65);
    phonePath.lineTo(size.width * 0.75, size.height * 0.55);
    phonePath.quadraticBezierTo(size.width * 0.80, size.height * 0.45, size.width * 0.65, size.height * 0.35);
    phonePath.close();

    canvas.drawPath(phonePath, phonePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
