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
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      prix: double.tryParse(json['prix']?.toString() ?? '0.0') ?? 0.0,
      devise: json['devise'] ?? 'GHS',
      dureeJours: json['dureeJours'] ?? 30,
      poidsRanking: json['poidsRanking'] ?? 10,
      estEpingle: json['estEpingle'] ?? false,
      frequenceRemontee: json['frequenceRemontee'] ?? 0,
      emplacementPub: List<String>.from(json['emplacementPub'] ?? []),
      accesChatInterne: json['accesChatInterne'] ?? false,
      masquerCoordonnees: json['masquerCoordonnees'] ?? false,
      boutonWhatsApp: json['boutonWhatsApp'] ?? false,
      boutonAppelDirect: json['boutonAppelDirect'] ?? false,
      afficherNumeroEnClair: json['afficherNumeroEnClair'] ?? false,
      accesVenteLive: json['accesVenteLive'] ?? false,
      publicationVocaleIA: json['publicationVocaleIA'] ?? false,
      badgeVerifie: json['badgeVerifie'] ?? false,
      accesStatsAvancees: json['accesStatsAvancees'] ?? false,
      prioriteComparateur: json['prioriteComparateur'] ?? false,
      accesPromogoFair: json['accesPromogoFair'] ?? false,
      accesDemandeCotation: json['accesDemandeCotation'] ?? false,
    );
  }
}
