import 'package:promogoai/models/subscription_plan.dart';

class UserSubscription {
  final int? id;
  final int? planId;
  final SubscriptionPlan? planDetails;
  final DateTime? dateDebut;
  final DateTime? dateExpiration;
  final String statutPaiement;
  final String gateway;
  final String? paystackReference;
  final int maxAds;
  final int activeAdsCount;
  final bool isActive;

  UserSubscription({
    this.id,
    this.planId,
    this.planDetails,
    this.dateDebut,
    this.dateExpiration,
    required this.statutPaiement,
    required this.gateway,
    this.paystackReference,
    required this.maxAds,
    required this.activeAdsCount,
    required this.isActive,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: (json['id'] as num?)?.toInt(),
      planId: (json['plan'] as num?)?.toInt(),
      planDetails: json['plan_details'] != null
          ? SubscriptionPlan.fromJson(json['plan_details'] as Map<String, dynamic>)
          : null,
      dateDebut: json['date_debut'] != null ? DateTime.tryParse(json['date_debut'].toString()) : null,
      dateExpiration: json['date_expiration'] != null ? DateTime.tryParse(json['date_expiration'].toString()) : null,
      statutPaiement: (json['statut_paiement'] as String?) ?? 'PENDING',
      gateway: (json['gateway'] as String?) ?? 'none',
      paystackReference: json['paystack_reference'] as String?,
      maxAds: (json['max_ads'] as num?)?.toInt() ?? 1,
      activeAdsCount: (json['active_ads_count'] as num?)?.toInt() ?? 0,
      isActive: (json['is_active'] as bool?) ?? false,
    );
  }
}
