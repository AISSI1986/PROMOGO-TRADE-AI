import 'package:flutter/material.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'otp_viewmodel.dart';

class OtpView extends StackedView<OtpViewModel> {
  final String phoneNumber;
  const OtpView({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  void onViewModelReady(OtpViewModel viewModel) {
    viewModel.init(phoneNumber);
    super.onViewModelReady(viewModel);
  }

  @override
  Widget builder(BuildContext context, OtpViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: viewModel.goBack,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vérification OTP',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              verticalSpaceSmall,
              Text(
                'Un code a été envoyé au $phoneNumber. Veuillez le saisir ci-dessous.',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              verticalSpaceLarge,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => _OtpDigitInput(index: index, viewModel: viewModel)),
              ),
              verticalSpaceLarge,
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: viewModel.verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kcPrimaryColor,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: const Text('Vérifier', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              verticalSpaceMedium,
              Center(
                child: Text(
                  viewModel.formattedTime,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
              verticalSpaceMedium,
              Center(
                child: TextButton(
                  onPressed: viewModel.timerSeconds == 0 ? viewModel.resendCode : null,
                  child: Text(
                    'Renvoyer le code',
                    style: TextStyle(
                      color: viewModel.timerSeconds == 0 ? kcPrimaryColor : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              verticalSpaceLarge,
            ],
          ),
        ),
      ),
    );
  }

  @override
  OtpViewModel viewModelBuilder(BuildContext context) => OtpViewModel();
}

class _OtpDigitInput extends StatelessWidget {
  final int index;
  final OtpViewModel viewModel;

  const _OtpDigitInput({Key? key, required this.index, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Controller pour gérer la valeur (utile pour le coller automatique)
    final controller = TextEditingController(text: viewModel.otpDigits[index]);
    controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));

    return SizedBox(
      width: 48,
      height: 55,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 6,
        onChanged: (value) {
          viewModel.updateDigit(index, value);
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.grey[100],
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
