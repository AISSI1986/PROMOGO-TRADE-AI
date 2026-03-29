import 'package:promogoai/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:promogoai/ui/views/login/login_view.dart';
import 'package:promogoai/ui/views/register/register_view.dart';
import 'package:promogoai/ui/views/otp/otp_view.dart';
import 'package:promogoai/ui/bottom_sheets/otp/otp_sheet.dart';
import 'package:promogoai/ui/bottom_sheets/settings/settings_sheet.dart';
import 'package:promogoai/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:promogoai/ui/views/home/home_view.dart';
import 'package:promogoai/ui/views/startup/startup_view.dart';
import 'package:promogoai/ui/views/mode_ia/mode_ia_view.dart';
import 'package:promogoai/ui/views/moi/moi_view.dart';
import 'package:promogoai/ui/views/reglages/reglages_view.dart';
import 'package:promogoai/ui/views/onboarding/onboarding_view.dart';
import 'package:promogoai/ui/views/panier/panier_view.dart';
import 'package:promogoai/services/settings_service.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView),
    MaterialRoute(page: StartupView),
    MaterialRoute(page: ModeIaView),
    MaterialRoute(page: MoiView),
    MaterialRoute(page: ReglagesView),
    MaterialRoute(page: OnboardingView),
    MaterialRoute(page: LoginView),
    MaterialRoute(page: RegisterView),
    MaterialRoute(page: OtpView),
    MaterialRoute(page: PanierView),
    // @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: SettingsService),
    // @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    StackedBottomsheet(classType: SettingsSheet),
    StackedBottomsheet(classType: OtpSheet),
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    // @stacked-dialog
  ],
)
class App {}
