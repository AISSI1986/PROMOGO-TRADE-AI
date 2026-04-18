import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'vendre_viewmodel.dart';

class VendreView extends StackedView<VendreViewModel> {
  const VendreView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    VendreViewModel viewModel,
    Widget? child,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard(

                    child: Column(
                      children: [
                        _buildTitleInput(viewModel),
                        const SizedBox(height: 20),
                        _buildPriceInput(viewModel),
                        const SizedBox(height: 16),
                        _buildDropdown(
                          label: 'post_ad.category'.tr(),
                          value: viewModel.selectedCategory,
                          items: viewModel.categories,
                          onChanged: viewModel.setCategory,
                        ),
                        if (viewModel.selectedCategory != null) ...[
                          const SizedBox(height: 16),
                          _buildDropdown(
                            label: 'post_ad.subcategory'.tr(),
                            value: viewModel.selectedSubCategory,
                            items: viewModel.subCategories[viewModel.selectedCategory] ?? [],
                            onChanged: viewModel.setSubCategory,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Photos Section
                  _buildSectionHeader('post_ad.section_photos'.tr()),
                  const SizedBox(height: 8),
                  _buildCard(
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
                  _buildSectionHeader('post_ad.section_location'.tr()),
                  _buildCard(
                    child: _buildDropdown(
                      label: 'post_ad.region'.tr(),
                      value: viewModel.selectedRegion,
                      items: viewModel.regions,
                      onChanged: viewModel.setRegion,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader('post_ad.section_video'.tr()),
                  _buildCard(
                    child: _buildTextField(
                      label: 'post_ad.video_hint'.tr(),
                      onChanged: viewModel.setVideoLink,
                      maxLength: 1024,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Dynamic Specs
                  if (viewModel.selectedSubCategory != null) ...[
                    _buildSectionHeader('post_ad.section_specs'.tr()),
                    _buildCard(
                      child: Column(
                        children: [
                          _buildTextField(label: 'post_ad.brand'.tr(), onChanged: (_) {}),
                          _buildTextField(label: 'post_ad.condition'.tr(), onChanged: (_) {}),
                          if (viewModel.selectedSubCategory == 'Computer') ...[
                            _buildTextField(label: 'post_ad.slots'.tr(), onChanged: (_) {}),
                            _buildTextField(label: 'post_ad.power'.tr(), onChanged: (_) {}),
                            _buildTextField(label: 'post_ad.docking'.tr(), onChanged: (_) {}),
                          ],
                          _buildTextField(label: 'post_ad.description'.tr(), onChanged: (_) {}, maxLines: 4),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Bulk Price
                  _buildBulkPriceSection(viewModel),
                  const SizedBox(height: 24),

                  // Subscription
                  _buildSectionHeader('post_ad.section_promo'.tr()),
                  _buildCard(child: _buildSubscriptionOptions(viewModel)),
                  const SizedBox(height: 40),

                  // Submit Button
                  // Submit Button
                  _buildSubmitButton(viewModel),
                  const SizedBox(height: 120),
                ],
              ),
            ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: kcVeryLightGrey),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: kcPrimaryColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTitleInput(VendreViewModel viewModel) {
    bool hasError = !viewModel.isTitleValid && viewModel.title.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'post_ad.input_label_title'.tr().toUpperCase(),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kcPrimaryColor),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLength: 70,
          onChanged: viewModel.setTitle,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'post_ad.input_title'.tr(),
            hintStyle: TextStyle(color: kcMediumGrey.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.normal),
            counterText: '${viewModel.title.length}/70',
            filled: true,
            fillColor: kcVeryLightGrey.withOpacity(0.15),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        if (hasError)
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

  Widget _buildPriceInput(VendreViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'post_ad.price'.tr().toUpperCase(),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kcPrimaryColor),
        ),
        const SizedBox(height: 8),
        TextField(
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: kcVeryLightGrey.withOpacity(0.5)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: kcTabIndicatorColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required Function(String) onChanged,
    int? maxLength,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kcPrimaryColor),
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: onChanged,
            maxLength: maxLength,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              filled: true,
              fillColor: kcVeryLightGrey.withOpacity(0.15),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: kcVeryLightGrey.withOpacity(0.5)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: kcTabIndicatorColor, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
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
            child: Column(
              children: [
                _buildDropdown(
                  label: 'post_ad.bulk_size'.tr(),
                  value: viewModel.selectedBulkSize,
                  items: viewModel.bulkSizes,
                  onChanged: viewModel.setBulkSize,
                ),
                if (viewModel.selectedBulkSize != null) ...[
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'post_ad.bulk_price_from'.tr(namedArgs: {'size': viewModel.selectedBulkSize!}),
                    onChanged: (val) {},
                    keyboardType: TextInputType.number,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => viewModel.addBulkPrice(viewModel.selectedBulkSize!, '0'),
                          style: TextButton.styleFrom(
                            backgroundColor: kcPrimaryColor,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text('post_ad.btn_save_bulk'.tr(), style: const TextStyle(color: kcTabIndicatorColor, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
                if (viewModel.bulkPrices.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: viewModel.bulkPrices.length,
                    itemBuilder: (context, index) {
                      final bp = viewModel.bulkPrices[index];
                      return ListTile(
                        dense: true,
                        title: Text('${bp['size']} pieces', style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: Text('${bp['price']} GHS', style: const TextStyle(color: kcTabIndicatorColor, fontWeight: FontWeight.bold)),
                        leading: IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                          onPressed: () => viewModel.removeBulkPrice(index),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSubscriptionOptions(VendreViewModel viewModel) {
    final subscriptions = ['Free', 'Top Promo', 'Premium Subscription'];
    return Column(
      children: subscriptions.map((sub) {
        bool isSelected = viewModel.selectedSubscription == sub;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border.all(color: isSelected ? kcTabIndicatorColor : kcVeryLightGrey, width: isSelected ? 2 : 1),
          ),
          child: RadioListTile<String>(
            title: Text(sub, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? kcPrimaryColor : kcMediumGrey)),
            value: sub,
            groupValue: viewModel.selectedSubscription,
            onChanged: viewModel.setSubscription,
            activeColor: kcTabIndicatorColor,
            secondary: Icon(
              sub == 'Free' ? Icons.fiber_new_outlined : sub == 'Top Promo' ? Icons.trending_up : Icons.star_outline,
              color: isSelected ? kcTabIndicatorColor : kcMediumGrey,
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
          'post_ad.btn_submit'.tr(),
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
