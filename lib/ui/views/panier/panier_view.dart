import 'package:flutter/material.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'panier_viewmodel.dart';

class PanierView extends StackedView<PanierViewModel> {
  const PanierView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, PanierViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'cart.title'.tr(),
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'cart.items_count'.tr(namedArgs: {'count': viewModel.cartItems.length.toString()}),
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
          )
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          // List of items
          ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              ..._buildStoreGroups(viewModel),
              if (viewModel.savedItems.isNotEmpty) _buildSavedForLater(viewModel),
            ],
          ),
          // Fixed Bottom Footer
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildFooter(viewModel),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStoreGroups(PanierViewModel viewModel) {
    // Get unique stores
    final stores = viewModel.cartItems.map((e) => e.storeName).toSet().toList();

    return stores.map((store) {
      final storeItems = viewModel.cartItems.where((i) => i.storeName == store).toList();

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.zero,
        ),
        child: Column(
          children: [
            // Store Title
            Row(
              children: [
                const Icon(Icons.storefront, size: 20, color: Colors.grey),
                horizontalSpaceSmall,
                Text(
                  store,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
              ],
            ),
            const Divider(height: 24),
            // Store Products
            ...storeItems.map((item) => _buildCartItemCard(viewModel, item)),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildCartItemCard(PanierViewModel viewModel, CartItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Select Checkbox
          Checkbox(
            value: item.isSelected,
            onChanged: (_) => viewModel.toggleItemSelection(item.id),
            activeColor: kcPrimaryColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          // Product Image
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.zero,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          horizontalSpaceMedium,
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                verticalSpaceTiny,
                Text(
                  'Variation: Standard', // Mock variation
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                verticalSpaceSmall,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.price.toStringAsFixed(0)} \$',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: kcPrimaryColor,
                      ),
                    ),
                    // Quantity Control
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Row(
                        children: [
                          _buildQtyBtn(Icons.remove, () => viewModel.updateQuantity(item.id, -1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          _buildQtyBtn(Icons.add, () => viewModel.updateQuantity(item.id, 1)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 18, color: Colors.black54),
      ),
    );
  }

  Widget _buildSavedForLater(PanierViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'cart.save_for_later'.tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          verticalSpaceMedium,
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: viewModel.savedItems.length,
              itemBuilder: (context, index) {
                final item = viewModel.savedItems[index];
                return Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 12),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(image: NetworkImage(item.imageUrl), fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                            Text('${item.price}\$', style: const TextStyle(fontWeight: FontWeight.bold, color: kcPrimaryColor)),
                            verticalSpaceTiny,
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => viewModel.moveToCart(item.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kcPrimaryColor,
                                  foregroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 30),
                                ),
                                child: const Text('Move to cart', style: TextStyle(fontSize: 10)),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(PanierViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Select All
            Checkbox(
              value: viewModel.isAllSelected,
              onChanged: viewModel.toggleAllSelection,
              activeColor: kcPrimaryColor,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            Text('cart.select_all'.tr(), style: const TextStyle(fontSize: 12)),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text('cart.total'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    horizontalSpaceSmall,
                    Text(
                      '${viewModel.totalPrice.toStringAsFixed(0)} \$',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: kcPrimaryColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  'USD ${viewModel.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
            horizontalSpaceMedium,
            // Checkout Button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: kcTabIndicatorColor, // Gold #C6A75E
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                'cart.checkout'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  PanierViewModel viewModelBuilder(BuildContext context) => PanierViewModel();
}
