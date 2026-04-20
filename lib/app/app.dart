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
import 'package:promogoai/ui/views/vendre/vendre_view.dart';
import 'package:promogoai/services/settings_service.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:promogoai/ui/views/language/language_view.dart';
import 'package:promogoai/ui/views/product_detail/product_detail_view.dart';
import 'package:promogoai/ui/views/support/support_view.dart';
import 'package:promogoai/ui/views/seller_dashboard/seller_dashboard_view.dart';
import 'package:promogoai/ui/views/seller_kyc/seller_kyc_view.dart';
import 'package:promogoai/ui/views/saved/saved_view.dart';
import 'package:promogoai/ui/views/my_publications/my_publications_view.dart';
import 'package:promogoai/ui/views/cart/cart_view.dart';
import 'package:promogoai/ui/views/promogo_fair/promogo_fair_view.dart';
import 'package:promogoai/ui/views/live_viewer/live_viewer_view.dart';
import 'package:promogoai/ui/views/live_broadcaster/live_broadcaster_view.dart';
import 'package:promogoai/services/srs_streaming_service.dart';
import 'package:promogoai/services/local_storage_service.dart';
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
    MaterialRoute(page: VendreView),
    MaterialRoute(page: LanguageView),
    MaterialRoute(page: ProductDetailView),
    MaterialRoute(page: SupportView),
    MaterialRoute(page: SellerDashboardView),
    MaterialRoute(page: SellerKycView),
    MaterialRoute(page: SavedView),
    MaterialRoute(page: MyPublicationsView),
    MaterialRoute(page: CartView),
    MaterialRoute(page: PromogoFairView),
    // @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: SettingsService),
    LazySingleton(classType: SrsStreamingService),
    InitializableSingleton(classType: LocalStorageService),
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
