import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';
import '../home_viewmodel.dart';
import 'promo_carousel.dart';
import '../../../../models/product.dart';

const List<String> allCategories = [
  "Tous",
  "Électronique grand public",
  "Énergies renouvelables",
  "Maison & Jardin",
  "Sports & Loisirs",
  "Lumière & Éclairage",
  "Sécurité",
  "Appareils électroménagers",
  "Cadeaux & Artisanat",
  "Composants électroniques, Accessoires & Télécom",
  "Produits chimiques",
  "Mère, Enfants & Jouets",
  "Machines industrielles",
  "Équipements électriques & Fournitures",
  "Machines & Équipements commerciaux",
  "Emballage & Impression",
  "Pièces & Accessoires pour véhicules",
  "Agriculture",
  "Matières premières pour Tissus & Textiles",
  "Outils et quincaillerie",
  "Beauté",
  "Bijouterie, Lunetterie, Horlogerie & Accessoires",
  "Vêtements & Accessoires",
  "Santé",
  "Construction & Immobilier",
  "Soins de santé",
  "Hygiène personnelle & Ménage",
  "Meubles",
  "Fournitures & Dispositifs médicaux",
  "Fourniture de bureau & Scolaire"
];

class ProduitsComponent extends ViewModelWidget<HomeViewModel> {
  const ProduitsComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, HomeViewModel viewModel) {
    if (viewModel.isBusy && viewModel.allAds.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(color: kcPrimaryColor),
        ),
      );
    }

    final allAds = viewModel.allAds;
    final catAds = allAds.take(4).toList();
    final offerAds = allAds.skip(4).take(4).toList();
    final customAds = allAds.skip(8).take(4).toList();
    final gridAds = allAds.skip(12).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPromoCards(context, viewModel),
          _buildInfoBanner(),
          _buildCategorySelector(context, viewModel),
          if (catAds.isNotEmpty)
            _buildProductList(
              context, 
              viewModel,
              title: 'home.section_produits_cat'.tr(),
              subtitle: 'home.section_produits_cat_sub'.tr(),
              backgroundGradient: const LinearGradient(
                colors: [kcOchreMuted, Color(0xFFFDF8EE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              titleColor: Colors.black,
              backgroundDecorationIcon: Icons.double_arrow_rounded,
              decorationColor: Colors.orange.shade800,
              decorationRotation: 0.5,
              products: catAds,
            ),
          if (offerAds.isNotEmpty)
            _buildProductList(
              context, 
              viewModel,
              title: 'home.section_meilleures_offres'.tr(),
              subtitle: 'home.section_meilleures_offres_sub'.tr(),
              backgroundGradient: const LinearGradient(
                colors: [kcSageMuted, Color(0xFFF0F5F3)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              titleColor: Colors.black,
              backgroundDecorationIcon: Icons.bolt_rounded,
              decorationColor: Colors.blue.shade800,
              decorationRotation: 0.0,
              products: offerAds,
            ),
          if (customAds.isNotEmpty)
            _buildProductList(
              context, 
              viewModel,
              title: 'home.section_selection_sur_mesure'.tr(),
              subtitle: 'home.section_selection_sur_mesure_sub'.tr(),
              backgroundGradient: const LinearGradient(
                colors: [kcClayMuted, Color(0xFFFEF9F8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              titleColor: Colors.black,
              backgroundDecorationIcon: Icons.auto_awesome_rounded,
              decorationColor: Colors.amber.shade800,
              decorationRotation: -0.2,
              products: customAds,
            ),
          _buildBottomPromoWidgets(),
          if (gridAds.isNotEmpty)
            _buildVerticalProductGrid(context, viewModel, gridAds),
          verticalSpaceLarge,
        ],
      ),
    );
  }


  Widget _buildPromoCards(BuildContext context, HomeViewModel viewModel) {

    final promos = [
      {'trKey': 'home.promo_devis', 'icon': Icons.track_changes},
      {'trKey': 'home.promo_categories', 'icon': Icons.grid_view_rounded},
      {'trKey': 'home.comparator_title', 'icon': Icons.balance_rounded},
      {'trKey': 'home.promo_top_ranking', 'icon': Icons.emoji_events_outlined},
      {'trKey': 'home.promo_discount', 'icon': Icons.local_offer_outlined},
    ];
    final itemWidth = (MediaQuery.of(context).size.width - 32) / 2.2;
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: promos.length,
        itemBuilder: (context, index) {
          final promo = promos[index];
          return InkWell(
            onTap: () {
              if (promo['trKey'] == 'home.promo_discount') {
                viewModel.navigateToPromogoFair();
              } else if (promo['trKey'] == 'home.promo_categories') {
                viewModel.navigateToMonAcademie();
              } else if (promo['trKey'] == 'home.promo_devis') {
                viewModel.navigateToDemandeDevis();
              }
            },
            child: Container(
              width: itemWidth,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4), // Très léger arrondi pour la modernité
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  children: [
                    // --- ÉLÉMENT DÉCORATIF "GHOST ICON" ---
                    Positioned(
                      right: -10,
                      top: -10,
                      child: Icon(
                        promo['icon'] as IconData,
                        size: 60,
                        color: kcTabIndicatorColor.withOpacity(0.05),
                      ),
                    ),
                    // --- CONTENU PRINCIPAL ---
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Badge d'icône élégant
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: kcTabIndicatorColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              promo['icon'] as IconData, 
                              color: kcTabIndicatorColor, 
                              size: 20
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              (promo['trKey'] as String).tr(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                                color: kcDarkGreyColor,
                                height: 1.1,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: kcGoldLight,
        borderRadius: BorderRadius.zero,
        boxShadow: [
          BoxShadow(
            color: kcPrimaryColor.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined, color: kcPrimaryColor, size: 20),
              horizontalSpaceTiny,
              Text(
                'home.badge_livraison'.tr(),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kcDarkGreyColor),
              ),
            ],
          ),
          Container(height: 20, width: 1, color: kcLightGrey.withOpacity(0.5)),
          Row(
            children: [
              const Icon(Icons.security_outlined, color: kcPrimaryColor, size: 20),
              horizontalSpaceTiny,
              Text(
                'home.badge_securite'.tr(),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kcDarkGreyColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context, HomeViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          const Text('Cat:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          horizontalSpaceSmall,
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: allCategories.map((cat) {
                  return InkWell(
                    onTap: () => viewModel.setCategory(cat),
                    child: _CategoryItem(
                      title: cat,
                      isSelected: viewModel.selectedCategory == cat,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          horizontalSpaceSmall,
          InkWell(
            onTap: () {
              _showAllCategoriesSheet(context, viewModel);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: kcLightGrey),
              ),
              child: const Row(
                children: [
                  Text('Lister', style: TextStyle(color: kcMediumGrey, fontSize: 13)),
                  Icon(Icons.arrow_drop_down, color: kcMediumGrey, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllCategoriesSheet(BuildContext context, HomeViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24), // Equilibre pour le centrage
                    const Text('Toutes les catégories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: kcMediumGrey),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: kcLightGrey.withOpacity(0.3)),
              Expanded(
                child: ListView.builder(
                  itemCount: allCategories.length,
                  itemBuilder: (context, index) {
                    final cat = allCategories[index];
                    final isSelected = viewModel.selectedCategory == cat;
                    return InkWell(
                      onTap: () {
                        viewModel.setCategory(cat);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: kcLightGrey.withOpacity(0.2))),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(cat, style: TextStyle(
                                fontSize: 15,
                                color: isSelected ? Colors.black : kcDarkGreyColor,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              )),
                            ),
                            if (isSelected) const Icon(Icons.check, color: kcPrimaryColor, size: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductList(
    BuildContext context, 
    HomeViewModel viewModel, {
    required String title,
    required String subtitle,
    required Gradient backgroundGradient,
    required Color titleColor,
    required IconData backgroundDecorationIcon,
    required Color decorationColor,
    required List<Product> products,
    double decorationRotation = 0.0,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Fond coloré qui s'arrête exactement à la limite des cartes (8 pixels de margin)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 8,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                gradient: backgroundGradient,
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -15,
                    right: -25,
                    child: Transform.rotate(
                      angle: decorationRotation,
                      child: Icon(
                        backgroundDecorationIcon,
                        size: 130,
                        color: decorationColor.withOpacity(0.08),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: titleColor),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: titleColor.withOpacity(0.6)),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_rounded, size: 24, color: titleColor),
                  ],
                ),
              ),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final itemWidth = (MediaQuery.of(context).size.width - 20) / 2.5;
                    return _buildProductCard(
                      viewModel,
                      products[index], 
                      itemWidth
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalProductGrid(BuildContext context, HomeViewModel viewModel, List<Product> gridAds) {
    final itemWidth = (MediaQuery.of(context).size.width - 40) / 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Plus de produits', // Titre générique pour le moment
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kcDarkGreyColor),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
          ),
          itemCount: gridAds.length,
          itemBuilder: (context, index) {
            return _buildProductCard(viewModel, gridAds[index], itemWidth);
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(HomeViewModel viewModel, Product product, double width) {
    return InkWell(
      onTap: () {
        viewModel.navigateToProductDetail(product);
      },
      child: Container(
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: kcCardColor,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F2F5),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(kcPrimaryColor),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => 
                          const Center(child: Icon(Icons.broken_image_outlined, color: kcMediumGrey, size: 24)),
                      ),
                      Positioned(
                        bottom: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(255, 255, 255, 0.9),
                            borderRadius: BorderRadius.zero,
                          ),
                          child: Text(
                            product.price,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      product.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPromoWidgets() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              height: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const PromoCarousel(),
            ),
          ),
          horizontalSpaceMedium,
          Expanded(
            flex: 1,
            child: Container(
              height: 280,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A), // Bleu nuit très pro (Slate 900)
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // --- GRILLE TECHNIQUE EN FOND ---
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.1,
                      child: CustomPaint(
                        painter: _GridPainter(),
                      ),
                    ),
                  ),
                  // --- GRAPHIQUE EN FOND (Sparkline avec Glow) ---
                  Positioned(
                    bottom: 50,
                    left: 0,
                    right: 0,
                    height: 90,
                    child: CustomPaint(
                      painter: _SparklinePainter(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // EN-TÊTE AVEC FITTEDBOX POUR ÉVITER TOUT OVERFLOW
                        SizedBox(
                          height: 20,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Text(
                                  'home.comparator_title'.tr().toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.greenAccent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.greenAccent.withOpacity(0.5), width: 0.5),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 4,
                                        height: 4,
                                        decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text("LIVE", style: TextStyle(color: Colors.greenAccent, fontSize: 8, fontWeight: FontWeight.w900)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        // --- MARCHÉ DATA ---
                        _buildMarketRow("Riz (Sac 50kg)", "24 500", "+2.4%", true),
                        _buildMarketRow("Huile (5L)", "6 200", "-0.8%", false),
                        _buildMarketRow("Sucre (Kg)", "850", "+1.1%", true),
                        
                        const Spacer(),
                        
                        // --- BOUTON TRADING ---
                        InkWell(
                          onTap: () {},
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.insights_rounded, color: Colors.cyanAccent, size: 14),
                                const SizedBox(width: 8),
                                Text(
                                  'home.comparator_action'.tr().toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.cyanAccent, 
                                    fontSize: 9, 
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketRow(String label, String price, String change, bool isUp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                isUp ? "▲" : "▼",
                style: TextStyle(color: isUp ? Colors.greenAccent : Colors.redAccent, fontSize: 8),
              ),
              const SizedBox(width: 4),
              Text(
                change,
                style: TextStyle(
                  color: isUp ? Colors.greenAccent : Colors.redAccent,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
              ),
              const SizedBox(width: 2),
              Text("F", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 8)),
            ],
          ),
          const SizedBox(height: 4),
          Divider(color: Colors.white.withOpacity(0.05), height: 1),
        ],
      ),
    );
  }

  List<String> _getMockGallery(String name, String mainImage) {
    if (name.contains('Chemise')) {
      return [
        mainImage,
        'https://images.unsplash.com/photo-1598033129183-c4f50c7176c8?w=500&q=80',
        'https://images.unsplash.com/photo-1594932224440-746932266999?w=500&q=80',
      ];
    } else if (name.contains('Sac')) {
      return [
        mainImage,
        'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=500&q=80',
        'https://images.unsplash.com/photo-1566150905458-1bf1fd113f06?w=500&q=80',
      ];
    } else if (name.contains('Watch') || name.contains('Montre')) {
      return [
        mainImage,
        'https://images.unsplash.com/photo-1542496658-e33a6d0d50f6?w=500&q=80',
        'https://images.unsplash.com/photo-1508685096489-77a46807f62e?w=500&q=80',
      ];
    }
    return [mainImage, 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500&q=80'];
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 0.5;

    for (double i = 0; i <= size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i <= size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.cubicTo(
      size.width * 0.2, size.height * 0.8,
      size.width * 0.3, size.height * 0.2,
      size.width * 0.5, size.height * 0.4,
    );
    path.cubicTo(
      size.width * 0.7, size.height * 0.6,
      size.width * 0.8, size.height * 0.1,
      size.width, size.height * 0.3,
    );

    // Effet de Glow sous la courbe
    final gradientPath = Path.from(path);
    gradientPath.lineTo(size.width, size.height);
    gradientPath.lineTo(0, size.height);
    gradientPath.close();

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.greenAccent.withOpacity(0.2), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(gradientPath, gradientPaint);
    canvas.drawPath(path, paint);

    // Point d'arrivée brillant
    canvas.drawCircle(Offset(size.width, size.height * 0.3), 3, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(size.width, size.height * 0.3), 6, Paint()..color = Colors.greenAccent.withOpacity(0.3));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _CategoryItem extends StatelessWidget {
  final String title;
  final bool isSelected;

  const _CategoryItem({required this.title, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? kcPrimaryColor : Colors.transparent,
        borderRadius: BorderRadius.zero,
        border: isSelected ? null : Border.all(color: kcLightGrey),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : kcMediumGrey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }
}
