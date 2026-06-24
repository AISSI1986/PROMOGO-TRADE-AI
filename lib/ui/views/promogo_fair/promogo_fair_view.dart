import 'package:flutter/material.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:country_picker/country_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'promogo_fair_viewmodel.dart';

class PromogoFairView extends StackedView<PromogoFairViewModel> {
  const PromogoFairView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    PromogoFairViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image (top 35%)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight(context) * 0.32,
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
                      Colors.black.withOpacity(0.4),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Registration Card
          Positioned(
            top: screenHeight(context) * 0.29,
            left: 16,
            right: 16,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF3EFEF),
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

                      Text(
                        'INSCRIPTION STAND',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF132238),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Remplissez ce formulaire pour réserver votre stand.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      verticalSpaceLarge,

                      // Form Fields
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            _buildInputField(
                              icon: Icons.person,
                              hint: 'Nom complet *',
                              initialValue: viewModel.fullName,
                              onChanged: viewModel.setFullName,
                            ),
                            verticalSpaceMedium,

                            _buildInputField(
                              icon: Icons.phone_android_rounded,
                              hint: 'WhatsApp / Téléphone *',
                              keyboardType: TextInputType.phone,
                              initialValue: viewModel.phone,
                              onChanged: viewModel.setPhone,
                            ),
                            verticalSpaceMedium,

                            _buildInputField(
                              icon: Icons.email_outlined,
                              hint: 'Adresse e-mail *',
                              keyboardType: TextInputType.emailAddress,
                              initialValue: viewModel.email,
                              onChanged: viewModel.setEmail,
                            ),
                            verticalSpaceMedium,

                            _buildCountrySelector(context, viewModel),
                            verticalSpaceMedium,

                            _buildInputField(
                              icon: Icons.work,
                              hint: "Nom de l'entreprise (optionnel)",
                              onChanged: viewModel.setCompanyName,
                            ),
                            verticalSpaceMedium,

                            _buildStandTypeSelector(viewModel),
                            verticalSpaceMedium,

                            _buildSectorSelector(context, viewModel),
                            const SizedBox(height: 40),

                            // Register Button
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton(
                                onPressed: viewModel.isSubmitting
                                    ? null
                                    : () => _handleSubmit(context, viewModel),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF132238),
                                  disabledBackgroundColor:
                                      const Color(0xFF132238).withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                  shadowColor:
                                      const Color(0xFF132238).withOpacity(0.5),
                                ),
                                child: viewModel.isSubmitting
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: kcTabIndicatorColor,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Text(
                                        'PRÉINSCRIRE',
                                        style: GoogleFonts.outfit(
                                          color: kcTabIndicatorColor,
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

          // PromoGo Fair Badge
          Positioned(
            top: screenHeight(context) * 0.16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF132238).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.1), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5))
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
                        color: kcTabIndicatorColor,
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
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: const EdgeInsets.only(left: 6),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                onPressed: viewModel.goBack,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Handles form submit: calls preRegister, shows error or success
  Future<void> _handleSubmit(BuildContext context, PromogoFairViewModel viewModel) async {
    final result = await viewModel.preRegister();
    if (result == null) return;
    if (!context.mounted) return;

    if (result.containsKey('error')) {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['error'].toString(),
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } else if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>? ?? {};
      final confirmationCode =
          (data['confirmation_code'] as String?) ?? 'FAIR-XXXXXX';
      _showSuccessDialog(context, confirmationCode, viewModel);
    }
  }

  void _showSuccessDialog(
      BuildContext context, String confirmationCode, PromogoFairViewModel viewModel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF132238), Color(0xFF1E3A5F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF132238).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Pré-inscription Confirmée !',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF132238),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                Text(
                  'Votre demande a été enregistrée avec succès. Notre équipe vous contactera pour confirmer votre stand.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Confirmation code
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  decoration: BoxDecoration(
                    color: kcTabIndicatorColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: kcTabIndicatorColor.withOpacity(0.4), width: 1),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Code de confirmation',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        confirmationCode,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF132238),
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Conservez ce code, il vous sera demandé à l\'entrée.',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      viewModel.goBack();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF132238),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Parfait, Merci !',
                      style: GoogleFonts.inter(
                        color: kcTabIndicatorColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField({
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    String? initialValue,
    required Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        keyboardType: keyboardType,
        controller: initialValue != null && initialValue.isNotEmpty
            ? (TextEditingController(text: initialValue)
              ..selection = TextSelection.fromPosition(
                  TextPosition(offset: initialValue.length)))
            : null,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: Colors.grey[400], fontSize: 15, fontWeight: FontWeight.normal),
          prefixIcon: Icon(icon, color: kcTabIndicatorColor, size: 22),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildCountrySelector(
      BuildContext context, PromogoFairViewModel viewModel) {
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.public, color: kcTabIndicatorColor, size: 22),
            const SizedBox(width: 12),
            Text(
              viewModel.country,
              style: TextStyle(
                color: viewModel.country == 'Pays de provenance'
                    ? Colors.grey[400]
                    : Colors.black87,
                fontSize: 15,
                fontWeight: viewModel.country == 'Pays de provenance'
                    ? FontWeight.normal
                    : FontWeight.w600,
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
    final types = ['Petit', 'Moyen', 'Grand', 'VIP'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront_rounded,
                  color: kcTabIndicatorColor, size: 22),
              const SizedBox(width: 12),
              Text(
                'Type de Stand',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: types
                .map((type) => _buildOptionButton(type, viewModel))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String label, PromogoFairViewModel viewModel) {
    final isSelected = viewModel.standType == label;
    final isVip = label == 'VIP';
    return GestureDetector(
      onTap: () => viewModel.setStandType(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isVip ? kcTabIndicatorColor : const Color(0xFF132238))
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (isVip ? kcTabIndicatorColor : const Color(0xFF132238))
                : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (isVip ? const Color(0xFF132238) : kcTabIndicatorColor)
                : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSectorSelector(
      BuildContext context, PromogoFairViewModel viewModel) {
    return GestureDetector(
      onTap: () => _showSectorBottomSheet(context, viewModel),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_graph_rounded,
                color: kcTabIndicatorColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                viewModel.sector,
                style: TextStyle(
                  color: viewModel.sector == "Secteur d'activité"
                      ? Colors.grey[400]
                      : Colors.black87,
                  fontSize: 15,
                  fontWeight: viewModel.sector == "Secteur d'activité"
                      ? FontWeight.normal
                      : FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down,
                color: kcTabIndicatorColor, size: 24),
          ],
        ),
      ),
    );
  }

  void _showSectorBottomSheet(
      BuildContext context, PromogoFairViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  // Handle + titre (fixed en haut)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Secteur d'activité",
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF132238),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                      ],
                    ),
                  ),
                  // Liste scrollable
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      children: [
                        ...viewModel.sectors.map((sector) {
                          final isSelected = viewModel.sector == sector;
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF132238)
                                    : Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                color: isSelected ? kcTabIndicatorColor : Colors.transparent,
                                size: 18,
                              ),
                            ),
                            title: Text(
                              sector,
                              style: GoogleFonts.inter(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected
                                    ? const Color(0xFF132238)
                                    : Colors.grey[700],
                              ),
                            ),
                            onTap: () {
                              viewModel.setSector(sector);
                              Navigator.of(ctx).pop();
                            },
                          );
                        }),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  PromogoFairViewModel viewModelBuilder(BuildContext context) =>
      PromogoFairViewModel();

  @override
  void onViewModelReady(PromogoFairViewModel viewModel) {
    viewModel.initAutoFill();
  }
}
