import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:promogoai/app/app.bottomsheets.dart';
import 'package:promogoai/app/app.dialogs.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:promogoai/ui/common/setup_snackbar_ui.dart';
import 'package:media_kit/media_kit.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print("🔥 [Firebase] Initialisation réussie.");
  } catch (e) {
    print("⚠️ [Firebase] Erreur d'initialisation (google-services.json manquant ?) : $e");
  }

  MediaKit.ensureInitialized();
  await setupLocator();
  setupSnackbarUi();
  setupDialogUi();
  setupBottomSheetUi();
  
  await EasyLocalization.ensureInitialized();
  
  // Désactiver les bordures de debug si elles ont été activées par erreur
  debugPaintSizeEnabled = false;

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
        Locale('ar'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('fr'),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.startupView,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      navigatorObservers: [StackedService.routeObserver],
    );
  }
}
