import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';
import 'saved_viewmodel.dart';

class SavedView extends StackedView<SavedViewModel> {
  const SavedView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    SavedViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kcTabIndicatorColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'saved.title'.tr(),
          style: const TextStyle(
            color: kcPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildTabs(viewModel),
          Expanded(
            child: _buildContent(viewModel),
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
    bool isEmpty = true; // Placeholder for now

    if (isEmpty) {
      return _buildEmptyState(
        viewModel.currentIndex == 0
            ? 'saved.empty_publications'.tr()
            : 'saved.empty_searches'.tr(),
        viewModel.currentIndex == 0 ? Icons.inventory_2_outlined : Icons.search,
      );
    }

    return const SizedBox.shrink();
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
