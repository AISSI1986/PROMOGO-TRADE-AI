import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'form_devis_viewmodel.dart';

class FormDevisView extends StackedView<FormDevisViewModel> {
  final String? initialDescription;
  final String? initialUnit;
  final int? initialQuantity;
  final String? initialCustomizationType;

  const FormDevisView({
    Key? key,
    this.initialDescription,
    this.initialUnit,
    this.initialQuantity,
    this.initialCustomizationType,
  }) : super(key: key);

  @override
  void onViewModelReady(FormDevisViewModel viewModel) {
    viewModel.init(
      initialDescription: initialDescription,
      initialUnit: initialUnit,
      initialQuantity: initialQuantity,
      initialCustomizationType: initialCustomizationType,
    );
  }

  @override
  Widget builder(
    BuildContext context,
    FormDevisViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kcPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: viewModel.goBack,
        ),
        title: Text(
          'rfq.title'.tr(),
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Premium Background Layer
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    kcBackgroundColor,
                    Colors.white,
                    kcBackgroundColor.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AnimatedEntrance(
                        delay: 100,
                        child: _buildCustomizationTypeSelector(viewModel),
                      ),
                      const SizedBox(height: 30),
                      _AnimatedEntrance(
                        delay: 180,
                        child: _buildVisualCustomizerSection(context, viewModel),
                      ),
                      const SizedBox(height: 30),
                      _AnimatedEntrance(
                        delay: 250,
                        child: _buildDescriptionSection(viewModel),
                      ),
                      const SizedBox(height: 30),
                      _AnimatedEntrance(
                        delay: 320,
                        child: _buildAttachmentsSection(viewModel),
                      ),
                      const SizedBox(height: 35),
                      _AnimatedEntrance(
                        delay: 400,
                        child: _buildQuantitySection(viewModel),
                      ),
                      const SizedBox(height: 35),
                      _AnimatedEntrance(
                        delay: 480,
                        child: _buildContactPhoneSection(viewModel),
                      ),
                      const SizedBox(height: 35),
                      _AnimatedEntrance(
                        delay: 550,
                        child: _buildCheckboxes(viewModel),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              _AnimatedEntrance(
                delay: 700,
                child: _buildSubmitButton(viewModel),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(FormDevisViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kcPrimaryColor.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                kcBackgroundColor.withOpacity(0.3),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                maxLines: 8,
                controller: viewModel.descriptionController,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: kcDarkGreyColor,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'rfq.form_description_placeholder'.tr(),
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: kcMediumGrey.withOpacity(0.45),
                    fontStyle: FontStyle.italic,
                  ),
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMagicAIButton(viewModel),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: kcBackgroundColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${viewModel.charCount}/8000',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: kcMediumGrey.withOpacity(0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMagicAIButton(FormDevisViewModel viewModel) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: kcSecondaryGold.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: viewModel.generateAIDescription,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: kcSecondaryGold,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(color: kcSecondaryGold.withOpacity(0.4), width: 1.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MetallicIcon(
                  icon: Icons.auto_awesome_rounded,
                  size: 18,
                  colors: [kcSecondaryGold, const Color(0xFFFFD700), kcSecondaryGold],
                ),
                const SizedBox(width: 10),
                Text(
                  'rfq.form_ai_btn'.tr(),
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttachmentsSection(FormDevisViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _MetallicIcon(
              icon: Icons.photo_library_outlined,
              size: 20,
              colors: [kcSecondaryGold, const Color(0xFFFFD700), kcSecondaryGold],
            ),
            const SizedBox(width: 12),
            Text(
              'rfq.form_upload_title'.tr(),
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: kcPrimaryColor,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: kcPrimaryColor.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(color: const Color(0xFFEDF2F7), width: 1.5),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: viewModel.pickLogoImage,
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kcSecondaryGold.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add_rounded, color: kcSecondaryGold, size: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'rfq.form_add_image'.tr(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: kcMediumGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (viewModel.logoFile != null) ...[
              const SizedBox(width: 15),
              Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: FileImage(viewModel.logoFile!),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(color: kcSecondaryGold, width: 1.5),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: viewModel.resetLogo,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildQuantitySection(FormDevisViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _MetallicIcon(
              icon: Icons.inventory_2_outlined,
              size: 20,
              colors: [kcSecondaryGold, const Color(0xFFFFD700), kcSecondaryGold],
            ),
            const SizedBox(width: 12),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'rfq.form_quantity_title'.tr(),
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: kcPrimaryColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                  TextSpan(
                    text: ' *',
                    style: GoogleFonts.outfit(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                height: 58,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFEDF2F7), width: 1.2),
                ),
                child: Center(
                  child: TextField(
                    controller: viewModel.quantityController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kcPrimaryColor,
                    ),
                    decoration: InputDecoration(
                      hintText: 'rfq.form_quantity_hint'.tr(),
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: kcMediumGrey.withOpacity(0.4),
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Container(
                height: 58,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFEDF2F7), width: 1.2),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: viewModel.selectedUnit,
                    icon: const Icon(Icons.unfold_more_rounded, color: kcSecondaryGold, size: 20),
                    isExpanded: true,
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    items: viewModel.units.map((String unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(
                          unit,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: kcPrimaryColor,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: viewModel.updateUnit,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckboxes(FormDevisViewModel viewModel) {
    return Column(
      children: [
        _buildCheckboxRow(
          value: viewModel.shareBusinessCard,
          onChanged: viewModel.toggleShareBusinessCard,
          text: 'rfq.form_share_card'.tr(),
        ),
        const SizedBox(height: 15),
        _buildCheckboxRow(
          value: viewModel.acceptTerms,
          onChanged: viewModel.toggleAcceptTerms,
          text: 'rfq.form_accept_terms'.tr(),
          isRichText: true,
        ),
      ],
    );
  }

  Widget _buildCheckboxRow({
    required bool value,
    required Function(bool?) onChanged,
    required String text,
    bool isRichText = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: kcPrimaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: isRichText
              ? RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(fontSize: 13, color: kcMediumGrey, height: 1.4),
                    children: [
                      TextSpan(text: text.split('publication').first),
                      TextSpan(
                        text: 'publication des demandes d\'achat',
                        style: GoogleFonts.inter(color: Colors.blue, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )
              : Text(
                  text,
                  style: GoogleFonts.inter(fontSize: 13, color: kcMediumGrey, height: 1.4),
                ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(FormDevisViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 15, 25, 35),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        boxShadow: [
          BoxShadow(
            color: kcPrimaryColor.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: -2.0, end: 2.0),
        duration: const Duration(seconds: 4),
        builder: (context, value, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: kcPrimaryColor.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: viewModel.isBusy ? null : () => viewModel.submitForm(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: kcPrimaryColor,
                minimumSize: const Size(double.infinity, 70),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
                padding: EdgeInsets.zero,
              ),
              child: viewModel.isBusy
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment(value - 0.5, 0),
                          end: Alignment(value + 0.5, 0),
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.12),
                            Colors.transparent,
                          ],
                          stops: const [0.3, 0.5, 0.7],
                        ),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          'rfq.form_post_btn'.tr(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomizationTypeSelector(FormDevisViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _MetallicIcon(
              icon: Icons.dashboard_customize_outlined,
              size: 20,
              colors: [kcSecondaryGold, const Color(0xFFFFD700), kcSecondaryGold],
            ),
            const SizedBox(width: 12),
            Text(
              'Type de personnalisation',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: kcPrimaryColor,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildTypeButton(viewModel, 'none', 'Aucune', Icons.close_rounded),
            const SizedBox(width: 10),
            _buildTypeButton(viewModel, 'logo', 'Logo', Icons.style_rounded),
            const SizedBox(width: 10),
            _buildTypeButton(viewModel, 'design', 'Design', Icons.draw_rounded),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeButton(
    FormDevisViewModel viewModel,
    String type,
    String label,
    IconData icon,
  ) {
    final bool isSelected = viewModel.selectedCustomizationType == type;
    return Expanded(
      child: InkWell(
        onTap: () => viewModel.setCustomizationType(type),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? kcPrimaryColor : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected ? kcPrimaryColor : const Color(0xFFEDF2F7),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: kcPrimaryColor.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))]
                : [],
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : kcMediumGrey, size: 20),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : kcDarkGreyColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisualCustomizerSection(BuildContext context, FormDevisViewModel viewModel) {
    if (viewModel.selectedCustomizationType == 'none') {
      return const SizedBox.shrink();
    }

    String templateImgUrl = 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=500&q=80';
    if (viewModel.selectedTemplate == 'Tasse') {
      templateImgUrl = 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=500&q=80';
    } else if (viewModel.selectedTemplate == 'Casquette') {
      templateImgUrl = 'https://images.unsplash.com/photo-1588850561407-ed78c282e89b?w=500&q=80';
    } else if (viewModel.selectedTemplate == 'Sac') {
      templateImgUrl = 'https://images.unsplash.com/photo-1544816155-12df9643f363?w=500&q=80';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _MetallicIcon(
              icon: Icons.palette_outlined,
              size: 20,
              colors: [kcSecondaryGold, const Color(0xFFFFD700), kcSecondaryGold],
            ),
            const SizedBox(width: 12),
            Text(
              'Visualiseur de Personnalisation',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: kcPrimaryColor,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        // Interactive Canvas Container
        Container(
          height: 280,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: Stack(
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            children: [
              // Tinted product image
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  viewModel.selectedProductColor,
                  BlendMode.modulate,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CachedNetworkImage(
                    imageUrl: templateImgUrl,
                    height: 280,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(color: kcPrimaryColor),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50),
                  ),
                ),
              ),
              // Drag-and-drop Logo overlay
              Positioned(
                left: 100 + viewModel.logoOffset.dx,
                top: 70 + viewModel.logoOffset.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    viewModel.updateLogoOffset(
                      viewModel.logoOffset + details.delta,
                    );
                  },
                  child: Transform.rotate(
                    angle: viewModel.logoRotation,
                    child: Transform.scale(
                      scale: viewModel.logoScale,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: kcSecondaryGold.withOpacity(0.5),
                            width: 1.5,
                          ),
                          color: Colors.white.withOpacity(0.1),
                        ),
                        child: viewModel.logoFile != null
                            ? Image.file(
                                viewModel.logoFile!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.contain,
                              )
                            : Container(
                                width: 100,
                                height: 100,
                                alignment: Alignment.center,
                                child: Text(
                                  "LOGOTYPE",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black.withOpacity(0.6),
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              // Tip overlay
              Positioned(
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Glissez le logo pour le déplacer",
                    style: GoogleFonts.inter(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        // Template selector
        Text(
          "Support produit",
          style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: kcMediumGrey),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: viewModel.templates.map((template) {
            final bool isSel = viewModel.selectedTemplate == template;
            return ChoiceChip(
              label: Text(template, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13)),
              selected: isSel,
              selectedColor: kcPrimaryColor,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(color: isSel ? Colors.white : kcDarkGreyColor),
              onSelected: (selected) {
                if (selected) viewModel.updateSelectedTemplate(template);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        // Color selector
        Text(
          "Couleur du support",
          style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: kcMediumGrey),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: viewModel.colors.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final color = viewModel.colors[index];
              final bool isSelected = viewModel.selectedProductColor == color;
              return GestureDetector(
                onTap: () => viewModel.updateProductColor(color),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? kcSecondaryGold : const Color(0xFFCBD5E1),
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: color == Colors.white || color == Colors.yellow ? Colors.black : Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        // Image pick button & control buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: viewModel.pickLogoImage,
                icon: const Icon(Icons.upload_file_rounded, size: 18),
                label: Text("Importer logo", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kcPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.center_focus_strong_rounded, color: kcPrimaryColor),
              onPressed: viewModel.centerLogo,
              tooltip: "Centrer",
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.red),
              onPressed: viewModel.resetLogo,
              tooltip: "Réinitialiser",
            ),
          ],
        ),
        const SizedBox(height: 15),
        // Sliders
        Row(
          children: [
            SizedBox(
              width: 60,
              child: Text("Échelle", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: kcMediumGrey)),
            ),
            Expanded(
              child: Slider(
                value: viewModel.logoScale,
                min: 0.1,
                max: 2.0,
                activeColor: kcPrimaryColor,
                inactiveColor: const Color(0xFFE2E8F0),
                onChanged: viewModel.updateLogoScale,
              ),
            ),
          ],
        ),
        Row(
          children: [
            SizedBox(
              width: 60,
              child: Text("Rotation", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: kcMediumGrey)),
            ),
            Expanded(
              child: Slider(
                value: viewModel.logoRotation,
                min: -3.14,
                max: 3.14,
                activeColor: kcPrimaryColor,
                inactiveColor: const Color(0xFFE2E8F0),
                onChanged: viewModel.updateLogoRotation,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactPhoneSection(FormDevisViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _MetallicIcon(
              icon: Icons.phone_android_rounded,
              size: 20,
              colors: [kcSecondaryGold, const Color(0xFFFFD700), kcSecondaryGold],
            ),
            const SizedBox(width: 12),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'rfq.form_contact_phone_title'.tr(),
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: kcPrimaryColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                  TextSpan(
                    text: ' *',
                    style: GoogleFonts.outfit(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: const Color(0xFFEDF2F7), width: 1.2),
          ),
          child: Center(
            child: TextField(
              controller: viewModel.contactPhoneController,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: kcPrimaryColor,
              ),
              decoration: InputDecoration(
                hintText: 'rfq.form_contact_phone_hint'.tr(),
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: kcMediumGrey.withOpacity(0.4),
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  FormDevisViewModel viewModelBuilder(BuildContext context) => FormDevisViewModel();
}

class _AnimatedEntrance extends StatefulWidget {
  final Widget child;
  final int delay;

  const _AnimatedEntrance({required this.child, required this.delay});

  @override
  State<_AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<_AnimatedEntrance> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _translate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    _translate = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.6, curve: Curves.easeOut)),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(0, _translate.value),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _MetallicIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final List<Color> colors;

  const _MetallicIcon({
    required this.icon,
    this.size = 24.0,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 1,
          top: 1,
          child: Icon(icon, size: size, color: Colors.black.withOpacity(0.35)),
        ),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Icon(icon, size: size, color: Colors.white),
        ),
      ],
    );
  }
}
