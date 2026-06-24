class SubscriptionPlan {
  final int id;
  final String nom;
  final double prix;
  final String devise;
  final int dureeJours;
  final int poidsRanking;
  final bool estEpingle;
  final int frequenceRemontee;
  final List<String> emplacementPub;
  
  // Permissions
  final bool accesChatInterne;
  final bool masquerCoordonnees;
  final bool boutonWhatsApp;
  final bool boutonAppelDirect;
  final bool afficherNumeroEnClair;
  final bool accesVenteLive;
  final bool publicationVocaleIA;
  final bool badgeVerifie;
  final bool accesStatsAvancees;
  final bool prioriteComparateur;
  final bool accesPromogoFair;
  final bool accesDemandeCotation;
  final int maxAds;

  SubscriptionPlan({
    required this.id,
    required this.nom,
    required this.prix,
    required this.devise,
    required this.dureeJours,
    required this.poidsRanking,
    required this.estEpingle,
    required this.frequenceRemontee,
    required this.emplacementPub,
    required this.accesChatInterne,
    required this.masquerCoordonnees,
    required this.boutonWhatsApp,
    required this.boutonAppelDirect,
    required this.afficherNumeroEnClair,
    required this.accesVenteLive,
    required this.publicationVocaleIA,
    required this.badgeVerifie,
    required this.accesStatsAvancees,
    required this.prioriteComparateur,
    required this.accesPromogoFair,
    required this.accesDemandeCotation,
    required this.maxAds,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nom: (json['nom'] as String?) ?? '',
      prix: double.tryParse(json['prix']?.toString() ?? '0.0') ?? 0.0,
      devise: (json['devise'] as String?) ?? 'GHS',
      dureeJours: (json['dureeJours'] as num?)?.toInt() ?? 30,
      poidsRanking: (json['poidsRanking'] as num?)?.toInt() ?? 10,
      estEpingle: (json['estEpingle'] as bool?) ?? false,
      frequenceRemontee: (json['frequenceRemontee'] as num?)?.toInt() ?? 0,
      emplacementPub: List<String>.from((json['emplacementPub'] as List?) ?? []),
      accesChatInterne: (json['accesChatInterne'] as bool?) ?? false,
      masquerCoordonnees: (json['masquerCoordonnees'] as bool?) ?? false,
      boutonWhatsApp: (json['boutonWhatsApp'] as bool?) ?? false,
      boutonAppelDirect: (json['boutonAppelDirect'] as bool?) ?? false,
      afficherNumeroEnClair: (json['afficherNumeroEnClair'] as bool?) ?? false,
      accesVenteLive: (json['accesVenteLive'] as bool?) ?? false,
      publicationVocaleIA: (json['publicationVocaleIA'] as bool?) ?? false,
      badgeVerifie: (json['badgeVerifie'] as bool?) ?? false,
      accesStatsAvancees: (json['accesStatsAvancees'] as bool?) ?? false,
      prioriteComparateur: (json['prioriteComparateur'] as bool?) ?? false,
      accesPromogoFair: (json['accesPromogoFair'] as bool?) ?? false,
      accesDemandeCotation: (json['accesDemandeCotation'] as bool?) ?? false,
      maxAds: (json['max_ads'] as num?)?.toInt() ?? 1,
    );
  }
}
