import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/app/app.router.dart';
import 'saved_viewmodel.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:promogoai/models/product.dart';

class SavedView extends StackedView<SavedViewModel> {
  const SavedView({Key? key}) : super(key: key);

  @override
  void onViewModelReady(SavedViewModel viewModel) {
    viewModel.fetchMyAds();
    super.onViewModelReady(viewModel);
  }

  @override
  Widget builder(
    BuildContext context,
    SavedViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: kcBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kcTabIndicatorColor, size: 20),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              locator<NavigationService>().clearStackAndShow(Routes.homeView);
            }
          },
        ),
        title: Text(
          'saved.title'.tr(),
          style: const TextStyle(
            color: kcPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildTabs(viewModel),
          Expanded(
            child: viewModel.isBusy 
              ? const Center(child: CircularProgressIndicator(color: kcPrimaryColor))
              : _buildContent(viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(SavedViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabItem(
              label: 'saved.publications'.tr(),
              isSelected: viewModel.currentIndex == 0,
              onTap: () => viewModel.setIndex(0),
            ),
          ),
          Expanded(
            child: _TabItem(
              label: 'saved.searches'.tr(),
              isSelected: viewModel.currentIndex == 1,
              onTap: () => viewModel.setIndex(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(SavedViewModel viewModel) {
    // Onglet Publications (Index 0)
    if (viewModel.currentIndex == 0) {
      if (viewModel.myAds.isEmpty) {
        return _buildEmptyState(
          'saved.empty_publications'.tr(),
          Icons.inventory_2_outlined,
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: viewModel.myAds.length,
        itemBuilder: (context, index) {
          final ad = viewModel.myAds[index];
          final product = viewModel.mapToProduct(ad);
          return _buildAdCard(context, product);
        },
      );
    }

    // Onglet Recherches (Index 1) - Toujours vide pour l'instant
    return _buildEmptyState(
      'saved.empty_searches'.tr(),
      Icons.search,
    );
  }

  Widget _buildAdCard(BuildContext context, Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: CachedNetworkImage(
                imageUrl: product.imageUrl,
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
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  product.price,
                  style: const TextStyle(
                    color: kcPrimaryColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: kcTabIndicatorColor.withOpacity(0.2)),
            verticalSpaceMedium,
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  SavedViewModel viewModelBuilder(BuildContext context) => SavedViewModel();
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? kcPrimaryColor : Colors.grey.shade400,
              ),
            ),
          ),
          Container(
            height: 3,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: isSelected ? kcPrimaryColor : Colors.transparent,
          ),
        ],
      ),
    );
  }
}
