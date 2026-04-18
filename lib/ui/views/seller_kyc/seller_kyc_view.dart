import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'seller_kyc_viewmodel.dart';

class SellerKycView extends StackedView<SellerKycViewModel> {
  const SellerKycView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, SellerKycViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('seller_kyc.title'.tr(), style: const TextStyle(color: kcPrimaryColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kcTabIndicatorColor),
          onPressed: viewModel.previousStep,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(viewModel.currentStep),
            Expanded(
              child: _buildStepContent(viewModel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(int currentStep) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: List.generate(7, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: index <= currentStep ? kcPrimaryColor : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(SellerKycViewModel viewModel) {
    switch (viewModel.currentStep) {
      case 0:
        return _buildInfoStep(viewModel);
      case 1:
        return _buildLocationStep(viewModel);
      case 2:
        return _buildConsentStep(viewModel);
      case 3:
        return _buildDocSelectionStep(viewModel);
      case 4:
        return _buildCameraStep(viewModel, isRecto: true);
      case 5:
        return _buildCameraStep(viewModel, isRecto: false);
      case 6:
        return _buildSuccessStep(viewModel);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInfoStep(SellerKycViewModel viewModel) {
    return _buildStepPadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'seller_kyc.step_info'.tr(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kcPrimaryColor),
          ),
          const SizedBox(height: 32),
          _buildTextField(
            label: 'seller_kyc.first_name'.tr(),
            icon: Icons.person_outline,
            onChanged: viewModel.setFirstName,
            initialValue: viewModel.firstName,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'seller_kyc.last_name'.tr(),
            icon: Icons.person_outline,
            onChanged: viewModel.setLastName,
            initialValue: viewModel.lastName,
          ),
          const Spacer(),
          _buildNextButton(viewModel.nextStep),
        ],
      ),
    );
  }

  Widget _buildLocationStep(SellerKycViewModel viewModel) {
    return _buildStepPadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'seller_kyc.step_info'.tr(), // Per user request to use step_info title here
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kcPrimaryColor),
          ),
          const SizedBox(height: 32),
          _buildTextField(
            label: 'seller_kyc.city'.tr(),
            icon: Icons.location_city_outlined,
            onChanged: viewModel.setCity,
            initialValue: viewModel.city,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'seller_kyc.email'.tr(),
            icon: Icons.email_outlined,
            onChanged: viewModel.setEmail,
            initialValue: viewModel.email,
          ),
          const Spacer(),
          _buildNextButton(viewModel.nextStep),
        ],
      ),
    );
  }

  Widget _buildConsentStep(SellerKycViewModel viewModel) {
    return _buildStepPadding(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.privacy_tip_outlined, size: 80, color: kcTabIndicatorColor),
          const SizedBox(height: 32),
          Text(
            'seller_kyc.consent_title'.tr(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kcPrimaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            'seller_kyc.consent_desc'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
          ),
          const Spacer(),
          _buildNextButton(viewModel.nextStep, label: 'seller_kyc.btn_consent'.tr()),
        ],
      ),
    );
  }

  Widget _buildDocSelectionStep(SellerKycViewModel viewModel) {
    final docs = [
      {'id': 'id_card', 'label': 'seller_kyc.doc_id_card'.tr(), 'icon': Icons.badge_outlined},
      {'id': 'passport', 'label': 'seller_kyc.doc_passport'.tr(), 'icon': Icons.menu_book_outlined},
      {'id': 'residence', 'label': 'seller_kyc.doc_residence'.tr(), 'icon': Icons.contact_mail_outlined},
      {'id': 'refugee', 'label': 'seller_kyc.doc_refugee'.tr(), 'icon': Icons.assignment_ind_outlined},
    ];

    return _buildStepPadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'seller_kyc.doc_selection_title'.tr(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 12),
          Text(
            'seller_kyc.doc_selection_subtitle'.tr(),
            style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
          ),
          const SizedBox(height: 32),
          ...docs.map((doc) => _DocOption(
            title: doc['label'] as String,
            icon: doc['icon'] as IconData,
            isSelected: viewModel.selectedDocType == doc['id'],
            onTap: () => viewModel.setDocumentType(doc['id'] as String),
          )),
          const Spacer(),
          _buildNextButton(
            viewModel.selectedDocType.isNotEmpty ? viewModel.nextStep : null, 
            label: 'seller_kyc.btn_continue'.tr()
          ),
        ],
      ),
    );
  }

  Widget _buildCameraStep(SellerKycViewModel viewModel, {required bool isRecto}) {
    final capturedFile = isRecto ? viewModel.idRecto : viewModel.idVerso;

    if (capturedFile != null) {
      return _buildReviewUI(viewModel, capturedFile, isRecto);
    }

    if (!viewModel.isCameraInitialized) {
      return const Center(child: CircularProgressIndicator(color: kcPrimaryColor));
    }

    return Stack(
      children: [
        Positioned.fill(
          child: CameraPreview(viewModel.cameraController!),
        ),
        // Darkened background around the scan area
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Center(
                child: Container(
                  width: 300,
                  height: 190,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Scan Overlay border
        Center(
          child: Container(
            width: 300,
            height: 190,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        Positioned(
          top: 40,
          left: 0,
          right: 0,
          child: Text(
            isRecto ? 'seller_kyc.overlay_recto'.tr() : 'seller_kyc.overlay_verso'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: viewModel.isBusy ? null : viewModel.captureImage,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (viewModel.isBusy)
          const Center(child: CircularProgressIndicator(color: kcTabIndicatorColor)),
      ],
    );
  }

  Widget _buildReviewUI(SellerKycViewModel viewModel, File image, bool isRecto) {
    return _buildStepPadding(
      child: Column(
        children: [
          Text(
            isRecto ? 'seller_kyc.step_id_recto'.tr() : 'seller_kyc.step_id_verso'.tr(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kcPrimaryColor),
          ),
          const SizedBox(height: 40),
          // Preview in the "grid" area
          Container(
            width: 300,
            height: 190,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kcPrimaryColor, width: 2),
              image: DecorationImage(
                image: FileImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 40),
          TextButton.icon(
            onPressed: viewModel.resetCapture,
            icon: const Icon(Icons.refresh, color: Colors.orange),
            label: Text('seller_kyc.btn_back'.tr(), style: const TextStyle(color: Colors.orange)),
          ),
          const Spacer(),
          _buildNextButton(viewModel.nextStep, label: 'seller_kyc.btn_continue'.tr()),
        ],
      ),
    );
  }

  Widget _buildSuccessStep(SellerKycViewModel viewModel) {
    return _buildStepPadding(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 100, color: kcTabIndicatorColor),
          const SizedBox(height: 32),
          Text(
            'seller_kyc.success_title'.tr(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kcPrimaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            'seller_kyc.success_desc'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
          ),
          const Spacer(),
          _buildNextButton(viewModel.finish, label: 'seller_kyc.btn_finish'.tr()),
        ],
      ),
    );
  }

  Widget _buildStepPadding({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: child,
    );
  }

  Widget _buildTextField({
    required String label, 
    required IconData icon,
    required Function(String) onChanged,
    String? initialValue,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.zero,
      ),
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: kcTabIndicatorColor),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: kcPrimaryColor, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildNextButton(VoidCallback? onPressed, {String? label}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kcPrimaryColor,
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          disabledBackgroundColor: Colors.grey[300],
        ),
        onPressed: onPressed,
        child: Text(
          label ?? 'seller_kyc.btn_next'.tr(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  @override
  SellerKycViewModel viewModelBuilder(BuildContext context) => SellerKycViewModel();
}

class _DocOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DocOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ? kcPrimaryColor.withOpacity(0.05) : Colors.grey[50],
            border: Border.all(
              color: isSelected ? kcPrimaryColor : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.zero,
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? kcTabIndicatorColor : Colors.grey[600]),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? kcPrimaryColor : Colors.black87,
                  ),
                ),
              ),
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? kcTabIndicatorColor : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
