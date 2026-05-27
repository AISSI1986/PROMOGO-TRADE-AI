import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/models/subscription_plan.dart';
import 'abonnement_viewmodel.dart';

class AbonnementView extends StackedView<AbonnementViewModel> {
  const AbonnementView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, AbonnementViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark Navy
      appBar: AppBar(
        title: const Text('Plans d\'Abonnement', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: viewModel.isFetching
          ? const Center(child: CircularProgressIndicator(color: kcPrimaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Propulsez votre visibilité",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: viewModel.plans.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final plan = viewModel.plans[index];
                      return _SubscriptionCard(plan: plan, viewModel: viewModel);
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  @override
  void onViewModelReady(AbonnementViewModel viewModel) => viewModel.init();

  @override
  AbonnementViewModel viewModelBuilder(BuildContext context) => AbonnementViewModel();
}

class _SubscriptionCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final AbonnementViewModel viewModel;

  const _SubscriptionCard({required this.plan, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    // Definir la couleur en fonction du plan
    Color primaryColor;
    if (plan.nom == 'BASIC') primaryColor = Colors.grey;
    else if (plan.nom == 'BOOST') primaryColor = Colors.blueAccent;
    else if (plan.nom == 'PREMIUM') primaryColor = Colors.orangeAccent;
    else if (plan.nom == 'VIP') primaryColor = Colors.purpleAccent;
    else primaryColor = const Color(0xFFFFD700); // GOLD for DIAMOND

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor.withOpacity(0.2), Colors.white.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      plan.nom,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
                    ),
                  ),
                  Text(
                    viewModel.formatPrice(plan.prix, context),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _FeatureRow(icon: Icons.check_circle, text: "Priorité : Niveau ${plan.poidsRanking / 10}"),
              if (plan.frequenceRemontee > 0)
                _FeatureRow(icon: Icons.auto_mode, text: "Remontée automatique toutes les ${plan.frequenceRemontee}h"),
              if (plan.boutonWhatsApp)
              _FeatureRow(icon: Icons.chat, text: "Bouton WhatsApp activé"),
              if (plan.accesVenteLive)
                _FeatureRow(icon: Icons.live_tv, text: "Accès aux Ventes Live"),
              if (plan.publicationVocaleIA)
                _FeatureRow(icon: Icons.mic, text: "Publication vocale par IA"),
              if (plan.accesPromogoFair)
                _FeatureRow(icon: Icons.stars, text: "Accès à PROMOGO FAIR", isSpecial: true),
              if (plan.accesDemandeCotation)
                _FeatureRow(icon: Icons.request_quote, text: "Demandes de Cotations", isSpecial: true),
              
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("Choisir ce plan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isSpecial;

  const _FeatureRow({required this.icon, required this.text, this.isSpecial = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isSpecial ? Colors.orangeAccent : Colors.white70),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isSpecial ? Colors.orangeAccent : Colors.white70,
                fontSize: 13,
                fontWeight: isSpecial ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
