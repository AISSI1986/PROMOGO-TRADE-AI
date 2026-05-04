import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';
import 'price_comparator_viewmodel.dart';

class PriceComparatorView extends StackedView<PriceComparatorViewModel> {
  const PriceComparatorView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    PriceComparatorViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: kcBackgroundColor,
      appBar: AppBar(
        backgroundColor: kcPrimaryColor,
        title: Text("comparator.title".tr(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: kcTabIndicatorColor),
            tooltip: "comparator.export_csv".tr(),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER : RECHERCHE ET LOCALISATION
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: kcPrimaryColor,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: kcTabIndicatorColor, size: 18),
                      horizontalSpaceTiny,
                      Text(viewModel.selectedRegion, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      TextButton(
                        onPressed: () {}, 
                        child: Text("comparator.change".tr(), style: const TextStyle(color: kcAIHighlight, fontSize: 12))
                      )
                    ],
                  ),
                  verticalSpaceSmall,
                  TextField(
                    onChanged: viewModel.search,
                    decoration: InputDecoration(
                      hintText: "comparator.search_hint".tr(),
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            
            verticalSpaceMedium,
            
            // 2. RÉSUMÉ INTELLIGENT B2C
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text("comparator.analysis_for".tr(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kcMediumGrey)),
                      Text(viewModel.searchQuery.isNotEmpty ? viewModel.searchQuery : "comparator.mock_product".tr(), 
                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: kcPrimaryColor)),
                    ],
                  ),
                  verticalSpaceSmall,
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSummaryItem("comparator.best_price".tr(), viewModel.intelligentSummary["bestPrice"], Icons.star, kcTabIndicatorColor),
                            _buildSummaryItem("comparator.avg_price".tr(), viewModel.intelligentSummary["avgPrice"], Icons.analytics, kcMediumGrey),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.savings, color: kcSuccessColor, size: 20),
                            horizontalSpaceSmall,
                            Expanded(
                              child: Text(
                                "${"comparator.savings_est".tr()} ${viewModel.intelligentSummary["savings"]}",
                                style: const TextStyle(color: kcSuccessColor, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                        verticalSpaceTiny,
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome, color: kcAIHighlight, size: 20),
                            horizontalSpaceSmall,
                            Expanded(
                              child: Text(
                                "${"comparator.recommended".tr()} ${viewModel.intelligentSummary["recommendation"]}",
                                style: const TextStyle(color: kcPrimaryColor, fontSize: 12),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),

            verticalSpaceMedium,

            // 3. LISTE DES FOURNISSEURS (B2C)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("comparator.suppliers_title".tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: kcPrimaryColor)),
                  verticalSpaceSmall,
                  ...viewModel.suppliers.map((supplier) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: kcVeryLightGrey)
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: kcBackgroundColor, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.storefront, color: kcPrimaryColor),
                        ),
                        horizontalSpaceMedium,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(supplier["name"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text("${supplier["distance"]} - Match: ${supplier["match"]}%", style: const TextStyle(color: kcMediumGrey, fontSize: 12)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(supplier["price"], style: const TextStyle(fontWeight: FontWeight.w900, color: kcPrimaryColor, fontSize: 14)),
                            verticalSpaceTiny,
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: kcPrimaryColor, borderRadius: BorderRadius.circular(4)),
                              child: Text("comparator.contact".tr(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            )
                          ],
                        )
                      ],
                    ),
                  )).toList()
                ],
              ),
            ),

            verticalSpaceLarge,
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        horizontalSpaceSmall,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: kcMediumGrey, fontSize: 11)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: kcPrimaryColor)),
          ],
        )
      ],
    );
  }

  @override
  PriceComparatorViewModel viewModelBuilder(BuildContext context) => PriceComparatorViewModel();
}
