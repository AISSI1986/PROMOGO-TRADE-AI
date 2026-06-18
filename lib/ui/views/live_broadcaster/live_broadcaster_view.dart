import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:stacked/stacked.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/common/api_constants.dart';
import 'live_broadcaster_viewmodel.dart';

class LiveBroadcasterView extends StackedView<LiveBroadcasterViewModel> {
  final String liveId;
  final List<Map<String, dynamic>> initialProducts;

  const LiveBroadcasterView({
    Key? key,
    required this.liveId,
    required this.initialProducts,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    LiveBroadcasterViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: kcPrimaryColorDark,
      resizeToAvoidBottomInset: false, // Empêche l'interface de se compresser
      body: Stack(
        children: [
          // 1. APERÇU CAMÉRA RÉEL
          if (viewModel.isStreamingInitialized)
            Positioned.fill(
              child: SizedBox.expand(
                child: viewModel.buildVideoView(isBroadcaster: true),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(color: kcSecondaryGold),
              ),
            ),

          // 2. FILTRE DE LISIBILITÉ
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),

          // 3. INTERFACE PRINCIPALE
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Column(
                children: [
                  _buildSuraAssistantBanner(),
                  const SizedBox(height: 15),
                  _buildTopStatsBar(viewModel),
                  const Spacer(),
                  if (viewModel.showLiveIndicator) _buildLivePulsingIndicator(),
                  const Spacer(),
                  _buildPremiumActionButton(context, viewModel),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // 3.5 ZONE DES PRODUITS ÉPINGLÉS (MULTI-ÉPINGLAGE)
          if (viewModel.pinnedProducts.isNotEmpty)
            Positioned(
              left: viewModel.pinnedPosition.dx,
              top: viewModel.pinnedPosition.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  viewModel.updatePinnedPosition(details.delta);
                },
                child: SizedBox(
                  width: 200, // Largeur max pour 2 colonnes par exemple
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(viewModel.pinnedProducts.length, (index) {
                      return _buildPinnedSquare(viewModel, index);
                    }),
                  ),
                ),
              ),
            ),

          // 3.6 SIDEBAR DE CONTRÔLES (À DROITE)
          Positioned(
            right: 15,
            bottom: 120,
            child: Column(
              children: [
                _buildSidebarButton(
                  icon: viewModel.isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                  label: "MICRO",
                  color: viewModel.isMuted ? Colors.red : kcSecondaryGold,
                  onTap: viewModel.toggleMute,
                ),
                const SizedBox(height: 20),
                _buildSidebarButton(
                  icon: Icons.grid_view_rounded,
                  label: "CATALOGUE",
                  color: kcSecondaryGold,
                  onTap: () => _showCatalogSheet(context, viewModel),
                ),
                const SizedBox(height: 20),
                _buildSidebarButton(
                  icon: Icons.list_alt_rounded,
                  label: "COMMANDES",
                  color: kcSecondaryGold,
                  onTap: () => _showOrdersSheet(context, viewModel),
                  badgeCount: viewModel.incomingOrders.length,
                ),
                const SizedBox(height: 20),
                _buildSidebarButton(
                  icon: Icons.flip_camera_ios_rounded,
                  label: "CAMÉRA",
                  color: kcSecondaryGold,
                  onTap: viewModel.switchCamera,
                ),
              ],
            ),
          ),

          // 3.7 ZONE DE SAISIE CHAT (BAS GAUCHE)
          _buildChatInput(context, viewModel),

          // FLOATING HEARTS
          ...viewModel.floatingHearts.map((heart) => _buildHeartAnimation(heart)),

          // 3.8 CHAT OVERLAY (AU DESSUS DU INPUT)
          Positioned(
            left: 20,
            bottom: (MediaQuery.of(context).viewInsets.bottom > 0) 
              ? MediaQuery.of(context).viewInsets.bottom + 65 
              : MediaQuery.of(context).padding.bottom + 140, // Adaptation dynamique au SafeArea
            child: SizedBox(
              height: 220,
              width: MediaQuery.of(context).size.width * 0.65,
              child: ListView.builder(
                reverse: true,
                itemCount: viewModel.chatMessages.length,
                itemBuilder: (context, index) {
                  final chat = viewModel.chatMessages[index];
                  return _buildChatBubble(chat);
                },
              ),
            ),
          ),

          // 4. BOUTON FERMER ÉLÉGANT
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: () async {
                if (viewModel.isLive) {
                  await viewModel.endLiveSession();
                  if (context.mounted) _showEndLiveStatsModal(context, viewModel);
                } else {
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white10),
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.5), width: 1),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              if (badgeCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text(
                      badgeCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSuraAssistantBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: kcSecondaryGold.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Image.asset('assets/images/logo_app.png', width: 24),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("ASSISTANT SURA IA", style: TextStyle(color: kcSecondaryGold, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
                    SizedBox(height: 2),
                    Text("Souriez ! Vos clients adorent voir votre visage.", style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopStatsBar(LiveBroadcasterViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildGlassStat(
          icon: Icons.timer_rounded,
          value: viewModel.formattedDuration,
          label: "DURÉE",
          isAlert: viewModel.isLive,
          color: kcSecondaryGold,
        ),
        const SizedBox(width: 15),
        _buildGlassStat(
          icon: Icons.remove_red_eye_rounded,
          value: "${viewModel.viewerCount}",
          label: "DIRECT",
          color: kcSecondaryGold,
        ),
        const SizedBox(width: 15),
        _buildGlassStat(
          icon: Icons.favorite_rounded,
          value: "${viewModel.likesCount}",
          label: "J'AIME",
          color: Colors.redAccent,
        ),
      ],
    );
  }

  Widget _buildGlassStat({required IconData icon, required String value, required String label, Color color = Colors.white, bool isAlert = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isAlert ? Colors.redAccent.withOpacity(0.5) : Colors.white10),
        ),
        child: Column(
          children: [
            Icon(icon, color: isAlert ? Colors.redAccent : color, size: 14),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isAlert) 
                  Container(
                    margin: const EdgeInsets.only(right: 4),
                    width: 6, height: 6,
                    decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                  ),
                Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
              ],
            ),
            Text(label, style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.w600, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildLivePulsingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.4), blurRadius: 15, spreadRadius: 2)],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sensors_rounded, color: Colors.white, size: 14),
          SizedBox(width: 8),
          Text("VOUS ÊTES EN DIRECT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
        ],
      ),
    );
  }



  void _showProductSelector(BuildContext context, LiveBroadcasterViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 450,
        decoration: const BoxDecoration(
          color: kcPrimaryColorDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("VOTRE CATALOGUE", style: TextStyle(color: kcSecondaryGold, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5)),
                  TextButton.icon(
                    onPressed: () {
                      viewModel.pinAllProducts();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.grid_view_rounded, color: Colors.white, size: 14),
                    label: const Text("TOUT ÉPINGLER", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: viewModel.sellerProducts.length,
                itemBuilder: (context, index) {
                  final product = viewModel.sellerProducts[index];
                  final isPinned = viewModel.pinnedProducts.any((p) => p['id'] == product['id']);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isPinned ? kcSecondaryGold : Colors.white10),
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildProductImage(product),
                      ),
                      title: Text((product['name'] as String?) ?? 'Produit sans nom', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text(
                         product['price'] != null 
                             ? (product['price'].toString().contains('GHS') 
                                 ? product['price'].toString() 
                                 : '${product['price']} GHS') 
                             : 'Prix non défini', 
                         style: const TextStyle(color: kcSecondaryGold, fontSize: 12),
                       ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_note_rounded, color: Colors.white70, size: 20),
                            onPressed: () {
                              // On réutilise la même logique de modification que dans le pré-live
                              _showEditProductSheet(context, viewModel, index);
                            },
                          ),
                          isPinned 
                            ? const Icon(Icons.push_pin_rounded, color: kcSecondaryGold, size: 20)
                            : TextButton.icon(
                                onPressed: () {
                                  viewModel.pinProduct(product);
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.push_pin_outlined, color: Colors.white, size: 14),
                                label: const Text("ÉPINGLER", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrdersPanel(BuildContext context, LiveBroadcasterViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 500,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("COMMANDES EN ATTENTE (CASH ON DELIVERY)", style: TextStyle(color: kcPrimaryColor, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5)),
            ),
            Expanded(
              child: viewModel.incomingOrders.isEmpty
                ? const Center(child: Text("Aucune commande pour le moment.", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: viewModel.incomingOrders.length,
                    itemBuilder: (context, index) {
                      final order = viewModel.incomingOrders[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: kcSecondaryGold.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text((order['buyer'] as String?) ?? '', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: kcPrimaryColor)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(5)),
                                  child: const Text("À LIVRER", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            _buildOrderInfo(Icons.shopping_bag, "PRODUIT: ${order['product']}"),
                            _buildOrderInfo(Icons.phone, "TEL: ${order['phone']}"),
                            _buildOrderInfo(Icons.location_on, "LIEU: ${order['location']}"),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {},
                                    style: OutlinedButton.styleFrom(side: const BorderSide(color: kcPrimaryColor)),
                                    child: const Text("VOIR PRIVÉ", style: TextStyle(color: kcPrimaryColor, fontSize: 11)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(backgroundColor: kcPrimaryColor),
                                    child: const Text("CONFIRMER LIVE", style: TextStyle(color: Colors.white, fontSize: 11)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfo(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: Colors.grey[800], fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildControlIcon({required IconData icon, required String label, required VoidCallback onTap, bool isActive = false, Color color = Colors.white, int? badgeCount}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isActive ? Colors.redAccent : Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: isActive ? Colors.redAccent : Colors.white10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              if (badgeCount != null && badgeCount > 0)
                Positioned(
                  right: -5,
                  top: -5,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text("$badgeCount", style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildPremiumActionButton(BuildContext context, LiveBroadcasterViewModel viewModel) {
    return GestureDetector(
      onTap: () async {
        if (viewModel.isLive) {
          await viewModel.endLiveSession();
          if (context.mounted) _showEndLiveStatsModal(context, viewModel);
        } else {
          viewModel.toggleLive();
        }
      },
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: viewModel.isLive 
            ? null 
            : const LinearGradient(colors: [kcPrimaryColor, Color(0xFF1E3A8A)]),
          color: viewModel.isLive ? Colors.transparent : null,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: viewModel.isLive ? Colors.redAccent : kcSecondaryGold, width: 1.5),
          boxShadow: [
            if (!viewModel.isLive) BoxShadow(color: kcPrimaryColor.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          viewModel.isLive ? "METTRE FIN AU DIRECT" : "LANCER LE LIVE MAINTENANT",
          style: TextStyle(
            color: viewModel.isLive ? Colors.redAccent : Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 13,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildPinnedSquare(LiveBroadcasterViewModel viewModel, int index) {
    final product = viewModel.pinnedProducts[index];
    return Container(
      width: 85,
      height: 85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: kcSecondaryGold.withOpacity(0.8), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black45, blurRadius: 8, spreadRadius: 1),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          children: [
            // IMAGE DE FOND
            Positioned.fill(child: _buildProductImage(product, size: 85)),
            
            // DÉGRADÉ POUR LE TEXTE
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),

            // TEXTE (NOM ET PRIX)
            Positioned(
              bottom: 6,
              left: 6,
              right: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    (product['name'] as String?) ?? 'Produit sans nom',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    product['price'] != null 
                        ? (product['price'].toString().contains('GHS') 
                            ? product['price'].toString() 
                            : '${product['price']} GHS') 
                        : '0 GHS',
                    style: const TextStyle(color: kcSecondaryGold, fontSize: 8, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),

            // BOUTON FERMER
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => viewModel.unpinProduct(index),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: Colors.white, size: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> chat) {
    final bool isSystem = chat['isSystem'] == true;
    final bool isMe = chat['isMe'] == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSystem 
                      ? kcSecondaryGold.withOpacity(0.2) 
                      : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isSystem ? kcSecondaryGold.withOpacity(0.4) : Colors.white10,
                    ),
                  ),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${chat['user']}: ",
                          style: TextStyle(
                            color: isSystem ? kcSecondaryGold : (isMe ? Colors.blueAccent : kcSecondaryGold),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        TextSpan(
                          text: chat['message'] as String?,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInput(BuildContext context, LiveBroadcasterViewModel viewModel) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    // Adaptation dynamique au SafeArea de l'écran pour ne jamais toucher le bouton Lancer le live
    final double bottomOffset = keyboardHeight > 0 
      ? keyboardHeight + 10 
      : MediaQuery.of(context).padding.bottom + 85;

    return Positioned(
      bottom: bottomOffset, 
      left: 20,
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 100, 
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: viewModel.chatController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  maxLength: 120,
                  decoration: const InputDecoration(
                    hintText: "Ajoutez un commentaire...",
                    hintStyle: TextStyle(color: Colors.white54, fontSize: 13),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                    counterText: "",
                  ),
                  onSubmitted: (_) => viewModel.sendMessage(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send_rounded, color: kcSecondaryGold, size: 18),
                onPressed: viewModel.sendMessage,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCatalogSheet(BuildContext context, LiveBroadcasterViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Mon Catalogue", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: viewModel.sellerProducts.length,
                itemBuilder: (context, index) {
                  final product = viewModel.sellerProducts[index];
                  final isPinned = viewModel.pinnedProducts.any((p) => p['id'] == product['id']);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
                    child: Row(
                      children: [
                        ClipRRect(borderRadius: BorderRadius.circular(10), child: _buildProductImage(product, size: 50)),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text((product['name'] as String?) ?? 'Produit sans nom', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              Text(
                                product['price'] != null 
                                    ? (product['price'].toString().contains('GHS') 
                                        ? product['price'].toString() 
                                        : '${product['price']} GHS') 
                                    : '0 GHS', 
                                style: const TextStyle(color: kcSecondaryGold, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_note_rounded, color: Colors.white70),
                          onPressed: () => _showEditProductSheet(context, viewModel, index),
                        ),
                        const SizedBox(width: 5),
                        ElevatedButton(
                          onPressed: () => viewModel.pinProduct(product),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isPinned ? kcSecondaryGold : Colors.white10,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Icon(
                            isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                            size: 16,
                            color: isPinned ? Colors.black : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrdersSheet(BuildContext context, LiveBroadcasterViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("Commandes du Direct", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: viewModel.incomingOrders.isEmpty
                ? const Center(child: Text("Aucune commande pour le moment", style: TextStyle(color: Colors.white54)))
                : ListView.builder(
                    itemCount: viewModel.incomingOrders.length,
                    itemBuilder: (context, index) {
                      final order = viewModel.incomingOrders[index];
                      return ListTile(
                        leading: const CircleAvatar(backgroundColor: kcSecondaryGold, child: Icon(Icons.shopping_bag, color: Colors.black)),
                        title: Text((order['buyer'] as String?) ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text("${order['product']} - ${order['location']}", style: const TextStyle(color: Colors.white70)),
                        trailing: const Icon(Icons.check_circle, color: Colors.green),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProductSheet(BuildContext context, LiveBroadcasterViewModel viewModel, int index) {
    final product = viewModel.sellerProducts[index];
    final nameController = TextEditingController(text: product['name'] as String?);
    final priceController = TextEditingController(text: product['price'].toString().replaceAll(" GHS", ""));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Modifier l'article",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Nom du produit",
                labelStyle: const TextStyle(color: kcSecondaryGold),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Prix (GHS)",
                labelStyle: const TextStyle(color: kcSecondaryGold),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Appel de la méthode complète (Backend + WebSocket)
                  viewModel.updateProduct(index, nameController.text, priceController.text);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: kcSecondaryGold),
                child: const Text("Enregistrer", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(Map<String, dynamic> product, {double size = 40}) {
    
    // 1. CAS PRODUIT FLASH (PHOTO LOCALE)
    if (product['isFlash'] == true && product['imagePath'] != null) {
      return Image.file(
        File(product['imagePath'] as String),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(size),
      );
    }

    // 2. CAS PRODUIT CATALOGUE (ASSET OU RÉSEAU)
    final String? image = product['image'] as String?;
    if (image == null) return _buildPlaceholder(size);

    if (image.startsWith('http')) {
      return Image.network(
        image,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(size),
      );
    } else if (image.startsWith('/media')) {
      // Cas des images venant du serveur Django (liens relatifs)
      return Image.network(
        "${ApiConstants.djangoRootUrl}$image",
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(size),
      );
    } else {
      return Image.asset(
        image,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(size),
      );
    }
  }

  Widget _buildPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      color: Colors.white10,
      child: const Icon(Icons.shopping_bag_outlined, color: Colors.white24, size: 20),
    );
  }

  @override
  void onViewModelReady(LiveBroadcasterViewModel viewModel) {
    viewModel.initBroadcaster(liveId, initialProducts);
    super.onViewModelReady(viewModel);
  }

  @override
  LiveBroadcasterViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      LiveBroadcasterViewModel();

  void _showEndLiveStatsModal(BuildContext context, LiveBroadcasterViewModel viewModel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF151923),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, color: kcSecondaryGold, size: 60),
                const SizedBox(height: 16),
                const Text("Live Terminé", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(Icons.timer, "Durée", viewModel.formattedDuration),
                    _buildStatItem(Icons.remove_red_eye, "Vues", "${viewModel.viewerCount}"),
                    _buildStatItem(Icons.favorite, "J'aime", "${viewModel.likesCount}"),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kcPrimaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Close Live screen
                  },
                  child: const Text("QUITTER LE LIVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: kcSecondaryGold, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _buildHeartAnimation(Map<String, dynamic> heart) {
    final double xOffset = heart['xOffset'] as double;
    final int colorIndex = heart['colorIndex'] as int;
    final Color heartColor = Colors.primaries[colorIndex];

    return Positioned(
      bottom: 100,
      right: 30,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(seconds: 2),
        builder: (context, value, child) {
          return Opacity(
            opacity: 1.0 - value,
            child: Transform.translate(
              offset: Offset(xOffset * math.sin(value * math.pi * 3), -value * 400),
              child: Icon(Icons.favorite, color: heartColor, size: 36),
            ),
          );
        },
      ),
    );
  }
}
