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
  final List<String> imagesGallery;
  final String type;
  final bool isVerified;

  FactoryModel({
    required this.name,
    required this.location,
    required this.region,
    required this.category,
    required this.description,
    required this.heroUrl,
    required this.imagesGallery,
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
        name: "Nestlé Ghana Limited",
        location: "Tema Industrial Zone",
        region: "Greater Accra",
        category: "Agro-Alimentaire & Boissons",
        description: "Leader dans la fabrication et la transformation de produits alimentaires et de boissons populaires de grande consommation (Milo, Milk, Nescafé, Maggi) à travers l'Afrique de l'Ouest.",
        heroUrl: "https://images.unsplash.com/photo-1596461404969-9ae70f2830c1?w=800&q=80",
        imagesGallery: [
          "https://images.unsplash.com/photo-1596461404969-9ae70f2830c1?w=800&q=80",
          "https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?w=800&q=80",
          "https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=800&q=80"
        ],
        type: "ALIMENTATION",
      ),
      FactoryModel(
        name: "Cocoa Processing Company (CPC)",
        location: "Tema Port Road Area",
        region: "Greater Accra",
        category: "Chocolaterie & Transformation de Cacao",
        description: "Usine nationale d'excellence pour la transformation et la fabrication de chocolats (sous la marque Golden Tree) et de dérivés de fèves de cacao premium ghanéennes.",
        heroUrl: "https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=800&q=80",
        imagesGallery: [
          "https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=800&q=80",
          "https://images.unsplash.com/photo-1606312440539-748e521364e5?w=800&q=80",
          "https://images.unsplash.com/photo-1511381939415-e44015466834?w=800&q=80"
        ],
        type: "CACAO & CHOCOLAT",
      ),
      FactoryModel(
        name: "Ernest Chemists Limited",
        location: "Tema Industrial Area",
        region: "Greater Accra",
        category: "Industrie Pharmaceutique & Soins",
        description: "La plus grande usine de fabrication de produits pharmaceutiques d'Afrique de l'Ouest, certifiée par l'OMS, produisant des capsules, sirops et médicaments essentiels.",
        heroUrl: "https://images.unsplash.com/photo-1584017911766-d451b3d0e843?w=800&q=80",
        imagesGallery: [
          "https://images.unsplash.com/photo-1584017911766-d451b3d0e843?w=800&q=80",
          "https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=800&q=80",
          "https://images.unsplash.com/photo-1581093588401-f3c22d75ba05?w=800&q=80"
        ],
        type: "PHARMACEUTIQUE",
      ),
      FactoryModel(
        name: "Aluworks Limited",
        location: "Tema Port Area",
        region: "Greater Accra",
        category: "Transformation d'Aluminium & Métallurgie",
        description: "Fabricant industriel majeur produisant des tôles d'aluminium, des bobines et des rouleaux destinés à la construction, la fabrication et l'export dans toute la sous-région.",
        heroUrl: "https://images.unsplash.com/photo-1504917595217-d4dc5ebe6122?w=800&q=80",
        imagesGallery: [
          "https://images.unsplash.com/photo-1504917595217-d4dc5ebe6122?w=800&q=80",
          "https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=800&q=80",
          "https://images.unsplash.com/photo-1563717789093-ba77651c6c6a?w=800&q=80"
        ],
        type: "METALLURGIE",
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
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 25),
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
            "i-Hub : Usines & Fabricants",
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            "Découvrez les leaders industriels réels du Ghana et visitez virtuellement leurs lignes de production en 3D.",
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, height: 1.4),
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
                        "USINE REELLE",
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
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: kcPrimaryColor),
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
                  style: const TextStyle(color: kcTabIndicatorColor, fontSize: 11, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  factory.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 16),
                // Call to Action
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _openVirtualTour(context, factory),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: kcPrimaryColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          "VISITE 3D",
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: kcPrimaryColor, letterSpacing: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _openFactoryDetails(context, factory),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kcPrimaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: const Text(
                          "DÉTAILS USINE",
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                        ),
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

  // Affiche un simulateur de Visite Virtuelle 3D
  void _openVirtualTour(BuildContext context, FactoryModel factory) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 380,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A), // Style cinématique sombre
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "VISITE VIRTUELLE 3D",
                      style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.0),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: factory.heroUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        // Overlay 3D simulateur
                        Container(
                          color: Colors.black.withOpacity(0.6),
                        ),
                        const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.threed_rotation, size: 70, color: Colors.cyanAccent),
                              SizedBox(height: 12),
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(Colors.cyanAccent),
                                strokeWidth: 2,
                              ),
                              SizedBox(height: 12),
                              Text(
                                "Chargement du Rendu 3D Interactive...",
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "Ligne de Production : ${factory.name}",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 5),
                Text(
                  "Pivotez à 360° pour inspecter les machines et capacités.",
                  style: TextStyle(color: Colors.grey[400], fontSize: 11),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Affiche les détails complets de l'usine avec carrousel d'images multiples
  void _openFactoryDetails(BuildContext context, FactoryModel factory) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    factory.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kcPrimaryColor),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "${factory.location}, ${factory.region}",
                        style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Carrousel horizontal pour associer et afficher plusieurs images
                  const Text(
                    "GALERIE PHOTOS & ÉQUIPEMENTS",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: kcTabIndicatorColor, letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: factory.imagesGallery.length,
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CachedNetworkImage(
                              imageUrl: factory.imagesGallery[i],
                              width: 220,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: Colors.grey[100]),
                              errorWidget: (context, url, err) => Container(color: Colors.grey[200]),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 25),
                  const Text(
                    "À PROPOS DE L'USINE",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: kcTabIndicatorColor, letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    factory.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.5),
                  ),

                  const SizedBox(height: 25),
                  const Text(
                    "DÉTAILS INDUSTRIELS",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: kcTabIndicatorColor, letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 10),
                  _buildDetailTile(Icons.category, "Secteur d'activité", factory.category),
                  _buildDetailTile(Icons.check_circle, "Statut de vérification", "Vérifié & Audité par PROMOGO"),
                  _buildDetailTile(Icons.precision_manufacturing, "Type d'installation", "Ligne de production ${factory.type}"),
                  _buildDetailTile(Icons.vpn_key_rounded, "Sourcing direct", "Contrat cadre direct usine sans intermédiaires"),
                  
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kcPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("FERMER", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: kcPrimaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: kcPrimaryColor)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
