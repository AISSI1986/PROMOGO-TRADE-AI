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
          _buildSearchBar(),
          _buildPromoCards(context, viewModel),
          _buildInfoBanner(),
          _buildCategorySelector(),
          _buildProductList(context, title: 'home.section_produits_cat'.tr()),
          _buildProductList(context, title: 'home.section_meilleures_offres'.tr()),
          _buildBottomPromoWidgets(),
          verticalSpaceLarge,
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: kcPrimaryColor, width: 1.5),
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Icon(Icons.camera_alt_outlined, color: kcMediumGrey, size: 20),
            ),
            Expanded(
              child: Text(
                'home.search_hint'.tr(),
                style: const TextStyle(color: kcMediumGrey, fontSize: 14),
              ),
            ),
            const Icon(Icons.mic_none, color: kcMediumGrey, size: 20),
            const SizedBox(width: 8),
            Container(
              margin: const EdgeInsets.all(2),
              width: 50,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kcPrimaryColor.withOpacity(0.7), kcPrimaryColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.search, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCards(BuildContext context, HomeViewModel viewModel) {
    final promos = [
      {'title': 'Pour vous', 'subtitle': 'Promotion de Mars'},
      {'title': 'Jusqu\'à -20%', 'subtitle': 'Économisez maintenant'},
      {'title': 'Top Produits', 'subtitle': 'Meilleurs choix'},
      {'title': 'Nouveautés', 'subtitle': 'Découvrez plus'},
    ];
    final itemWidth = (MediaQuery.of(context).size.width - 32) / 3.2;
    return SizedBox(
      height: 75,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: promos.length,
        itemBuilder: (context, index) {
          final promo = promos[index];
          return Container(
            width: itemWidth,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kcVeryLightGrey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  promo['title']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  promo['subtitle']!,
                  style: const TextStyle(fontSize: 9, color: kcMediumGrey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kcSuccessColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kcSuccessColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined, color: kcSuccessColor, size: 20),
              horizontalSpaceTiny,
              Text('home.badge_livraison'.tr(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.security, color: kcSuccessColor, size: 20),
              horizontalSpaceTiny,
              Text('home.badge_securite'.tr(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
          _CategoryItem(title: 'home.category_securite'.tr(), isSelected: true),
          _CategoryItem(title: 'home.category_sports'.tr(), isSelected: false),
          _CategoryItem(title: 'home.category_auto'.tr(), isSelected: false),
          const Spacer(),
          Text('home.list_action'.tr(), style: const TextStyle(color: kcPrimaryColor, fontSize: 14)),
          const Icon(Icons.arrow_drop_down, color: kcPrimaryColor),
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
              return Container(
                width: itemWidth,
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                decoration: BoxDecoration(
                  color: kcCardColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: kcVeryLightGrey.withOpacity(0.5),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        ),
                        child: const Center(child: Icon(Icons.image, color: kcMediumGrey, size: 40)),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${'home.product_prefix'.tr()} ${index + 1}',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            verticalSpaceTiny,
                            const Text(
                              '10.00 €',
                              style: TextStyle(color: kcPrimaryColor, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
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
              height: 100,
              decoration: BoxDecoration(
                color: kcAccentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text('home.pub'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: kcAccentColor)),
              ),
            ),
          ),
          horizontalSpaceMedium,
          Expanded(
            flex: 2,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: kcPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kcPrimaryColor.withOpacity(0.3)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'home.comparator_title'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kcPrimaryColorDark),
                    ),
                    verticalSpaceSmall,
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: kcPrimaryColor, borderRadius: BorderRadius.circular(20)),
                      child: Text('home.comparator_action'.tr(), style: const TextStyle(color: Colors.white, fontSize: 12)),
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
        borderRadius: BorderRadius.circular(20),
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
