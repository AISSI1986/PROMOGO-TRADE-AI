// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter/material.dart' as _i21;
import 'package:flutter/material.dart';
import 'package:promogoai/models/product.dart' as _i22;
import 'package:promogoai/ui/views/cart/cart_view.dart' as _i19;
import 'package:promogoai/ui/views/home/home_view.dart' as _i2;
import 'package:promogoai/ui/views/language/language_view.dart' as _i12;
import 'package:promogoai/ui/views/login/login_view.dart' as _i8;
import 'package:promogoai/ui/views/mode_ia/mode_ia_view.dart' as _i4;
import 'package:promogoai/ui/views/moi/moi_view.dart' as _i5;
import 'package:promogoai/ui/views/my_publications/my_publications_view.dart'
    as _i18;
import 'package:promogoai/ui/views/onboarding/onboarding_view.dart' as _i7;
import 'package:promogoai/ui/views/otp/otp_view.dart' as _i10;
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
import 'package:stacked_services/stacked_services.dart' as _i23;

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
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.HomeView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i2.HomeView(),
        settings: data,
      );
    },
    _i3.StartupView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i3.StartupView(),
        settings: data,
      );
    },
    _i4.ModeIaView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i4.ModeIaView(),
        settings: data,
      );
    },
    _i5.MoiView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i5.MoiView(),
        settings: data,
      );
    },
    _i6.ReglagesView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i6.ReglagesView(),
        settings: data,
      );
    },
    _i7.OnboardingView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i7.OnboardingView(),
        settings: data,
      );
    },
    _i8.LoginView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i8.LoginView(),
        settings: data,
      );
    },
    _i9.RegisterView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i9.RegisterView(),
        settings: data,
      );
    },
    _i10.OtpView: (data) {
      final args = data.getArgs<OtpViewArguments>(nullOk: false);
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i10.OtpView(key: args.key, phoneNumber: args.phoneNumber),
        settings: data,
      );
    },
    _i11.VendreView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i11.VendreView(),
        settings: data,
      );
    },
    _i12.LanguageView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i12.LanguageView(),
        settings: data,
      );
    },
    _i13.ProductDetailView: (data) {
      final args = data.getArgs<ProductDetailViewArguments>(nullOk: false);
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i13.ProductDetailView(key: args.key, product: args.product),
        settings: data,
      );
    },
    _i14.SupportView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i14.SupportView(),
        settings: data,
      );
    },
    _i15.SellerDashboardView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i15.SellerDashboardView(),
        settings: data,
      );
    },
    _i16.SellerKycView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i16.SellerKycView(),
        settings: data,
      );
    },
    _i17.SavedView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i17.SavedView(),
        settings: data,
      );
    },
    _i18.MyPublicationsView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i18.MyPublicationsView(),
        settings: data,
      );
    },
    _i19.CartView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i19.CartView(),
        settings: data,
      );
    },
    _i20.PromogoFairView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i20.PromogoFairView(),
        settings: data,
      );
    },
  };

  @override
  List<_i1.RouteDef> get routes => _routes;

  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class OtpViewArguments {
  const OtpViewArguments({
    this.key,
    required this.phoneNumber,
  });

  final _i21.Key? key;

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

class ProductDetailViewArguments {
  const ProductDetailViewArguments({
    this.key,
    required this.product,
  });

  final _i21.Key? key;

  final _i22.Product product;

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

extension NavigatorStateExtension on _i23.NavigationService {
  Future<dynamic> navigateToHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.homeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToStartupView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.startupView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToModeIaView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.modeIaView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToMoiView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.moiView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToReglagesView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.reglagesView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToOnboardingView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.onboardingView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToLoginView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.loginView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToRegisterView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.registerView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToOtpView({
    _i21.Key? key,
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

  Future<dynamic> navigateToVendreView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.vendreView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToLanguageView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.languageView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToProductDetailView({
    _i21.Key? key,
    required _i22.Product product,
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

  Future<dynamic> navigateToSupportView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.supportView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToSellerDashboardView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.sellerDashboardView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToSellerKycView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.sellerKycView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToSavedView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.savedView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToMyPublicationsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.myPublicationsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToCartView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.cartView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToPromogoFairView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.promogoFairView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.homeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithStartupView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.startupView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithModeIaView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.modeIaView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithMoiView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.moiView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithReglagesView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.reglagesView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithOnboardingView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.onboardingView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithLoginView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.loginView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithRegisterView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.registerView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithOtpView({
    _i21.Key? key,
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

  Future<dynamic> replaceWithVendreView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.vendreView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithLanguageView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.languageView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithProductDetailView({
    _i21.Key? key,
    required _i22.Product product,
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

  Future<dynamic> replaceWithSupportView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.supportView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithSellerDashboardView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.sellerDashboardView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithSellerKycView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.sellerKycView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithSavedView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.savedView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithMyPublicationsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.myPublicationsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithCartView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.cartView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithPromogoFairView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.promogoFairView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }
}
