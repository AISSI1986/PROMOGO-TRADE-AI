import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:country_picker/country_picker.dart';
import 'login_viewmodel.dart';

class LoginView extends StackedView<LoginViewModel> {
  const LoginView({super.key});

  @override
  Widget builder(BuildContext context, LoginViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpaceSmall,
                Center(
                  child: Image.asset(
                    'assets/images/logo.jpeg',
                    height: 70, // Taille optimisée pour libérer de l'espace
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.shopping_bag_outlined,
                      size: 70,
                      color: kcPrimaryColor,
                    ),
                  ),
                ),
                verticalSpaceMedium, // Espacement réduit
                const Text(
                  'Connexion',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: kcPrimaryColor),
                ),
                verticalSpaceSmall,
                const Text(
                  'Bienvenue sur Promogo. Connectez-vous pour continuer.',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                verticalSpaceMedium, // Espacement réduit pour remonter le formulaire
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
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
                    horizontalSpaceSmall,
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.phone,
                        onChanged: (val) => viewModel.phoneNumber = val,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: 'Téléphone',
                          errorText: viewModel.phoneError,
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpaceMedium,
                TextField(
                  obscureText: true,
                  onChanged: (val) => viewModel.password = val,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    errorText: viewModel.passwordError,
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                  ),
                ),
                verticalSpaceSmall,
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: viewModel.navigateToForgotPassword,
                    child: const Text('Mot de passe oublié ?',
                        style: TextStyle(color: kcPrimaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
                verticalSpaceSmall,
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: viewModel.isBusy ? null : viewModel.login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kcPrimaryColor,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    child: viewModel.isBusy 
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : const Text('Se connecter',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                verticalSpaceMedium, // Espacement réduit
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Vous n'avez pas de compte ? "),
                    TextButton(
                      onPressed: viewModel.navigateToRegister,
                      child: const Text('Inscrivez-vous', style: TextStyle(color: kcPrimaryColor, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getFlag(String code) {
    return code.toUpperCase().replaceAllMapped(RegExp(r'[A-Z]'),
        (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397));
  }

  @override
  LoginViewModel viewModelBuilder(BuildContext context) => LoginViewModel();
}
