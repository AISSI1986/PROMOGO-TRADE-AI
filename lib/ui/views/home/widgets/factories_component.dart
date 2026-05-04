import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';
import '../home_viewmodel.dart';

class FactoryModel {
  final String name;
  final String location;
  final String region;
  final String category;
  final String description;
  final String heroUrl;
  final String type;
  final bool isVerified;

  FactoryModel({
    required this.name,
    required this.location,
    required this.region,
    required this.category,
    required this.description,
    required this.heroUrl,
    this.type = "INDUSTRIAL",
    this.isVerified = true,
  });
}

class FactoriesComponent extends ViewModelWidget<HomeViewModel> {
  const FactoriesComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, HomeViewModel viewModel) {
    final List<FactoryModel> factories = [
      FactoryModel(
        name: "MinoHealth AI Labs",
        location: "East Legon, Accra",
        region: "Greater Accra",
        category: "Health-Tech & Deep Learning",
        description: "Utilisation du Deep Learning pour automatiser les diagnostics médicaux en radiologie et microscopie à travers l'Afrique.",
        heroUrl: "https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=800&q=80",
        type: "AI DIAGNOSTICS",
      ),
      FactoryModel(
        name: "Rungas GH Ltd",
        location: "Tema Industrial Zone",
        region: "Greater Accra",
        category: "Clean Energy Manufacturing",
        description: "Leader dans la fabrication de bouteilles de GPL composites de haute technologie pour l'Afrique de l'Ouest.",
        heroUrl: "https://images.unsplash.com/photo-1581094120527-133f15d9c248?w=800&q=80",
        type: "ENERGY",
      ),
      FactoryModel(
        name: "Kingdom Exim Group",
        location: "Tema",
        region: "Greater Accra",
        category: "Agro-Industrial Export",
        description: "Premier processeur et exportateur de produits agricoles (anacarde) avec des installations de classe mondiale.",
        heroUrl: "https://images.unsplash.com/photo-1595113316349-9fa4ee24f884?w=800&q=80",
        type: "AGRO-PROCESSING",
      ),
      FactoryModel(
        name: "Swoove Logistics",
        location: "Airport Residential",
        region: "Greater Accra",
        category: "Smart Logistics",
        description: "Optimisation de la chaîne d'approvisionnement et de la livraison via l'IA pour les entreprises ghanéennes.",
        heroUrl: "https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=800&q=80",
        type: "LOGISTICS",
      ),
    ];

    return Container(
      color: const Color(0xFFF1F5F9),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: factories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _buildHeader(context);
          return _buildFactoryCard(context, factories[index - 1]);
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
      decoration: const BoxDecoration(
        color: kcPrimaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user, color: Colors.cyanAccent, size: 14),
                SizedBox(width: 6),
                Text(
                  "Sourcing Vérifié PROMOGO",
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Hub Industriel & IA",
            style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            "Connectez-vous directement aux leaders technologiques et industriels du Ghana.",
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildFactoryCard(BuildContext context, FactoryModel factory) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Image Section
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: CachedNetworkImage(
                  imageUrl: factory.heroUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.business, color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified, color: Colors.blue, size: 14),
                      SizedBox(width: 4),
                      Text(
                        "VERIFIED",
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ),
              // Type Badge
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: kcPrimaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    factory.type,
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
          // Info Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        factory.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kcPrimaryColor),
                      ),
                    ),
                    const Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text("4.9", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.redAccent, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      "${factory.location}, ${factory.region}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  factory.category,
                  style: const TextStyle(color: kcTabIndicatorColor, fontSize: 12, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  factory.description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 16),
                // Call to Action
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: kcPrimaryColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("PROFIL", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kcPrimaryColor)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kcPrimaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: const Text("CONTACTER", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
