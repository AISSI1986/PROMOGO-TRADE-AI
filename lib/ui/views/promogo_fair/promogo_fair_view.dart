import 'package:flutter/material.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:country_picker/country_picker.dart';
import 'promogo_fair_viewmodel.dart';
import 'dart:ui'; // For BackdropFilter

class PromogoFairView extends StackedView<PromogoFairViewModel> {
  const PromogoFairView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    PromogoFairViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.white, // "le deriere es blanc"
      body: Stack(
        children: [
          // Background Image (Only at the top 35%)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight(context) * 0.32, // Image slightly smaller so it moves everything up
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/promogo_fair_background.png'), 
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                      Colors.black.withOpacity(0.4), // dark fade at the bottom to contrast the badge
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Registration Card (Aminci avec des marges latérales)
          Positioned(
            top: screenHeight(context) * 0.29, 
            left: 16, // Shrink from left
            right: 16, // Shrink from right
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF3EFEF), // Very light soft color for the form background, matching screenshot
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    children: [
                      // Space for the overlapping badge
                      const SizedBox(height: 30),
                      
                      // Handler bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      verticalSpaceMedium,
                      
                      const Text(
                        'INSCRIPTION STAND',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF132238),
                          letterSpacing: 1.5,
                        ),
                      ),
                      verticalSpaceLarge,

                      // Form Fields (Rétrécis / Avec des marges latérales)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            _buildInputField(
                              icon: Icons.person,
                              hint: 'Nom complet',
                              onChanged: viewModel.setFullName,
                            ),
                            verticalSpaceMedium,

                            _buildInputField(
                              icon: Icons.phone_android_rounded,
                              hint: 'WhatsApp / Téléphone',
                              keyboardType: TextInputType.phone,
                              onChanged: viewModel.setPhone,
                            ),
                            verticalSpaceMedium,

                            _buildCountrySelector(context, viewModel),
                            verticalSpaceMedium,

                            _buildInputField(
                              icon: Icons.work,
                              hint: 'Nom de l\'entreprise',
                              onChanged: viewModel.setCompanyName,
                            ),
                            verticalSpaceMedium,

                            _buildStandTypeSelector(viewModel),
                            verticalSpaceMedium,

                            _buildSectorSelector(viewModel),
                            const SizedBox(height: 40),

                            // Register Button
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton(
                                onPressed: viewModel.preRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF132238), // Dark Navy
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                  shadowColor: const Color(0xFF132238).withOpacity(0.5),
                                ),
                                child: const Text(
                                  'PRÉINSCRIRE',
                                  style: TextStyle(
                                    color: kcTabIndicatorColor, // Gold text
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // PromoGo Fair Badge (Détaché du formulaire, entièrement sur l'image)
          Positioned(
            top: screenHeight(context) * 0.16, // Positioned much higher up, completely inside the image
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF132238).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'PromoGo ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Fair',
                      style: TextStyle(
                        color: kcTabIndicatorColor, // Gold color
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: 45,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5), // Gives the arrow an opaque background so it's always visible
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: const EdgeInsets.only(left: 6), // center the iOS arrow
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                onPressed: viewModel.goBack,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    required Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBEB), // Very slight variation for the fields
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        onChanged: onChanged,
        keyboardType: keyboardType,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15, fontWeight: FontWeight.normal),
          prefixIcon: Icon(icon, color: kcTabIndicatorColor, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildCountrySelector(BuildContext context, PromogoFairViewModel viewModel) {
    return InkWell(
      onTap: () {
        showCountryPicker(
          context: context,
          onSelect: (Country country) {
            viewModel.setCountry(country.name);
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0EBEB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.public, color: kcTabIndicatorColor, size: 22),
            const SizedBox(width: 12),
            Text(
              viewModel.country,
              style: TextStyle(
                color: viewModel.country == 'Pays de provenance' ? Colors.grey[400] : Colors.black87,
                fontSize: 15,
                fontWeight: viewModel.country == 'Pays de provenance' ? FontWeight.normal : FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(Icons.keyboard_arrow_down, color: kcTabIndicatorColor, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStandTypeSelector(PromogoFairViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBEB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.storefront_rounded, color: kcTabIndicatorColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Type de Stand',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _buildOptionButton('Petit', viewModel),
          const SizedBox(width: 8),
          _buildOptionButton('Moyen', viewModel),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String label, PromogoFairViewModel viewModel) {
    bool isSelected = viewModel.standType == label;
    return InkWell(
      onTap: () => viewModel.setStandType(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF132238) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? kcTabIndicatorColor : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSectorSelector(PromogoFairViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBEB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_graph_rounded, color: kcTabIndicatorColor, size: 22),
          const SizedBox(width: 12),
          Text(
            viewModel.sector,
            style: TextStyle(
              color: viewModel.sector == 'Secteur d\'activité' ? Colors.grey[400] : Colors.black87,
              fontSize: 15,
              fontWeight: viewModel.sector == 'Secteur d\'activité' ? FontWeight.normal : FontWeight.w600,
            ),
          ),
          const Spacer(),
          Icon(Icons.keyboard_arrow_down, color: kcTabIndicatorColor, size: 24),
        ],
      ),
    );
  }

  @override
  PromogoFairViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      PromogoFairViewModel();
}

