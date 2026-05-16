import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';
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
                        child: SizedBox(
                          width: viewModel.cameraController!.value.previewSize?.height ?? 1,
                          height: viewModel.cameraController!.value.previewSize?.width ?? 1,
                          child: CameraPreview(viewModel.cameraController!),
                        ),
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
                                  onTap: viewModel.selectProducts,
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
    final nameController = TextEditingController(text: product['name']);
    final priceController = TextEditingController(text: product['price'].toString().replaceAll(" GHS", ""));

    showModalBottomSheet(
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

  Widget _buildProductPreviewImage(Map<String, dynamic> product) {
    if (product['isFlash'] == true && product['imagePath'] != null) {
      return Image.file(File(product['imagePath']), fit: BoxFit.cover);
    }
    
    final String? image = product['image'];
    if (image == null) {
      return Container(color: Colors.white10, child: const Icon(Icons.shopping_bag_outlined, color: Colors.white24));
    }

    if (image.startsWith('http')) {
      return Image.network(image, fit: BoxFit.cover);
    } else {
      return Image.asset(image, fit: BoxFit.cover);
    }
  }

  @override
  void onViewModelReady(PreLiveSetupViewModel viewModel) {
    viewModel.init();
  }

  @override
  PreLiveSetupViewModel viewModelBuilder(BuildContext context) => PreLiveSetupViewModel();
}
