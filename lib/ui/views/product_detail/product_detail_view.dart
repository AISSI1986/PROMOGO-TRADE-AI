import 'package:flutter/material.dart';
import 'package:promogoai/models/product.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
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

                        // 1. LOCALISATION ET CROWN BADGE
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: kcMediumGrey, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "${(product.location ?? '').isNotEmpty ? product.location : 'Abidjan, CI'} • 3 hours ago",
                                style: const TextStyle(color: kcMediumGrey, fontSize: 13, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (product.hasPremiumVisibility)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: kcGoldLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.emoji_events_rounded, color: kcSecondaryGold, size: 16),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // 2. TITRE
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: kcPrimaryColor,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // 3. PRIX
                        Text(
                          product.price,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: kcPrimaryColor,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 4. ACTION BUTTONS (Request call back & Call)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: kcPrimaryColor, width: 1.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: Text(
                                  'product_detail.request_callback'.tr(),
                                  style: const TextStyle(color: kcPrimaryColor, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.phone, color: Colors.white, size: 18),
                                label: Text(
                                  'product_detail.call'.tr(),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kcPrimaryColor,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // 6. SPECIFICATIONS GRID
                        _buildSpecsGrid(),
                        const SizedBox(height: 24),

                        // 7. STORE ADDRESS
                        _buildStoreAddress(),
                        const SizedBox(height: 24),

                        // 8. DESCRIPTION CARD
                        _buildDescriptionCard(),
                        const SizedBox(height: 24),

                        // 9. SECONDARY MAKE AN OFFER BUTTON
                        _buildSecondaryOfferButton(),
                        const SizedBox(height: 24),

                        // 10. SELLER CARD (ENRICHIE)
                        _buildEnrichedSellerCard(),
                        const SizedBox(height: 24),

                        // 11. FEEDBACK / REVIEWS
                        _buildFeedbackSection(),
                        const SizedBox(height: 24),

                        // 12. PRODUITS SUGGÉRÉS DYNAMIQUE
                        if (viewModel.loadingSuggestions)
                          const Center(child: CircularProgressIndicator(color: kcPrimaryColor))
                        else if (viewModel.suggestedProducts.isNotEmpty) ...[
                          Text(
                            viewModel.suggestionTitle,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kcPrimaryColor),
                          ),
                          const SizedBox(height: 12),
                          _buildSuggestedProducts(viewModel),
                        ],

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

  // Chat card removed, using the bottom action bar's Discuter button.

  Widget _buildSpecsGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildSpecItem("Type", "Other")),
              Expanded(child: _buildSpecItem("Condition", "Brand New")),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildSpecItem("Brand", "Other")),
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(String key, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: kcPrimaryColor),
        ),
        const SizedBox(height: 2),
        Text(
          key,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStoreAddress() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.store, color: kcMediumGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'product_detail.store_address'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kcPrimaryColor),
            ),
          ),
          Text(
            'product_detail.show'.tr(),
            style: const TextStyle(color: kcPrimaryColor, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, color: kcPrimaryColor),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.description.isNotEmpty ? product.description : "No description provided.",
            style: const TextStyle(fontSize: 14, color: kcPrimaryColor, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryOfferButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.chat_bubble_outline_rounded, color: kcPrimaryColor, size: 18),
        label: Text(
          'product_detail.make_offer'.tr(),
          style: const TextStyle(color: kcPrimaryColor, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: kcPrimaryColor, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildEnrichedSellerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade100,
                ),
                child: const Center(
                  child: Icon(Icons.person, color: kcMediumGrey, size: 30),
                ),
              ),
              const SizedBox(width: 12),
              // Name & Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.sellerName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kcPrimaryColor),
                    ),
                    const SizedBox(height: 4),
                    // Badges row
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _buildSmallBadge(Icons.check, "Verified ID"),
                        _buildSmallBadge(Icons.person_outline, "5+ years on Jiji"),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "online 16 min ago",
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // View Ads Link
              GestureDetector(
                onTap: () {},
                child: Text(
                  'product_detail.view_ads'.tr(args: ['383']),
                  style: const TextStyle(color: kcPrimaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Response time indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, color: Colors.grey.shade600, size: 16),
                const SizedBox(width: 8),
                Text(
                  'product_detail.typically_replies'.tr(),
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSmallBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.blue.shade600),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: Colors.blue.shade700, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'product_detail.feedback_title'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: kcPrimaryColor),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'product_detail.view_all_reviews'.tr(args: ['20']),
                  style: const TextStyle(color: kcPrimaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // User Review
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: kcPrimaryColor,
                child: const Text("P", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Prophet",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: kcPrimaryColor),
                        ),
                        Text(
                          "23/06/25",
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Stars
                    Row(
                      children: List.generate(5, (index) => const Icon(Icons.star, color: kcSecondaryGold, size: 14)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "The guy is very respectful and a calm person n my purchase was very successful even though I merse up but he had faith in me replace the microphone for me and I will recommend him to every one who needs something like musical",
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSuggestedProducts(ProductDetailViewModel viewModel) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: viewModel.suggestedProducts.length,
        itemBuilder: (context, index) {
          final suggestedProduct = viewModel.suggestedProducts[index];
          return GestureDetector(
            onTap: () {
              // Ouvrir le produit suggéré en poussant un nouveau ProductDetailView
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProductDetailView(product: suggestedProduct),
                ),
              );
            },
            child: Container(
              width: 150,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: CachedNetworkImage(
                        imageUrl: suggestedProduct.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: Colors.grey[100]),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[100],
                          child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          suggestedProduct.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          suggestedProduct.price,
                          style: const TextStyle(
                            color: kcPrimaryColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
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
        color: kcSecondaryGold.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: kcSecondaryGold, size: 20),
          const SizedBox(width: 4),
          Text(
            '${product.rating}',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: kcSecondaryGold),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionActions(BuildContext context, ProductDetailViewModel viewModel, double bottomPadding) {
    final bool canChat = true;
    final bool canWhatsApp = product.canShowWhatsapp;
    final bool canCall = product.canShowPhone;

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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'product_detail.discuter'.tr(), 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
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
