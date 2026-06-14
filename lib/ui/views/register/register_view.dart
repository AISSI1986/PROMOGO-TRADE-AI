import 'package:flutter/material.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:country_picker/country_picker.dart';
import 'register_viewmodel.dart';

class RegisterView extends StackedView<RegisterViewModel> {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, RegisterViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: viewModel.previousStep,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: viewModel.pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: viewModel.setStep,
              children: [
                _StepPhone(),
                _StepPersonalInfo(),
              ],
            ),
          ),
        ],
      ),

    );
  }

  @override
  RegisterViewModel viewModelBuilder(BuildContext context) => RegisterViewModel();

  @override
  void onViewModelReady(RegisterViewModel viewModel) => viewModel.init();
}

class _StepPersonalInfo extends ViewModelWidget<RegisterViewModel> {
  @override
  Widget build(BuildContext context, RegisterViewModel viewModel) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations personnelles',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            verticalSpaceSmall,
            const Text(
              'Renseignez vos informations avec précision telles que figurées sur votre pièce d\'identité.',
              style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
            ),
            verticalSpaceLarge,
            
            // --- NOMS ---
            _buildTextField(
              label: 'Votre Nom',
              icon: Icons.person_outline,
              controller: viewModel.lastNameController,
              onChanged: (val) {
                viewModel.lastName = val;
                viewModel.updateField();
              },
            ),
            verticalSpaceMedium,
            _buildTextField(
              label: 'Votre Prénom',
              icon: Icons.person_outline,
              controller: viewModel.firstNameController,
              onChanged: (val) {
                viewModel.firstName = val;
                viewModel.updateField();
              },
            ),
            verticalSpaceMedium,
            _buildTextField(
              label: 'Adresse E-mail',
              icon: Icons.email_outlined,
              controller: viewModel.emailController,
              onChanged: (val) {
                viewModel.email = val;
                viewModel.updateField();
              },
            ),
            verticalSpaceMedium,
            _buildTextField(
              label: 'Votre Adresse (Ville, Pays)',
              icon: Icons.location_on,
              controller: viewModel.adresseController,
              onChanged: (val) {
                viewModel.adresse = val;
                viewModel.updateField();
              },
            ),
            verticalSpaceMedium,

            // --- RÔLE (Client / Vendeur) ---
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 2.0),
              child: Text(
                'QUEL EST VOTRE PROFIL ?',
                style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _buildRoleOption(
                    viewModel,
                    title: 'Client',
                    isSeller: false,
                    icon: Icons.shopping_bag_outlined,
                  ),
                ),
                horizontalSpaceMedium,
                Expanded(
                  child: _buildRoleOption(
                    viewModel,
                    title: 'Vendeur',
                    isSeller: true,
                    icon: Icons.storefront_outlined,
                  ),
                ),
              ],
            ),
            verticalSpaceMedium,

            // --- NOM DE LA BOUTIQUE (Vendeur Uniquement) ---
            if (viewModel.isSeller) ...[
              _buildTextField(
                label: 'Nom de la boutique',
                icon: Icons.store_outlined,
                controller: viewModel.shopNameController,
                onChanged: (val) {
                  viewModel.shopName = val;
                  viewModel.updateField();
                },
              ),
              verticalSpaceMedium,
            ],

            // --- NATIONALITÉ ---
            InkWell(
              onTap: () {
                showCountryPicker(
                  context: context,
                  onSelect: (Country country) {
                    viewModel.nationality = country.name;
                    viewModel.nationalityCode = country.countryCode.toLowerCase();
                    viewModel.notifyListeners();
                  },
                );
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Votre Nationalité',
                  labelStyle: TextStyle(color: Colors.grey[500], fontSize: 15, fontWeight: FontWeight.normal),
                  floatingLabelStyle: const TextStyle(color: Color(0xFF0A1F44), fontWeight: FontWeight.bold),
                  // Force le label à rester en haut même s'il n'y a pas de curseur actif
                  floatingLabelBehavior: FloatingLabelBehavior.always, 
                  prefixIcon: Icon(Icons.public, color: Colors.grey[400], size: 22),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      _getFlag(viewModel.nationalityCode),
                      style: const TextStyle(fontSize: 22),
                    ),
                    horizontalSpaceSmall,
                    Text(viewModel.nationality, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                    const Spacer(),
                    Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
            verticalSpaceMedium,

            // --- GENRE / CIVILITÉ ---
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 2.0),
              child: Text(
                'VOTRE CIVILITÉ',
                style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ),
            Row(
              children: [
                Expanded(child: _buildGenderOption(viewModel, 'Homme', Icons.male)),
                horizontalSpaceMedium,
                Expanded(child: _buildGenderOption(viewModel, 'Femme', Icons.female)),
              ],
            ),
            verticalSpaceMedium,

            // --- PROFESSION ---
            _buildTextField(
              label: 'Profession',
              icon: Icons.work_outline,
              controller: viewModel.professionController,
              onChanged: (val) {
                viewModel.profession = val;
                viewModel.updateField();
              },
            ),
            verticalSpaceMedium,

            // --- SÉCURITÉ ---
            _buildTextField(
              label: 'Votre mot de passe',
              icon: Icons.lock_outline,
              controller: viewModel.passwordController,
              obscureText: true,
              onChanged: (val) {
                viewModel.password = val;
                viewModel.updateField();
              },
            ),
            verticalSpaceMedium,
            _buildTextField(
              label: 'Confirmer votre mot de passe',
              icon: Icons.lock_outline,
              controller: viewModel.confirmPasswordController,
              obscureText: true,
              onChanged: (val) {
                viewModel.confirmPassword = val;
                viewModel.updateField();
              },
            ),
            const SizedBox(height: 40),

            // --- CGU ---
            const Center(
              child: Column(
                children: [
                  Text('En continuant, vous acceptez nos', style: TextStyle(fontSize: 13, color: Colors.grey)),
                  SizedBox(height: 4),
                  Text(
                    'Conditions Générales d\'Utilisation\net Politique de confidentialité',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: kcPrimaryColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            verticalSpaceLarge,
            
            // Bouton Finaliser intégré au scroll
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: viewModel.nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kcPrimaryColor,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                child: const Text(
                  'Finaliser',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            verticalSpaceLarge,

          ],
        ),
      ),
    );
  }

  String _getFlag(String code) {
    if (code.isEmpty) return '🏳️';
    return code.toUpperCase().replaceAllMapped(RegExp(r'[A-Z]'),
        (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397));
  }

  Widget _buildGenderOption(RegisterViewModel viewModel, String value, IconData icon) {
    bool isSelected = viewModel.gender == value;
    return InkWell(
      onTap: () => viewModel.updateGender(value),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? kcPrimaryColor : Colors.grey[300]!, width: 1.5),
          color: isSelected ? kcPrimaryColor.withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? kcPrimaryColor : Colors.grey[400], size: 22),
            horizontalSpaceSmall,
            Text(value, style: TextStyle(
              fontSize: 15, 
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? kcPrimaryColor : Colors.black87
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleOption(RegisterViewModel viewModel, {required String title, required bool isSeller, required IconData icon}) {
    bool isSelected = viewModel.isSeller == isSeller;
    return InkWell(
      onTap: () => viewModel.updateRole(isSeller),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? kcPrimaryColor : Colors.grey[300]!, width: 2.0),
          color: isSelected ? kcPrimaryColor.withOpacity(0.05) : Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? kcPrimaryColor : Colors.grey[400], size: 28),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(
              fontSize: 14, 
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? kcPrimaryColor : Colors.black87
            )),
          ],
        ),
      ),
    );
  }
}

class _StepPhone extends ViewModelWidget<RegisterViewModel> {
  @override
  Widget build(BuildContext context, RegisterViewModel viewModel) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Numéro de téléphone', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            verticalSpaceSmall,
            const Text(
              'Renseignez votre numéro de téléphone valide que vous voulez associer au compte.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            verticalSpaceLarge,
            Row(
              children: [
                InkWell(
                  onTap: () {
                    showCountryPicker(
                      context: context,
                      onSelect: (Country country) {
                        viewModel.phoneCountryCode = country.phoneCode;
                        viewModel.phoneIsoCode = country.countryCode.toLowerCase();
                        viewModel.notifyListeners();
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.zero,
                    ),
                    child: Row(
                      children: [
                        Text(_getFlag(viewModel.phoneIsoCode), style: const TextStyle(fontSize: 20)),
                        horizontalSpaceTiny,
                        Text('+${viewModel.phoneCountryCode}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        horizontalSpaceTiny,
                        const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                horizontalSpaceMedium,
                Expanded(
                  child: TextField(
                    controller: viewModel.phoneController,
                    keyboardType: TextInputType.phone,
                    onChanged: (val) {
                      viewModel.phoneNumber = val;
                      viewModel.updateField();
                      if (viewModel.hasPhoneError) {
                         viewModel.hasPhoneError = false;
                         viewModel.notifyListeners();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Numéro de téléphone',
                      errorText: viewModel.hasPhoneError ? viewModel.phoneErrorMessage : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(color: viewModel.hasPhoneError ? Colors.red : Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(color: viewModel.hasPhoneError ? Colors.red : Colors.grey),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            verticalSpaceMedium,
            Row(
              children: [
                const Text('Avez-vous déjà un compte ? ', style: TextStyle(fontSize: 13)),
                InkWell(
                  onTap: viewModel.navigateToLogin,
                  child: const Text('Connectez-vous', style: TextStyle(color: kcPrimaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
            verticalSpaceLarge,
            
            // Bouton Suivant intégré au scroll
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: viewModel.nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kcPrimaryColor,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                child: const Text(
                  'Suivant',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            verticalSpaceLarge,

          ],
        ),
      ),
    );
  }

  String _getFlag(String code) {
    return code.toUpperCase().replaceAllMapped(RegExp(r'[A-Z]'),
        (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397));
  }
}


Widget _buildTextField(
    {required String label,
    required IconData icon,
    TextEditingController? controller,
    bool obscureText = false,
    required Function(String) onChanged}) {
  return SizedBox(
    height: 60, 
    child: TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      decoration: InputDecoration(
        labelText: label, // IMPORTANT: Utilise labelText au lieu de hintText (s'anime quand on clique)
        labelStyle: TextStyle(color: Colors.grey[500], fontSize: 15, fontWeight: FontWeight.normal),
        floatingLabelStyle: const TextStyle(color: Color(0xFF0A1F44), fontWeight: FontWeight.bold),
        prefixIcon: Icon(icon, color: Colors.grey[400], size: 22),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Color(0xFF0A1F44), width: 2), // Focus en bleu nuit premium
        ),
      ),
    ),
  );
}
