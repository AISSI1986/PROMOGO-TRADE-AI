import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';
import '../home_viewmodel.dart';

class ProduitsComponent extends ViewModelWidget<HomeViewModel> {
  const ProduitsComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, HomeViewModel viewModel) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPromoCards(context, viewModel),
          _buildInfoBanner(),
          _buildCategorySelector(),
          _buildProductList(context, title: 'home.section_produits_cat'.tr()),
          _buildProductList(context, title: 'home.section_meilleures_offres'.tr()),
          _buildBottomPromoWidgets(),
          _buildVerticalProductGrid(context),
          verticalSpaceLarge,
        ],
      ),
    );
  }


  Widget _buildPromoCards(BuildContext context, HomeViewModel viewModel) {
    final promos = [
      {'trKey': 'home.promo_categories', 'icon': Icons.grid_view_rounded},
      {'trKey': 'home.promo_devis', 'icon': Icons.track_changes},
      {'trKey': 'home.promo_top_ranking', 'icon': Icons.emoji_events_outlined},
      {'trKey': 'home.promo_for_you', 'icon': Icons.favorite_border},
      {'trKey': 'home.promo_discount', 'icon': Icons.local_offer_outlined},
      {'trKey': 'home.promo_top_products', 'icon': Icons.star_outline},
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
          return Container(
            width: itemWidth,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: kcVeryLightGrey.withOpacity(0.4),
              borderRadius: BorderRadius.zero,
            ),
            child: Row(
              children: [
                Icon(promo['icon'] as IconData, color: kcPrimaryColor, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    (promo['trKey'] as String).tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                      color: kcDarkGreyColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
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
        color: Colors.white,
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

  Widget _buildCategorySelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text('home.category_title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          horizontalSpaceSmall,
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _CategoryItem(title: 'home.category_all'.tr(), isSelected: true),
                  _CategoryItem(title: 'home.category_clothing'.tr(), isSelected: false),
                  _CategoryItem(title: 'home.category_bags'.tr(), isSelected: false),
                ],
              ),
            ),
          ),
          horizontalSpaceSmall,
          InkWell(
            onTap: () {
              // Action pour ouvrir toutes les catégories
            },
            child: Row(
              children: [
                Text('home.list_action'.tr(), style: const TextStyle(color: kcPrimaryColor, fontSize: 14)),
                const Icon(Icons.arrow_drop_down, color: kcPrimaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(BuildContext context, {required String title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kcDarkGreyColor),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: kcMediumGrey),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: 10,
            itemBuilder: (context, index) {
              final itemWidth = (MediaQuery.of(context).size.width - 20) / 2.5;
              return _buildProductCard(index, itemWidth);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalProductGrid(BuildContext context) {
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
          itemCount: 8,
          itemBuilder: (context, index) {
            return _buildProductCard(index, itemWidth);
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(int index, double width) {
    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: kcCardColor,
        borderRadius: BorderRadius.zero,
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
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F2F5),
                  borderRadius: BorderRadius.zero,
                ),
                child: Stack(
                  children: [
                    const Center(child: Icon(Icons.image_outlined, color: kcMediumGrey, size: 36)),
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, 0.9),
                          borderRadius: BorderRadius.zero,
                        ),
                        child: const Text(
                          '7 134 F CFA',
                          style: TextStyle(
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
                    index % 2 == 0 ? 'Chemise' : 'Sacs à main',
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
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.zero,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.campaign_outlined, color: kcAccentColor, size: 30),
                    verticalSpaceTiny,
                    Text(
                      'home.pub'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.w900, color: kcAccentColor, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
          horizontalSpaceMedium,
          Expanded(
            flex: 2,
            child: Container(
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.zero,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'home.comparator_title'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: kcDarkGreyColor),
                    ),
                    verticalSpaceSmall,
                    InkWell(
                      onTap: () {},
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: const BoxDecoration(
                          color: kcPrimaryColor,
                          borderRadius: BorderRadius.zero,
                        ),
                        child: Center(
                          child: Text(
                            'home.comparator_action'.tr(),
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
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
