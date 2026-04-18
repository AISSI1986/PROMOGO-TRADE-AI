import 'package:flutter/material.dart';
import 'package:promogoai/models/product.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image & Gallery
                _buildProductHeader(context, viewModel),
                
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price & Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            product.price,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFB22222), // Deep red for emphasis
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(0xFFFFF7E6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: Color(0xFFFAAD14), size: 16),
                                horizontalSpaceTiny,
                                Text(
                                  '${product.rating}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      verticalSpaceSmall,
                      
                      // Product Name
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kcPrimaryColor,
                        ),
                      ),
                      verticalSpaceLarge,
                      
                      // Description Section
                      const Text(
                        "Détails du produit",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      verticalSpaceSmall,
                      Text(
                        product.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: kcMediumGrey,
                          height: 1.6,
                        ),
                      ),
                      verticalSpaceLarge,
                      
                      // Seller Section
                      _buildSellerCard(),
                      
                      const SizedBox(height: 100), // Space for bottom buttons
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Custom Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back, color: kcPrimaryColor),
              ),
            ),
          ),

          // Bottom Action Buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomActions(viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildProductHeader(BuildContext context, ProductDetailViewModel viewModel) {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.40,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFFF6F8FC),
          ),
          child: CachedNetworkImage(
            imageUrl: viewModel.currentImageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kcPrimaryColor),
              ),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.broken_image),
          ),
        ),
        if (product.gallery.length > 1)
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: product.gallery.length,
              itemBuilder: (context, index) {
                final isSelected = viewModel.selectedImageIndex == index;
                return GestureDetector(
                  onTap: () => viewModel.setSelectedImage(index),
                  child: Container(
                    width: 56,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? kcTabIndicatorColor : Colors.transparent,
                        width: 2,
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
          ),
      ],
    );
  }

  Widget _buildSellerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: kcLightGrey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          horizontalSpaceMedium,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.sellerName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Vendeur Vérifié sur Promogo AI",
                  style: TextStyle(fontSize: 11, color: kcMediumGrey),
                ),
              ],
            ),
          ),
          const Icon(Icons.verified, color: Colors.blue, size: 18),
        ],
      ),
    );
  }

  Widget _buildBottomActions(ProductDetailViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Chat Button
          Expanded(
            child: ElevatedButton(
              onPressed: viewModel.onChatWithSeller,
              style: ElevatedButton.styleFrom(
                backgroundColor: kcPrimaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text("Discuter avec le vendeur", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  ProductDetailViewModel viewModelBuilder(BuildContext context) =>
      ProductDetailViewModel(product: product);
}
