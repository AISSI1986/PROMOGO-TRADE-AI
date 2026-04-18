import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/views/home/widgets/produits_component.dart';
import 'my_publications_viewmodel.dart';

class MyPublicationsView extends StackedView<MyPublicationsViewModel> {
  const MyPublicationsView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    MyPublicationsViewModel viewModel,
    Widget? child,
  ) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: kcTabIndicatorColor),
            onPressed: viewModel.onBack,
          ),
          title: Text(
            'publications.title'.tr(),
            style: const TextStyle(
              color: kcPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.zero,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'publications.search_hint'.tr(),
                        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                        prefixIcon: const Icon(Icons.search, color: kcPrimaryColor, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                // Tabs
                TabBar(
                  indicatorColor: kcTabIndicatorColor,
                  indicatorWeight: 3,
                  labelColor: kcPrimaryColor,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: [
                    Tab(text: 'publications.active'.tr().toUpperCase()),
                    Tab(text: 'publications.draft'.tr().toUpperCase()),
                    Tab(text: 'publications.closed'.tr().toUpperCase()),
                  ],
                ),
                Container(color: Colors.grey.shade100, height: 1.0),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildEmptyState(context, 'publications.active'),
            _buildEmptyState(context, 'publications.draft'),
            _buildEmptyState(context, 'publications.closed'),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String sectionKey) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, color: Colors.grey.shade300, size: 64),
          const SizedBox(height: 16),
          Text(
            "Aucune publication en cours".tr(), // Will use translations if available
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  MyPublicationsViewModel viewModelBuilder(BuildContext context) => MyPublicationsViewModel();
}
