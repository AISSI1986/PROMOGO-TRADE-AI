import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/models/product.dart';
import 'top_ranking_viewmodel.dart';

const List<String> _rankingCategories = [
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

class TopRankingView extends StackedView<TopRankingViewModel> {
  const TopRankingView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, TopRankingViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: kcBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, viewModel),
            _buildFilterBar(context, viewModel),
            Expanded(
              child: viewModel.isFiltering
                  ? _buildSkeletonGrid(context)
                  : viewModel.filteredAds.isEmpty
                      ? _buildEmptyState(context)
                      : _buildProductGrid(context, viewModel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TopRankingViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 12, bottom: 24, left: 16, right: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2C1B0C), Color(0xFF1A1006)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // --- LAURIERS DORÉS EN ARRIÈRE-PLAN (EFFET WOW 3D) ---
          Positioned(
            left: 10,
            top: 20,
            child: Transform.rotate(
              angle: -0.3,
              child: Icon(
                Icons.emoji_events_rounded,
                size: 110,
                color: Colors.amber.withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            right: 10,
            top: 20,
            child: Transform.rotate(
              angle: 0.3,
              child: Icon(
                Icons.workspace_premium_rounded,
                size: 110,
                color: Colors.amber.withOpacity(0.12),
              ),
            ),
          ),

          // --- CONTENU PRINCIPAL DU HEADER ---
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => viewModel.navigateBack(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12), // Espacement propre
                  Expanded(
                    child: Text(
                      'home.promo_top_ranking'.tr().toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15, // Ajusté légèrement pour une lisibilité optimale
                        letterSpacing: 1.0, // Réduit pour éviter l'encombrement sur petits écrans
                        fontFamily: 'Outfit',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // Sécurité absolue contre tout débordement
                    ),
                  ),
                  // Ajout d'une icône décorative à droite pour garder un équilibre et une symétrie parfaits
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.military_tech_rounded, color: Colors.amber, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // --- BOUTON DE SÉLECTION DE CATÉGORIE ---
              GestureDetector(
                onTap: () => _showCategorySheet(context, viewModel),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        viewModel.selectedCategory == "Tous" 
                            ? 'top_ranking.select_category'.tr() 
                            : viewModel.selectedCategory,
                        style: const TextStyle(
                          color: kcDarkGreyColor, 
                          fontWeight: FontWeight.w700, 
                          fontSize: 14
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.keyboard_arrow_down_rounded, color: kcDarkGreyColor, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, TopRankingViewModel viewModel) {
    final filters = [
      'top_ranking.filter_all'.tr(),
      'top_ranking.filter_featured'.tr(),
      'top_ranking.filter_popular'.tr(),
      'top_ranking.filter_top_rated'.tr(),
    ];

    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1006),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isSelected = viewModel.activeFilterIndex == index;
          return GestureDetector(
            onTap: () => viewModel.setFilterIndex(index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  filters[index],
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF1A1006) : Colors.white70,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, TopRankingViewModel viewModel) {
    final itemWidth = (MediaQuery.of(context).size.width - 40) / 2;
    final products = viewModel.filteredAds;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(context, viewModel, product, itemWidth);
      },
    );
  }

  Widget _buildProductCard(BuildContext context, TopRankingViewModel viewModel, Product product, double width) {
    return InkWell(
      onTap: () => viewModel.navigateToProductDetail(product),
      child: Container(
        decoration: BoxDecoration(
          color: kcCardColor,
          borderRadius: BorderRadius.circular(8),
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
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F2F5),
                    borderRadius: BorderRadius.circular(6),
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
                            color: Color.fromRGBO(255, 255, 255, 0.95),
                            borderRadius: BorderRadius.zero,
                          ),
                          child: Text(
                            product.price,
                            style: const TextStyle(
                              fontSize: 10,
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
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      product.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: kcDarkGreyColor),
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

  Widget _buildSkeletonGrid(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF0F2F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  height: 14, 
                  width: double.infinity, 
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kcTabIndicatorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: kcTabIndicatorColor,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'top_ranking.empty_title'.tr(),
              style: const TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: kcDarkGreyColor
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'top_ranking.empty_subtitle'.tr(),
              style: const TextStyle(
                fontSize: 14, 
                color: kcMediumGrey,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showCategorySheet(BuildContext context, TopRankingViewModel viewModel) {
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
                    const SizedBox(width: 24),
                    Text('home.category_title'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  itemCount: _rankingCategories.length,
                  itemBuilder: (context, index) {
                    final cat = _rankingCategories[index];
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

  @override
  TopRankingViewModel viewModelBuilder(BuildContext context) => TopRankingViewModel();
}
