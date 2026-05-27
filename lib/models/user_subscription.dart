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
      id: json['id'],
      planId: json['plan'],
      planDetails: json['plan_details'] != null
          ? SubscriptionPlan.fromJson(json['plan_details'])
          : null,
      dateDebut: json['date_debut'] != null ? DateTime.tryParse(json['date_debut']) : null,
      dateExpiration: json['date_expiration'] != null ? DateTime.tryParse(json['date_expiration']) : null,
      statutPaiement: json['statut_paiement'] ?? 'PENDING',
      gateway: json['gateway'] ?? 'none',
      paystackReference: json['paystack_reference'],
      maxAds: json['max_ads'] ?? 1,
      activeAdsCount: json['active_ads_count'] ?? 0,
      isActive: json['is_active'] ?? false,
    );
  }
}
