import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';

class ReglagesViewModel extends BaseViewModel {
  void changeLanguage(BuildContext context, String langCode) {
    context.setLocale(Locale(langCode));
    notifyListeners();
  }
}
