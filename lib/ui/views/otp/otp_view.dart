import 'package:flutter/material.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'otp_viewmodel.dart';

class OtpView extends StackedView<OtpViewModel> {
  final String phoneNumber;
  const OtpView({Key? key, required this.phoneNumber}) : super(key: key);

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
      body: Padding(
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
              'Un code a été envoyé au +$phoneNumber. Veuillez le saisir ci-dessous.',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            verticalSpaceLarge,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) => _OtpDigitInput()),
            ),
            verticalSpaceLarge,
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: viewModel.verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00ACC1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Vérifier', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            verticalSpaceMedium,
            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text('Renvoyer le code', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  OtpViewModel viewModelBuilder(BuildContext context) => OtpViewModel();
}

class _OtpDigitInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 65,
      child: TextField(
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
