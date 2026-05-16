// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as _i31;
import 'package:promogoai/models/course_model.dart' as _i33;
import 'package:promogoai/models/product.dart' as _i32;
import 'package:promogoai/ui/views/abonnement/abonnement_view.dart' as _i24;
import 'package:promogoai/ui/views/cart/cart_view.dart' as _i19;
import 'package:promogoai/ui/views/course_detail/course_detail_view.dart'
    as _i26;
import 'package:promogoai/ui/views/demande_devis/demande_devis_view.dart'
    as _i22;
import 'package:promogoai/ui/views/demande_devis/form_devis_view.dart' as _i23;
import 'package:promogoai/ui/views/home/home_view.dart' as _i2;
import 'package:promogoai/ui/views/language/language_view.dart' as _i12;
import 'package:promogoai/ui/views/lesson/lesson_view.dart' as _i27;
import 'package:promogoai/ui/views/live_broadcaster/live_broadcaster_view.dart'
    as _i29;
import 'package:promogoai/ui/views/live_viewer/live_viewer_view.dart' as _i28;
import 'package:promogoai/ui/views/login/login_view.dart' as _i8;
import 'package:promogoai/ui/views/mode_ia/mode_ia_view.dart' as _i4;
import 'package:promogoai/ui/views/moi/moi_view.dart' as _i5;
import 'package:promogoai/ui/views/mon_academie/mon_academie_view.dart' as _i21;
import 'package:promogoai/ui/views/my_publications/my_publications_view.dart'
    as _i18;
import 'package:promogoai/ui/views/onboarding/onboarding_view.dart' as _i7;
import 'package:promogoai/ui/views/otp/otp_view.dart' as _i10;
import 'package:promogoai/ui/views/pre_live_setup/pre_live_setup_view.dart'
    as _i30;
import 'package:promogoai/ui/views/price_comparator/price_comparator_view.dart'
    as _i25;
import 'package:promogoai/ui/views/product_detail/product_detail_view.dart'
    as _i13;
import 'package:promogoai/ui/views/promogo_fair/promogo_fair_view.dart' as _i20;
import 'package:promogoai/ui/views/register/register_view.dart' as _i9;
import 'package:promogoai/ui/views/reglages/reglages_view.dart' as _i6;
import 'package:promogoai/ui/views/saved/saved_view.dart' as _i17;
import 'package:promogoai/ui/views/seller_dashboard/seller_dashboard_view.dart'
    as _i15;
import 'package:promogoai/ui/views/seller_kyc/seller_kyc_view.dart' as _i16;
import 'package:promogoai/ui/views/startup/startup_view.dart' as _i3;
import 'package:promogoai/ui/views/support/support_view.dart' as _i14;
import 'package:promogoai/ui/views/vendre/vendre_view.dart' as _i11;
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i34;

class Routes {
  static const homeView = '/home-view';

  static const startupView = '/startup-view';

  static const modeIaView = '/mode-ia-view';

  static const moiView = '/moi-view';

  static const reglagesView = '/reglages-view';

  static const onboardingView = '/onboarding-view';

  static const loginView = '/login-view';

  static const registerView = '/register-view';

  static const otpView = '/otp-view';

  static const vendreView = '/vendre-view';

  static const languageView = '/language-view';

  static const productDetailView = '/product-detail-view';

  static const supportView = '/support-view';

  static const sellerDashboardView = '/seller-dashboard-view';

  static const sellerKycView = '/seller-kyc-view';

  static const savedView = '/saved-view';

  static const myPublicationsView = '/my-publications-view';

  static const cartView = '/cart-view';

  static const promogoFairView = '/promogo-fair-view';

  static const monAcademieView = '/mon-academie-view';

  static const demandeDevisView = '/demande-devis-view';

  static const formDevisView = '/form-devis-view';

  static const abonnementView = '/abonnement-view';

  static const priceComparatorView = '/price-comparator-view';

  static const courseDetailView = '/course-detail-view';

  static const lessonView = '/lesson-view';

  static const liveViewerView = '/live-viewer-view';

  static const liveBroadcasterView = '/live-broadcaster-view';

  static const preLiveSetupView = '/pre-live-setup-view';

  static const all = <String>{
    homeView,
    startupView,
    modeIaView,
    moiView,
    reglagesView,
    onboardingView,
    loginView,
    registerView,
    otpView,
    vendreView,
    languageView,
    productDetailView,
    supportView,
    sellerDashboardView,
    sellerKycView,
    savedView,
    myPublicationsView,
    cartView,
    promogoFairView,
    monAcademieView,
    demandeDevisView,
    formDevisView,
    abonnementView,
    priceComparatorView,
    courseDetailView,
    lessonView,
    liveViewerView,
    liveBroadcasterView,
    preLiveSetupView,
  };
}

class StackedRouter extends _i1.RouterBase {
  final _routes = <_i1.RouteDef>[
    _i1.RouteDef(
      Routes.homeView,
      page: _i2.HomeView,
    ),
    _i1.RouteDef(
      Routes.startupView,
      page: _i3.StartupView,
    ),
    _i1.RouteDef(
      Routes.modeIaView,
      page: _i4.ModeIaView,
    ),
    _i1.RouteDef(
      Routes.moiView,
      page: _i5.MoiView,
    ),
    _i1.RouteDef(
      Routes.reglagesView,
      page: _i6.ReglagesView,
    ),
    _i1.RouteDef(
      Routes.onboardingView,
      page: _i7.OnboardingView,
    ),
    _i1.RouteDef(
      Routes.loginView,
      page: _i8.LoginView,
    ),
    _i1.RouteDef(
      Routes.registerView,
      page: _i9.RegisterView,
    ),
    _i1.RouteDef(
      Routes.otpView,
      page: _i10.OtpView,
    ),
    _i1.RouteDef(
      Routes.vendreView,
      page: _i11.VendreView,
    ),
    _i1.RouteDef(
      Routes.languageView,
      page: _i12.LanguageView,
    ),
    _i1.RouteDef(
      Routes.productDetailView,
      page: _i13.ProductDetailView,
    ),
    _i1.RouteDef(
      Routes.supportView,
      page: _i14.SupportView,
    ),
    _i1.RouteDef(
      Routes.sellerDashboardView,
      page: _i15.SellerDashboardView,
    ),
    _i1.RouteDef(
      Routes.sellerKycView,
      page: _i16.SellerKycView,
    ),
    _i1.RouteDef(
      Routes.savedView,
      page: _i17.SavedView,
    ),
    _i1.RouteDef(
      Routes.myPublicationsView,
      page: _i18.MyPublicationsView,
    ),
    _i1.RouteDef(
      Routes.cartView,
      page: _i19.CartView,
    ),
    _i1.RouteDef(
      Routes.promogoFairView,
      page: _i20.PromogoFairView,
    ),
    _i1.RouteDef(
      Routes.monAcademieView,
      page: _i21.MonAcademieView,
    ),
    _i1.RouteDef(
      Routes.demandeDevisView,
      page: _i22.DemandeDevisView,
    ),
    _i1.RouteDef(
      Routes.formDevisView,
      page: _i23.FormDevisView,
    ),
    _i1.RouteDef(
      Routes.abonnementView,
      page: _i24.AbonnementView,
    ),
    _i1.RouteDef(
      Routes.priceComparatorView,
      page: _i25.PriceComparatorView,
    ),
    _i1.RouteDef(
      Routes.courseDetailView,
      page: _i26.CourseDetailView,
    ),
    _i1.RouteDef(
      Routes.lessonView,
      page: _i27.LessonView,
    ),
    _i1.RouteDef(
      Routes.liveViewerView,
      page: _i28.LiveViewerView,
    ),
    _i1.RouteDef(
      Routes.liveBroadcasterView,
      page: _i29.LiveBroadcasterView,
    ),
    _i1.RouteDef(
      Routes.preLiveSetupView,
      page: _i30.PreLiveSetupView,
    ),
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.HomeView: (data) {
      final args = data.getArgs<HomeViewArguments>(
        orElse: () => const HomeViewArguments(),
      );
      return _i31.MaterialPageRoute<dynamic>(
        builder: (context) => _i2.HomeView(key: args.key),
        settings: data,
      );
    },
    _i3.StartupView: (data) {
      final args = data.getArgs<StartupViewArguments>(
        orElse: () => const StartupViewArguments(),
      );
      return _i31.MaterialPageRoute<dynamic>(
        builder: (context) => _i3.StartupView(key: args.key),
        settings: data,
      );
    },
    _i4.ModeIaView: (data) {
      final args = data.getArgs<ModeIaViewArguments>(
        orElse: () => const ModeIaViewArguments(),
      );
      return _i31.MaterialPageRoute<dynamic>(
        builder: (context) => _i4.ModeIaView(key: args.key),
        settings: data,
      );
    },
    _i5.MoiView: (data) {
      final args = data.getArgs<MoiViewArguments>(
        orElse: () => const MoiViewArguments(),
      );
      return _i31.MaterialPageRoute<dynamic>(
        builder: (context) => _i5.MoiView(key: args.key, onBack: args.onBack),
        settings: data,
      );
    },
    _i6.ReglagesView: (data) {
      final args = data.getArgs<ReglagesViewArguments>(
        orElse: () => const ReglagesViewArguments(),
      );
      return _i31.MaterialPageRoute<dynamic>(
        builder: (context) => _i6.ReglagesView(key: args.key),
        settings: data,
      );
    },
    _i7.OnboardingView: (data) {
      final args = data.getArgs<OnboardingViewArguments>(
        orElse: () => const OnboardingViewArguments(),
      );
      return _i31.MaterialPageRoute<dynamic>(
        builder: (context) => _i7.OnboardingView(key: args.key),
        settings: data,
      );
    },
    _i8.LoginView: (data) {
      final args = data.getArgs<LoginViewArguments>(
        orElse: () => const LoginViewArguments(),
      );
      return _i31.MaterialPageRoute<dynamic>(
        builder: (context) => _i8.LoginView(key: args.key),
        settings: data,
      );
    },
    _i9.RegisterView: (data) {
      final args = data.getArgs<RegisterViewArguments>(
        orElse: () => const RegisterViewArguments(),
      );
      return _i31.MaterialPageRoute<dynamic>(
        builder: (context) => _i9.RegisterView(key: args.key),
        settings: data,
      );
    },
    _i10.OtpView: (data) {
      final args = data.getArgs<OtpViewArguments>(nullOk: false);
      return _i31.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i10.OtpView(key: args.key, phoneNumber: args.phoneNumber),
        settings: data,
      );
    },
    _i11.VendreView: (data) {
      final args = data.getArgs<VendreViewArguments>(
        orElse: () => const VendreViewArguments(),
      );
      return _i31.MaterialPageRoute<dynamic>(
        builder: (context) => _i11.VendreView(key: args.key),
        settings: data,
      );
    },
    _i12.LanguageView: (data) {
      final args = data.getArgs<LanguageViewArguments>(
        orElse: () => const LanguageViewArguments(),
      );
      return _i31.MaterialPageRoute<dynamic>(
        builder: (context) => _i12.LanguageView(key: args.key),
        settings: data,
      );
    },
    _i13.ProductDetailView: (data) {
      final args = data.getArgs<ProductDetailViewArguments>(nullOk: false);
      return _i31.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i13.ProductDetailView(key: args.key, product: args.product),
        settings: data,
      );
    },
    _i14.SupportView: (data) {
      final args = data.getArgs<SupportViewArguments>(
        orElse: () => const SupportViewArguments(),
      );
      return _i31.MaterialPageRoute<dynamic>(
        builder: (context) => _i14.SupportView(key: args.key),
        settings: data,
      );
    },
    _i15.SellerDashboardView: (data) {
      final args = data.getArgs<SellerDashboardViewArguments>(
        orElse: () => const SellerDashboardViewArguments(),
      );
      return _i31.MaterialPageRoute<dynamic>(
        builder: (context) => _i15.SellerDashboardView(key: args.key),
        settings: data,
      );
    },
    _i16.SellerKycView: (data) {
      final args = data.getArgs<SellerKycViewArguments>(
        orElse: () => const SellerKycViewArguments(),
      );
      return _i31.MaterialPageRoute<dynamic>(
        builder: (context) => _i16.SellerKycView(key: args.key),
        settings: data,
      );
    },
    _i17.SavedView: (data) {
      final args = data.getArgs<SavedViewArguments>(
        orElse: () => const SavedViewArguments(),
      );
      return _i31.MaterialPageRoute<dynamic>(
        builder: (context) => _i17.SavedView(key: args.key),
        settings: data,
      );
    },
    _i18.MyPublicationsView: (data) {
      final args = data.getArgs<MyPublicationsViewArguments>(
        orElse: () => const MyPublicationsViewArguments(),
      );
      return _i31.MaterialPageRoute<dynamic>(
        builder: (context) => _i18.MyPublicationsView(key: args.key),
        settings: data,
      );
    },
    _i19.CartView: (data) {
      final args = data.getArgs<CartViewArguments>(
        orElse: () => const CartViewArguments(),
      );
      return _i31.MaterialPageRoute<dynamic>(
        builder: (context) => _i19.CartView(key: args.key),
        settings: data,
      );
    },
    _i20.PromogoFairView: (data) {
      final args = data.getArgs<PromogoFairViewArguments>(
        orElse: () => const PromogoFairViewArguments(),
      );
      return _i31.MaterialPageRoute<dynamic>(
        builder: (context) => _i20.PromogoFairView(key: args.key),
        settings: data,
      );
    },
    _i21.MonAcademieView: (data) {
      final args = data.getArgs<MonAcademieViewArguments>(
        orElse: () => const MonAcademieViewArguments(),
      );
      return _i31.MaterialPageRoute<dynamic>(
        builder: (context) => _i21.MonAcademieView(key: args.key),
        settings: data,
      );
    },
    _i22.DemandeDevisView: (data) {
      final args = data.getArgs<DemandeDevisViewArguments>(
        orElse: () => const DemandeDevisViewArguments(),
      );
      return _i31.MaterialPageRoute<dynamic>(
        builder: (context) => _i22.DemandeDevisView(key: args.key),
        settings: data,
      );
    },
    _i23.FormDevisView: (data) {
      final args = data.getArgs<FormDevisViewArguments>(
        orElse: () => const FormDevisViewArguments(),
      );
      return _i31.MaterialPageRoute<dynamic>(
        builder: (context) => _i23.FormDevisView(key: args.key),
        settings: data,
      );
    },
    _i24.AbonnementView: (data) {
      final args = data.getArgs<AbonnementViewArguments>(
        orElse: () => const AbonnementViewArguments(),
      );
      return _i31.MaterialPageRoute<dynamic>(
        builder: (context) => _i24.AbonnementView(key: args.key),
        settings: data,
      );
    },
    _i25.PriceComparatorView: (data) {
      final args = data.getArgs<PriceComparatorViewArguments>(
        orElse: () => const PriceComparatorViewArguments(),
      );
      return _i31.MaterialPageRoute<dynamic>(
        builder: (context) => _i25.PriceComparatorView(key: args.key),
        settings: data,
      );
    },
    _i26.CourseDetailView: (data) {
      final args = data.getArgs<CourseDetailViewArguments>(nullOk: false);
      return _i31.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i26.CourseDetailView(key: args.key, courseId: args.courseId),
        settings: data,
      );
    },
    _i27.LessonView: (data) {
      final args = data.getArgs<LessonViewArguments>(nullOk: false);
      return _i31.MaterialPageRoute<dynamic>(
        builder: (context) => _i27.LessonView(
            key: args.key,
            lesson: args.lesson,
            allLessons: args.allLessons,
            moduleTitle: args.moduleTitle,
            courseId: args.courseId),
        settings: data,
      );
    },
    _i28.LiveViewerView: (data) {
      final args = data.getArgs<LiveViewerViewArguments>(
        orElse: () => const LiveViewerViewArguments(),
      );
      return _i31.MaterialPageRoute<dynamic>(
        builder: (context) => _i28.LiveViewerView(key: args.key),
        settings: data,
      );
    },
    _i29.LiveBroadcasterView: (data) {
      final args = data.getArgs<LiveBroadcasterViewArguments>(nullOk: false);
      return _i31.MaterialPageRoute<dynamic>(
        builder: (context) => _i29.LiveBroadcasterView(
            key: args.key,
            liveId: args.liveId,
            initialProducts: args.initialProducts),
        settings: data,
      );
    },
    _i30.PreLiveSetupView: (data) {
      final args = data.getArgs<PreLiveSetupViewArguments>(
        orElse: () => const PreLiveSetupViewArguments(),
      );
      return _i31.MaterialPageRoute<dynamic>(
        builder: (context) => _i30.PreLiveSetupView(key: args.key),
        settings: data,
      );
    },
  };

  @override
  List<_i1.RouteDef> get routes => _routes;

  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class HomeViewArguments {
  const HomeViewArguments({this.key});

  final _i31.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant HomeViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class StartupViewArguments {
  const StartupViewArguments({this.key});

  final _i31.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant StartupViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class ModeIaViewArguments {
  const ModeIaViewArguments({this.key});

  final _i31.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant ModeIaViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class MoiViewArguments {
  const MoiViewArguments({
    this.key,
    this.onBack,
  });

  final _i31.Key? key;

  final void Function()? onBack;

  @override
  String toString() {
    return '{"key": "$key", "onBack": "$onBack"}';
  }

  @override
  bool operator ==(covariant MoiViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.onBack == onBack;
  }

  @override
  int get hashCode {
    return key.hashCode ^ onBack.hashCode;
  }
}

class ReglagesViewArguments {
  const ReglagesViewArguments({this.key});

  final _i31.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant ReglagesViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class OnboardingViewArguments {
  const OnboardingViewArguments({this.key});

  final _i31.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant OnboardingViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class LoginViewArguments {
  const LoginViewArguments({this.key});

  final _i31.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant LoginViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class RegisterViewArguments {
  const RegisterViewArguments({this.key});

  final _i31.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant RegisterViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class OtpViewArguments {
  const OtpViewArguments({
    this.key,
    required this.phoneNumber,
  });

  final _i31.Key? key;

  final String phoneNumber;

  @override
  String toString() {
    return '{"key": "$key", "phoneNumber": "$phoneNumber"}';
  }

  @override
  bool operator ==(covariant OtpViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode {
    return key.hashCode ^ phoneNumber.hashCode;
  }
}

class VendreViewArguments {
  const VendreViewArguments({this.key});

  final _i31.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant VendreViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class LanguageViewArguments {
  const LanguageViewArguments({this.key});

  final _i31.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant LanguageViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class ProductDetailViewArguments {
  const ProductDetailViewArguments({
    this.key,
    required this.product,
  });

  final _i31.Key? key;

  final _i32.Product product;

  @override
  String toString() {
    return '{"key": "$key", "product": "$product"}';
  }

  @override
  bool operator ==(covariant ProductDetailViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.product == product;
  }

  @override
  int get hashCode {
    return key.hashCode ^ product.hashCode;
  }
}

class SupportViewArguments {
  const SupportViewArguments({this.key});

  final _i31.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant SupportViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class SellerDashboardViewArguments {
  const SellerDashboardViewArguments({this.key});

  final _i31.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant SellerDashboardViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class SellerKycViewArguments {
  const SellerKycViewArguments({this.key});

  final _i31.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant SellerKycViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class SavedViewArguments {
  const SavedViewArguments({this.key});

  final _i31.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant SavedViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class MyPublicationsViewArguments {
  const MyPublicationsViewArguments({this.key});

  final _i31.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant MyPublicationsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class CartViewArguments {
  const CartViewArguments({this.key});

  final _i31.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant CartViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class PromogoFairViewArguments {
  const PromogoFairViewArguments({this.key});

  final _i31.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant PromogoFairViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class MonAcademieViewArguments {
  const MonAcademieViewArguments({this.key});

  final _i31.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant MonAcademieViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class DemandeDevisViewArguments {
  const DemandeDevisViewArguments({this.key});

  final _i31.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant DemandeDevisViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class FormDevisViewArguments {
  const FormDevisViewArguments({this.key});

  final _i31.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant FormDevisViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class AbonnementViewArguments {
  const AbonnementViewArguments({this.key});

  final _i31.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant AbonnementViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class PriceComparatorViewArguments {
  const PriceComparatorViewArguments({this.key});

  final _i31.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant PriceComparatorViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class CourseDetailViewArguments {
  const CourseDetailViewArguments({
    this.key,
    required this.courseId,
  });

  final _i31.Key? key;

  final String courseId;

  @override
  String toString() {
    return '{"key": "$key", "courseId": "$courseId"}';
  }

  @override
  bool operator ==(covariant CourseDetailViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.courseId == courseId;
  }

  @override
  int get hashCode {
    return key.hashCode ^ courseId.hashCode;
  }
}

class LessonViewArguments {
  const LessonViewArguments({
    this.key,
    required this.lesson,
    required this.allLessons,
    required this.moduleTitle,
    required this.courseId,
  });

  final _i31.Key? key;

  final _i33.Lesson lesson;

  final List<_i33.Lesson> allLessons;

  final String moduleTitle;

  final String courseId;

  @override
  String toString() {
    return '{"key": "$key", "lesson": "$lesson", "allLessons": "$allLessons", "moduleTitle": "$moduleTitle", "courseId": "$courseId"}';
  }

  @override
  bool operator ==(covariant LessonViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.lesson == lesson &&
        other.allLessons == allLessons &&
        other.moduleTitle == moduleTitle &&
        other.courseId == courseId;
  }

  @override
  int get hashCode {
    return key.hashCode ^
        lesson.hashCode ^
        allLessons.hashCode ^
        moduleTitle.hashCode ^
        courseId.hashCode;
  }
}

class LiveViewerViewArguments {
  const LiveViewerViewArguments({this.key});

  final _i31.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant LiveViewerViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class LiveBroadcasterViewArguments {
  const LiveBroadcasterViewArguments({
    this.key,
    required this.liveId,
    required this.initialProducts,
  });

  final _i31.Key? key;

  final String liveId;

  final List<Map<String, dynamic>> initialProducts;

  @override
  String toString() {
    return '{"key": "$key", "liveId": "$liveId", "initialProducts": "$initialProducts"}';
  }

  @override
  bool operator ==(covariant LiveBroadcasterViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.liveId == liveId &&
        other.initialProducts == initialProducts;
  }

  @override
  int get hashCode {
    return key.hashCode ^ liveId.hashCode ^ initialProducts.hashCode;
  }
}

class PreLiveSetupViewArguments {
  const PreLiveSetupViewArguments({this.key});

  final _i31.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant PreLiveSetupViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

extension NavigatorStateExtension on _i34.NavigationService {
  Future<dynamic> navigateToHomeView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.homeView,
        arguments: HomeViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToStartupView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.startupView,
        arguments: StartupViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToModeIaView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.modeIaView,
        arguments: ModeIaViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToMoiView({
    _i31.Key? key,
    void Function()? onBack,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.moiView,
        arguments: MoiViewArguments(key: key, onBack: onBack),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToReglagesView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.reglagesView,
        arguments: ReglagesViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToOnboardingView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.onboardingView,
        arguments: OnboardingViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToLoginView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.loginView,
        arguments: LoginViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToRegisterView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.registerView,
        arguments: RegisterViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToOtpView({
    _i31.Key? key,
    required String phoneNumber,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.otpView,
        arguments: OtpViewArguments(key: key, phoneNumber: phoneNumber),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToVendreView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.vendreView,
        arguments: VendreViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToLanguageView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.languageView,
        arguments: LanguageViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToProductDetailView({
    _i31.Key? key,
    required _i32.Product product,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.productDetailView,
        arguments: ProductDetailViewArguments(key: key, product: product),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToSupportView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.supportView,
        arguments: SupportViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToSellerDashboardView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.sellerDashboardView,
        arguments: SellerDashboardViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToSellerKycView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.sellerKycView,
        arguments: SellerKycViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToSavedView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.savedView,
        arguments: SavedViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToMyPublicationsView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.myPublicationsView,
        arguments: MyPublicationsViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToCartView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.cartView,
        arguments: CartViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToPromogoFairView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.promogoFairView,
        arguments: PromogoFairViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToMonAcademieView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.monAcademieView,
        arguments: MonAcademieViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToDemandeDevisView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.demandeDevisView,
        arguments: DemandeDevisViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToFormDevisView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.formDevisView,
        arguments: FormDevisViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAbonnementView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.abonnementView,
        arguments: AbonnementViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToPriceComparatorView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.priceComparatorView,
        arguments: PriceComparatorViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToCourseDetailView({
    _i31.Key? key,
    required String courseId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.courseDetailView,
        arguments: CourseDetailViewArguments(key: key, courseId: courseId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToLessonView({
    _i31.Key? key,
    required _i33.Lesson lesson,
    required List<_i33.Lesson> allLessons,
    required String moduleTitle,
    required String courseId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.lessonView,
        arguments: LessonViewArguments(
            key: key,
            lesson: lesson,
            allLessons: allLessons,
            moduleTitle: moduleTitle,
            courseId: courseId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToLiveViewerView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.liveViewerView,
        arguments: LiveViewerViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToLiveBroadcasterView({
    _i31.Key? key,
    required String liveId,
    required List<Map<String, dynamic>> initialProducts,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.liveBroadcasterView,
        arguments: LiveBroadcasterViewArguments(
            key: key, liveId: liveId, initialProducts: initialProducts),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToPreLiveSetupView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.preLiveSetupView,
        arguments: PreLiveSetupViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithHomeView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.homeView,
        arguments: HomeViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithStartupView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.startupView,
        arguments: StartupViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithModeIaView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.modeIaView,
        arguments: ModeIaViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithMoiView({
    _i31.Key? key,
    void Function()? onBack,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.moiView,
        arguments: MoiViewArguments(key: key, onBack: onBack),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithReglagesView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.reglagesView,
        arguments: ReglagesViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithOnboardingView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.onboardingView,
        arguments: OnboardingViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithLoginView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.loginView,
        arguments: LoginViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithRegisterView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.registerView,
        arguments: RegisterViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithOtpView({
    _i31.Key? key,
    required String phoneNumber,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.otpView,
        arguments: OtpViewArguments(key: key, phoneNumber: phoneNumber),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithVendreView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.vendreView,
        arguments: VendreViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithLanguageView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.languageView,
        arguments: LanguageViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithProductDetailView({
    _i31.Key? key,
    required _i32.Product product,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.productDetailView,
        arguments: ProductDetailViewArguments(key: key, product: product),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithSupportView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.supportView,
        arguments: SupportViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithSellerDashboardView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.sellerDashboardView,
        arguments: SellerDashboardViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithSellerKycView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.sellerKycView,
        arguments: SellerKycViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithSavedView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.savedView,
        arguments: SavedViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithMyPublicationsView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.myPublicationsView,
        arguments: MyPublicationsViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithCartView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.cartView,
        arguments: CartViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithPromogoFairView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.promogoFairView,
        arguments: PromogoFairViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithMonAcademieView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.monAcademieView,
        arguments: MonAcademieViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithDemandeDevisView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.demandeDevisView,
        arguments: DemandeDevisViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithFormDevisView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.formDevisView,
        arguments: FormDevisViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAbonnementView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.abonnementView,
        arguments: AbonnementViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithPriceComparatorView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.priceComparatorView,
        arguments: PriceComparatorViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithCourseDetailView({
    _i31.Key? key,
    required String courseId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.courseDetailView,
        arguments: CourseDetailViewArguments(key: key, courseId: courseId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithLessonView({
    _i31.Key? key,
    required _i33.Lesson lesson,
    required List<_i33.Lesson> allLessons,
    required String moduleTitle,
    required String courseId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.lessonView,
        arguments: LessonViewArguments(
            key: key,
            lesson: lesson,
            allLessons: allLessons,
            moduleTitle: moduleTitle,
            courseId: courseId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithLiveViewerView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.liveViewerView,
        arguments: LiveViewerViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithLiveBroadcasterView({
    _i31.Key? key,
    required String liveId,
    required List<Map<String, dynamic>> initialProducts,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.liveBroadcasterView,
        arguments: LiveBroadcasterViewArguments(
            key: key, liveId: liveId, initialProducts: initialProducts),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithPreLiveSetupView({
    _i31.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.preLiveSetupView,
        arguments: PreLiveSetupViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }
}
