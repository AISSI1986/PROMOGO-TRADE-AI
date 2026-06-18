import 'dart:io';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/common/api_constants.dart';
import 'pre_live_setup_viewmodel.dart';

class PreLiveSetupView extends StackedView<PreLiveSetupViewModel> {
  const PreLiveSetupView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    PreLiveSetupViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. APERÇU CAMÉRA (Corrigé pour remplir tout l'écran de manière adaptative)
          Positioned.fill(
            child: viewModel.isCameraInitialized
                ? Transform.scale(
                    scale: 1.05, // Léger zoom pour s'assurer de couvrir tous les bords (Pixel 3 XL)
                    child: SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: viewModel.buildVideoView(),
                      ),
                    ),
                  )
                : Container(color: Colors.grey[900]),
          ),

          // 2. FILTRE SOMBRE
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),

          // 3. INTERFACE (ADAPTATIVE)
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  const Text(
                                    "PRÉPARATION DU LIVE",
                                    style: TextStyle(
                                      color: Colors.white,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                                    onPressed: viewModel.switchCamera,
                                  ),
                                ],
                              ),
                            const SizedBox(height: 30),
        
                            // CARTE TITRE & CATÉGORIE
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white.withOpacity(0.15)),
                              ),
                              child: Column(
                                children: [
                                  TextField(
                                    onChanged: viewModel.updateTitle,
                                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                    decoration: InputDecoration(
                                      hintText: "Titre de votre direct...",
                                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                                      prefixIcon: const Icon(Icons.edit, color: kcSecondaryGold, size: 20),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                  const Divider(color: Colors.white12),
                                  DropdownButton<String>(
                                    value: viewModel.selectedCategory,
                                    dropdownColor: Colors.grey[900],
                                    underline: const SizedBox(),
                                    icon: const Icon(Icons.keyboard_arrow_down, color: kcSecondaryGold),
                                    isExpanded: true,
                                    items: viewModel.categories.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value, style: const TextStyle(color: Colors.white)),
                                      );
                                    }).toList(),
                                    onChanged: viewModel.updateCategory,
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            const Text(
                              "PRODUITS À PRÉSENTER",
                              style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5),
                            ),
                            const SizedBox(height: 16),
        
                            Row(
                              children: [
                                _buildActionChip(
                                  icon: Icons.list_alt,
                                  label: "Catalogue",
                                  onTap: () => _showCatalogSelectionSheet(context, viewModel),
                                ),
                                const SizedBox(width: 12),
                                _buildActionChip(
                                  icon: Icons.add_a_photo,
                                  label: "Flash Photo",
                                  onTap: viewModel.takeFlashPhoto,
                                  isHighlight: true,
                                ),
                              ],
                            ),
        
                            if (viewModel.selectedProducts.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 90,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: viewModel.selectedProducts.length,
                                  itemBuilder: (context, index) {
                                    final p = viewModel.selectedProducts[index];
                                    return GestureDetector(
                                      onTap: () => _showEditProductSheet(context, viewModel, index),
                                      child: Container(
                                        width: 75,
                                        margin: const EdgeInsets.only(right: 12),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: kcSecondaryGold.withOpacity(0.3)),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: Stack(
                                            children: [
                                              Positioned.fill(child: _buildProductPreviewImage(p)),
                                              Positioned(
                                                bottom: 0, left: 0, right: 0,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                                  color: Colors.black87,
                                                  child: Text(
                                                    p['isFlash'] == true ? "FLASH" : "CAT",
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
        
                            const Spacer(), // <--- Cette partie est CRUCIALE : elle pousse le bouton vers le bas
                            const SizedBox(height: 40),
        
                            // BOUTON GO LIVE
                            SizedBox(
                              width: double.infinity,
                              height: 64,
                              child: ElevatedButton(
                                onPressed: viewModel.startLive,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kcPrimaryColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                  elevation: 8,
                                  shadowColor: kcPrimaryColor.withOpacity(0.4),
                                ),
                                child: viewModel.isBusy
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text(
                                        "LANCER LE DIRECT",
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Center(
                              child: Text(
                                "Conseil Sura : Souriez, vos clients adorent votre visage !",
                                style: TextStyle(color: Colors.white54, fontSize: 11, fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({required IconData icon, required String label, required VoidCallback onTap, bool isHighlight = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isHighlight ? kcSecondaryGold.withOpacity(0.2) : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isHighlight ? kcSecondaryGold : Colors.white24),
          ),
          child: Column(
            children: [
              Icon(icon, color: isHighlight ? kcSecondaryGold : Colors.white),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: isHighlight ? kcSecondaryGold : Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProductSheet(BuildContext context, PreLiveSetupViewModel viewModel, int index) {
    final product = viewModel.selectedProducts[index];
    final nameController = TextEditingController(text: product['name'] as String?);
    final priceController = TextEditingController(text: product['price'].toString().replaceAll(" GHS", ""));

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Modifier l'article",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Nom du produit",
                labelStyle: const TextStyle(color: kcSecondaryGold),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Prix (GHS)",
                labelStyle: const TextStyle(color: kcSecondaryGold),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  viewModel.selectedProducts[index]['name'] = nameController.text;
                  viewModel.selectedProducts[index]['price'] = "${priceController.text} GHS";
                  viewModel.notifyListeners();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: kcSecondaryGold),
                child: const Text("Enregistrer", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCatalogSelectionSheet(BuildContext context, PreLiveSetupViewModel viewModel) async {
    await viewModel.fetchMyCatalogProducts();

    if (!context.mounted) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Sélection du Catalogue",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                viewModel.isBusy
                    ? const Expanded(child: Center(child: CircularProgressIndicator(color: kcSecondaryGold)))
                    : viewModel.myCatalogProducts.isEmpty
                        ? Expanded(
                            child: Center(
                              child: Text(
                                "Votre catalogue est vide.\nPubliez d'abord des articles !",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                              ),
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                              itemCount: viewModel.myCatalogProducts.length,
                              itemBuilder: (context, index) {
                                final p = viewModel.myCatalogProducts[index];
                                final idString = p['id'].toString();
                                final isSelected = viewModel.isProductSelected(idString);
                                
                                String? imageUrl;
                                if (p['images'] != null && p['images'] is List && (p['images'] as List).isNotEmpty) {
                                  imageUrl = p['images'][0]['image'] as String?;
                                } else if (p['image'] != null) {
                                  imageUrl = p['image'] as String?;
                                }

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? kcSecondaryGold : Colors.white12,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: _buildProductPreviewImage({
                                        'image': imageUrl,
                                      }, width: 50, height: 50),
                                    ),
                                    title: Text(
                                      (p['titre'] as String?) ?? (p['title'] as String?) ?? "Produit",
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      "${p['prix'] ?? 200} GHS",
                                      style: const TextStyle(color: kcSecondaryGold),
                                    ),
                                    trailing: Icon(
                                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                                      color: isSelected ? kcSecondaryGold : Colors.white38,
                                      size: 28,
                                    ),
                                    onTap: () {
                                      viewModel.toggleCatalogProduct(Map<String, dynamic>.from(p as Map));
                                      setStateModal(() {});
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kcSecondaryGold,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      "Valider (${viewModel.selectedProducts.length} sélectionnés)",
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductPreviewImage(Map<String, dynamic> product, {double? width, double? height}) {
    if (product['isFlash'] == true && product['imagePath'] != null) {
      return Image.file(
        File(product['imagePath'] as String),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(width, height),
      );
    }
    
    final String? image = product['image'] as String?;
    if (image == null) {
      return _buildPlaceholder(width, height);
    }

    if (image.startsWith('http')) {
      return Image.network(
        image,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(width, height),
      );
    } else if (image.startsWith('/media')) {
      return Image.network(
        "${ApiConstants.djangoRootUrl}$image",
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(width, height),
      );
    } else {
      return Image.asset(
        image,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(width, height),
      );
    }
  }

  Widget _buildPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.white10,
      child: const Icon(Icons.shopping_bag_outlined, color: Colors.white24, size: 20),
    );
  }

  @override
  void onViewModelReady(PreLiveSetupViewModel viewModel) {
    viewModel.init();
  }

  @override
  PreLiveSetupViewModel viewModelBuilder(BuildContext context) => PreLiveSetupViewModel();
}
