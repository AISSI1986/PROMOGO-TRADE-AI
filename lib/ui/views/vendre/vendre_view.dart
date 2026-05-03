import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/models/subscription_plan.dart';
import 'vendre_viewmodel.dart';

class VendreView extends StackedView<VendreViewModel> {
  VendreView({Key? key}) : super(key: key);

  // Controllers & Keys pour le scroll automatique
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _titleKey = GlobalKey();
  final GlobalKey _categoryKey = GlobalKey();
  final GlobalKey _priceKey = GlobalKey();
  final GlobalKey _imagesKey = GlobalKey();
  final GlobalKey _locationKey = GlobalKey();
  final GlobalKey _descriptionKey = GlobalKey();
  final GlobalKey _bulkKey = GlobalKey();

  void _scrollToFirstError(VendreViewModel viewModel) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GlobalKey? keyToScroll;
      if (viewModel.titleHasError) {
        keyToScroll = _titleKey;
      } else if (viewModel.categoryHasError) {
        keyToScroll = _categoryKey;
      } else if (viewModel.priceHasError) {
        keyToScroll = _priceKey;
      } else if (viewModel.imagesHasError) {
        keyToScroll = _imagesKey;
      } else if (viewModel.locationHasError) {
        keyToScroll = _locationKey;
      } else if (viewModel.descriptionHasError) {
        keyToScroll = _descriptionKey;
      } else if (viewModel.bulkPricesHasError) {
        keyToScroll = _bulkKey;
      }

      if (keyToScroll != null && keyToScroll.currentContext != null) {
        Scrollable.ensureVisible(
          keyToScroll.currentContext!,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void onViewModelReady(VendreViewModel viewModel) {
    viewModel.init();
  }

  @override
  Widget builder(
    BuildContext context,
    VendreViewModel viewModel,
    Widget? child,
  ) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bool isKeyboardOpen = bottomInset > 0;

    // Déclencher le scroll seulement si le ViewModel le demande explicitement
    if (viewModel.shouldScrollToError) {
       _scrollToFirstError(viewModel);
       viewModel.clearScrollSignal(); // On consomme le signal pour ne pas rescroller à chaque frappe
    }

    return Stack(
      children: [
        // 1. Formulaire Scrollable
        SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCard(
                  child: Column(
                    children: [
                      _buildTitleInput(viewModel, key: _titleKey),
                      const SizedBox(height: 20),
                      _buildPriceInput(viewModel, key: _priceKey),
                      const SizedBox(height: 16),
                      
                      // SÉLECTEUR DE CATÉGORIE PREMIUM
                      _buildCategorySelector(context, viewModel, key: _categoryKey),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Photos Section
                _buildSectionHeader('post_ad.section_photos'.tr(), key: _imagesKey, isRequired: true),
                const SizedBox(height: 8),
                _buildCard(
                  hasError: viewModel.imagesHasError,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'post_ad.instruction'.tr(),
                        style: TextStyle(fontSize: 11, color: kcMediumGrey.withOpacity(0.8), height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      _buildImagePicker(viewModel),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Location and Video
                _buildSectionHeader('post_ad.section_location'.tr(), isRequired: true),
                _buildCard(
                  key: _locationKey,
                  child: _buildTextField(
                    viewModel,
                    label: 'post_ad.location'.tr(),
                    controller: viewModel.locationController,
                    onChanged: viewModel.setLocation,
                    isRequired: true,
                    hasError: viewModel.locationHasError,
                  ),
                ),
                const SizedBox(height: 24),

                _buildSectionHeader('post_ad.section_video'.tr()),
                _buildCard(
                  child: _buildTextField(
                    viewModel,
                    label: 'post_ad.video_hint'.tr(),
                    controller: viewModel.videoController,
                    onChanged: viewModel.setVideoLink,
                    maxLength: 1024,
                  ),
                ),
                const SizedBox(height: 24),

                // Description Simple
                _buildSectionHeader('post_ad.description'.tr(), isRequired: true),
                _buildCard(
                  key: _descriptionKey,
                  child: _buildTextField(
                    viewModel,
                    label: 'Décrivez votre article en quelques mots...',
                    controller: viewModel.descriptionController,
                    onChanged: viewModel.setDescription,
                    maxLines: 4,
                    isRequired: true,
                    hasError: viewModel.descriptionHasError,
                  ),
                ),
                const SizedBox(height: 24),

                // Bulk Price
                _buildBulkPriceSection(viewModel),
                const SizedBox(height: 24),

                // Subscription
                _buildSectionHeader('post_ad.section_promo'.tr()),
                _buildCard(child: _buildSubscriptionOptions(viewModel)),
                
                const SizedBox(height: 32),

                // BOUTON NORMAL (Visible seulement si le clavier est FERMÉ)
                if (!isKeyboardOpen) 
                  viewModel.isBusy 
                    ? const Center(child: CircularProgressIndicator(color: kcPrimaryColor))
                    : _buildSubmitButton(viewModel),
                
                // ESPACE pour une finition propre en bas de scroll
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),

        // 2. BOUTON FLOTTANT (Visible seulement si le clavier est OUVERT)
        if (isKeyboardOpen)
          Positioned(
            left: 16,
            right: 16,
            bottom: bottomInset + 10,
            child: viewModel.isBusy 
              ? const Center(child: CircularProgressIndicator(color: kcPrimaryColor))
              : _buildSubmitButton(viewModel),
          ),
      ],
    );
  }

  Widget _buildCategorySelector(BuildContext context, VendreViewModel viewModel, {Key? key}) {
    return GestureDetector(
      key: key,
      onTap: () => _showCategoryBottomSheet(context, viewModel),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: viewModel.categoryHasError ? Colors.red : kcVeryLightGrey),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: viewModel.selectedCategory ?? 'post_ad.category'.tr().toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: viewModel.selectedCategory != null ? FontWeight.w600 : FontWeight.bold,
                    color: viewModel.selectedCategory != null ? Colors.black : kcPrimaryColor,
                    fontFamily: 'Outfit',
                  ),
                  children: [
                    if (viewModel.selectedCategory == null)
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: kcTabIndicatorColor),
          ],
        ),
      ),
    );
  }

  void _showCategoryBottomSheet(BuildContext context, VendreViewModel viewModel) {
    // Reset search query when opening
    viewModel.setSearchQuery('');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true, // Permet de cliquer à l'extérieur pour fermer
      enableDrag: true,    // Permet de glisser vers le bas pour fermer
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false, // Empêche de prendre tout l'écran pour laisser le clic extérieur fonctionner
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 20),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: kcVeryLightGrey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              
              Text(
                'SÉLECTIONNEZ UNE CATÉGORIE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: kcPrimaryColor.withOpacity(0.8),
                  letterSpacing: 1.2,
                ),
              ),
              
              const SizedBox(height: 15),
              
              // Barre de Recherche
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  onChanged: viewModel.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Rechercher une catégorie...',
                    prefixIcon: const Icon(Icons.search, color: kcPrimaryColor),
                    filled: true,
                    fillColor: kcVeryLightGrey.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Liste des Catégories
              Expanded(
                child: viewModel.categories.isEmpty 
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 48, color: kcMediumGrey.withOpacity(0.5)),
                          const SizedBox(height: 10),
                          const Text("Aucune catégorie trouvée", style: TextStyle(color: kcMediumGrey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      itemCount: viewModel.categories.length,
                      itemBuilder: (context, index) {
                        final cat = viewModel.categories[index];
                        final catName = cat['libele'] as String;
                        final isSelected = viewModel.selectedCategory == catName;
                        
                        return ListTile(
                          onTap: () {
                            viewModel.setCategory(cat);
                            Navigator.pop(context);
                          },
                          leading: Icon(
                            Icons.category_outlined, 
                            color: isSelected ? kcPrimaryColor : kcMediumGrey.withOpacity(0.5)
                          ),
                          title: Text(
                            catName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? kcPrimaryColor : Colors.black87,
                            ),
                          ),
                          trailing: isSelected 
                            ? const Icon(Icons.check_circle, color: kcPrimaryColor)
                            : null,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          tileColor: isSelected ? kcPrimaryColor.withOpacity(0.05) : null,
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child, Key? key, bool hasError = false}) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: hasError ? Colors.red : kcVeryLightGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title, {Key? key, bool isRequired = false}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: 12.0),
      child: RichText(
        text: TextSpan(
          text: title.toUpperCase(),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: kcPrimaryColor,
            letterSpacing: 1.2,
            fontFamily: 'Outfit',
          ),
          children: [
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleInput(VendreViewModel viewModel, {Key? key}) {
    bool hasValidationError = viewModel.titleHasError || (!viewModel.isTitleValid && viewModel.title.isNotEmpty);
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'post_ad.input_label_title'.tr().toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kcPrimaryColor, fontFamily: 'Outfit'),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: viewModel.titleController,
          maxLength: 70,
          onChanged: viewModel.setTitle,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'post_ad.input_title'.tr(),
            hintStyle: TextStyle(color: kcMediumGrey.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.normal),
            counterText: '${viewModel.title.length}/70',
            filled: true,
            fillColor: kcVeryLightGrey.withOpacity(0.15),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: hasValidationError ? Colors.red : kcVeryLightGrey.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: hasValidationError ? Colors.red : kcTabIndicatorColor, width: 1.5),
            ),
          ),
        ),
        if (!viewModel.isTitleValid && viewModel.title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              viewModel.titleError.tr(),
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildPriceInput(VendreViewModel viewModel, {Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'post_ad.price'.tr().toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kcPrimaryColor, fontFamily: 'Outfit'),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: viewModel.priceController,
          onChanged: viewModel.setPrice,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kcTabIndicatorColor),
          decoration: InputDecoration(
            hintText: 'e.g. 5000',
            hintStyle: TextStyle(color: kcMediumGrey.withOpacity(0.5), fontSize: 16, fontWeight: FontWeight.w500),
            prefixIcon: const Icon(Icons.payments_outlined, color: kcTabIndicatorColor),
            suffixText: 'GHS',
            suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: kcMediumGrey),
            filled: true,
            fillColor: kcVeryLightGrey.withOpacity(0.15),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: viewModel.priceHasError ? Colors.red : kcVeryLightGrey.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: viewModel.priceHasError ? Colors.red : kcTabIndicatorColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    VendreViewModel viewModel, {
    required String label,
    required Function(String) onChanged,
    TextEditingController? controller,
    int? maxLength,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
    bool hasError = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kcPrimaryColor, fontFamily: 'Outfit'),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLength: maxLength,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            filled: true,
            fillColor: kcVeryLightGrey.withOpacity(0.15),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: hasError ? Colors.red : kcVeryLightGrey.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: hasError ? Colors.red : kcTabIndicatorColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?)? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: kcVeryLightGrey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(label.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kcPrimaryColor)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: kcTabIndicatorColor),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildImagePicker(VendreViewModel viewModel) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // Changed from 3 to 4 for smaller previews
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: viewModel.images.length + 1,
      itemBuilder: (context, index) {
        if (index == viewModel.images.length) {
          return GestureDetector(
            onTap: () => _showImageSourcePicker(context, viewModel),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: kcTabIndicatorColor, style: BorderStyle.solid, width: 1),
                color: kcVeryLightGrey.withOpacity(0.3),
              ),
              child: const Icon(Icons.add_a_photo_outlined, color: kcTabIndicatorColor, size: 20),
            ),
          );
        }
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: kcVeryLightGrey),
                image: DecorationImage(
                  image: FileImage(viewModel.images[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: () => viewModel.removeImage(index),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  color: Colors.red.withOpacity(0.9),
                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                ),
              ),
            ),
            if (index == 0)
              Positioned(
                left: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  color: kcTabIndicatorColor,
                  child: const Text('TITLE', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showImageSourcePicker(BuildContext context, VendreViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: kcPrimaryColor),
              title: Text('post_ad.gallery'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                viewModel.pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: kcPrimaryColor),
              title: Text('post_ad.camera'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                viewModel.pickImage(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulkPriceSection(VendreViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader('post_ad.bulk_title'.tr()),
            Switch(
              value: viewModel.showBulkPriceForm,
              onChanged: (_) => viewModel.toggleBulkPriceForm(),
              activeColor: kcTabIndicatorColor,
              activeTrackColor: kcTabIndicatorColor.withOpacity(0.3),
            ),
          ],
        ),
        if (viewModel.showBulkPriceForm)
          _buildCard(
            key: _bulkKey,
            hasError: viewModel.bulkPricesHasError,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (viewModel.bulkPrices.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Aucun palier défini. Ajoutez-en un ci-dessous.",
                        style: TextStyle(color: kcMediumGrey.withOpacity(0.7), fontSize: 12),
                      ),
                    ),
                  ),
                
                // LISTE DES PALIERS (LIGNES DYNAMIQUES)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: viewModel.bulkPrices.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          // 1. Quantité (Menu Déroulant)
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: viewModel.bulkPrices[index]['size']!.isEmpty ? null : viewModel.bulkPrices[index]['size'],
                              items: viewModel.bulkSizes.map((size) => DropdownMenuItem(
                                value: size,
                                child: Text(size, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              )).toList(),
                              onChanged: (val) => viewModel.updateBulkPriceRow(index, 'size', val ?? ''),
                              decoration: InputDecoration(
                                hintText: 'Qté',
                                hintStyle: TextStyle(fontSize: 12, color: kcMediumGrey.withOpacity(0.5)),
                                prefixIcon: const Icon(Icons.shopping_basket_outlined, size: 16, color: kcTabIndicatorColor),
                                filled: true,
                                fillColor: kcVeryLightGrey.withOpacity(0.15),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.zero,
                                  borderSide: BorderSide(color: (viewModel.bulkPricesHasError && viewModel.bulkPrices[index]['size']!.isEmpty) ? Colors.red : Colors.transparent),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.zero,
                                  borderSide: BorderSide(color: (viewModel.bulkPricesHasError && viewModel.bulkPrices[index]['size']!.isEmpty) ? Colors.red : Colors.transparent),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 2. Prix
                          Expanded(
                            flex: 3,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (val) => viewModel.updateBulkPriceRow(index, 'price', val),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: kcTabIndicatorColor),
                              decoration: InputDecoration(
                                hintText: 'Prix total (GHS)',
                                hintStyle: TextStyle(fontSize: 12, color: kcMediumGrey.withOpacity(0.5)),
                                prefixIcon: const Icon(Icons.payments_outlined, size: 16, color: kcTabIndicatorColor),
                                filled: true,
                                fillColor: kcVeryLightGrey.withOpacity(0.15),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.zero,
                                  borderSide: BorderSide(color: (viewModel.bulkPricesHasError && viewModel.bulkPrices[index]['price']!.isEmpty) ? Colors.red : Colors.transparent),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.zero,
                                  borderSide: BorderSide(color: (viewModel.bulkPricesHasError && viewModel.bulkPrices[index]['price']!.isEmpty) ? Colors.red : Colors.transparent),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                          // 3. Bouton Supprimer
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 22),
                            onPressed: () => viewModel.removeBulkPrice(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 10),
                
                // BOUTON AJOUTER UNE LIGNE
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: viewModel.canAddBulkPriceRow ? viewModel.addBulkPriceRow : null,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("AJOUTER UN PALIER DE PRIX", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: viewModel.canAddBulkPriceRow ? kcPrimaryColor : kcMediumGrey,
                      side: BorderSide(color: viewModel.canAddBulkPriceRow ? kcPrimaryColor : kcMediumGrey),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSubscriptionOptions(VendreViewModel viewModel) {
    if (viewModel.subscriptionPlans.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(color: kcPrimaryColor),
        ),
      );
    }

    return Column(
      children: viewModel.subscriptionPlans.map((plan) {
        bool isSelected = viewModel.selectedSubscription == plan.nom;
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            border: Border.all(color: isSelected ? kcTabIndicatorColor : kcVeryLightGrey, width: isSelected ? 2 : 1),
          ),
          child: RadioListTile<SubscriptionPlan>(
            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(plan.nom, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? kcPrimaryColor : kcMediumGrey)),
                Text(
                  plan.prix > 0 ? '${plan.prix} ${plan.devise}' : 'FREE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: plan.prix > 0 ? kcTabIndicatorColor : Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            value: plan,
            groupValue: viewModel.selectedPlan,
            onChanged: viewModel.setSubscription,
            activeColor: kcTabIndicatorColor,
            secondary: Icon(
              plan.nom == 'BASIC' ? Icons.fiber_new_outlined : plan.nom == 'BOOST' ? Icons.trending_up : Icons.star_outline,
              color: isSelected ? kcTabIndicatorColor : kcMediumGrey,
              size: 20,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubmitButton(VendreViewModel viewModel) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: kcPrimaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: viewModel.submitAd,
        style: ElevatedButton.styleFrom(
          backgroundColor: kcPrimaryColor,
          foregroundColor: kcTabIndicatorColor,
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: Text(
          viewModel.submitButtonText.tr(),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 2.0,
          ),
        ),
      ),
    );
  }


  @override
  VendreViewModel viewModelBuilder(BuildContext context) => VendreViewModel();
}
