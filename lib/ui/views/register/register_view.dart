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
                _StepNames(),
                _StepNationality(),
                _StepGender(),
                _StepProfession(),
                _StepPhone(),
                _StepPassword(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: viewModel.nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kcPrimaryColor,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                child: Text(
                  viewModel.currentStep == 5 ? 'Finaliser' : 'Suivant',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  RegisterViewModel viewModelBuilder(BuildContext context) => RegisterViewModel();
}

class _StepNames extends ViewModelWidget<RegisterViewModel> {
  @override
  Widget build(BuildContext context, RegisterViewModel viewModel) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nom et prénom',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            verticalSpaceSmall,
            const Text(
              'Renseignez votre nom et prénom tels que figurés sur votre pièce d\'identité.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            verticalSpaceLarge,
            _buildTextField(
              label: 'NOM',
              icon: Icons.person_outline,
              onChanged: (val) => viewModel.lastName = val,
            ),
            verticalSpaceMedium,
            _buildTextField(
              label: 'PRÉNOM',
              icon: Icons.person_outline,
              onChanged: (val) => viewModel.firstName = val,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepNationality extends ViewModelWidget<RegisterViewModel> {
  @override
  Widget build(BuildContext context, RegisterViewModel viewModel) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nationalité', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            verticalSpaceSmall,
            const Text('Précisez votre nationalité.', style: TextStyle(fontSize: 14, color: Colors.grey)),
            verticalSpaceLarge,
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
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.zero,
                ),
                child: Row(
                  children: [
                    Text(
                      _getFlag(viewModel.nationalityCode),
                      style: const TextStyle(fontSize: 24),
                    ),
                    horizontalSpaceMedium,
                    Text(viewModel.nationality, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    const Icon(Icons.search, color: Colors.grey),
                  ],
                ),
              ),
            ),
            verticalSpaceMedium,
            const Text('Rechercher une nationalité', style: TextStyle(color: Colors.grey)),
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

class _StepGender extends ViewModelWidget<RegisterViewModel> {
  @override
  Widget build(BuildContext context, RegisterViewModel viewModel) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Civilité H/F', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            verticalSpaceSmall,
            const Text('Précisez votre civilité', style: TextStyle(fontSize: 14, color: Colors.grey)),
            verticalSpaceLarge,
            _buildGenderOption(viewModel, 'Homme', Icons.person),
            verticalSpaceMedium,
            _buildGenderOption(viewModel, 'Femme', Icons.person_3_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderOption(RegisterViewModel viewModel, String value, IconData icon) {
    bool isSelected = viewModel.gender == value;
    return InkWell(
      onTap: () => viewModel.updateGender(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? kcPrimaryColor : Colors.grey[300]!),
          borderRadius: BorderRadius.zero,
          color: isSelected ? kcPrimaryColor.withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54),
            horizontalSpaceMedium,
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Spacer(),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? kcPrimaryColor : Colors.grey,
            ),
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
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.zero,
                    ),
                    child: Row(
                      children: [
                        Text(_getFlag(viewModel.phoneIsoCode), style: const TextStyle(fontSize: 20)),
                        horizontalSpaceTiny,
                        const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                horizontalSpaceMedium,
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.phone,
                    onChanged: (val) => viewModel.phoneNumber = val,
                    decoration: const InputDecoration(
                      hintText: 'Numéro de téléphone',
                      filled: true,
                      fillColor: Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide.none,
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

class _StepProfession extends ViewModelWidget<RegisterViewModel> {
  @override
  Widget build(BuildContext context, RegisterViewModel viewModel) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Profession', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            verticalSpaceSmall,
            const Text('Précisez votre profession.', style: TextStyle(fontSize: 14, color: Colors.grey)),
            verticalSpaceLarge,
            _buildTextField(
              label: 'PROFESSION',
              icon: Icons.wallet_travel_outlined,
              onChanged: (val) => viewModel.profession = val,
            ),
            verticalSpaceLarge,
            const Center(
              child: Column(
                children: [
                  Text('En continuant, vous acceptez nos', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(
                    'Conditions Générales d\'Utilisation\net Politique de confidentialité',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: kcPrimaryColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepPassword extends ViewModelWidget<RegisterViewModel> {
  @override
  Widget build(BuildContext context, RegisterViewModel viewModel) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sécurité', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            verticalSpaceSmall,
            const Text('Définissez votre mot de passe pour sécuriser votre compte.',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            verticalSpaceLarge,
            _buildTextField(
              label: 'MOT DE PASSE',
              icon: Icons.lock_outline,
              obscureText: true,
              onChanged: (val) => viewModel.password = val,
            ),
            verticalSpaceMedium,
            _buildTextField(
              label: 'CONFIRMER LE MOT DE PASSE',
              icon: Icons.lock_outline,
              obscureText: true,
              onChanged: (val) => viewModel.confirmPassword = val,
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildTextField(
    {required String label,
    required IconData icon,
    bool obscureText = false,
    required Function(String) onChanged}) {
  return TextField(
    onChanged: onChanged,
    obscureText: obscureText,
    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    decoration: InputDecoration(
      hintText: label,
      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.normal),
      prefixIcon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Icon(icon, color: Colors.black38, size: 24),
      ),
      filled: true,
      fillColor: Colors.grey[200],
      contentPadding: const EdgeInsets.symmetric(vertical: 20),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide.none,
      ),
    ),
  );
}
