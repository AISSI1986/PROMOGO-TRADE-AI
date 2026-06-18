import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:stacked/stacked.dart';
import 'package:video_player/video_player.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'live_viewer_viewmodel.dart';

class LiveViewerView extends StackedView<LiveViewerViewModel> {
  final LiveViewerViewModel? preloadedViewModel;

  const LiveViewerView({Key? key, this.preloadedViewModel}) : super(key: key);

  @override
  LiveViewerViewModel viewModelBuilder(BuildContext context) =>
      preloadedViewModel ?? LiveViewerViewModel();

  @override
  bool get disposeViewModel => preloadedViewModel == null;

  @override
  void onViewModelReady(LiveViewerViewModel viewModel) {
    if (preloadedViewModel == null) {
      viewModel.initViewer();
    } else {
      // Si c'est pré-chargé, on ne fait rien de particulier ici
    }
  }

  @override
  void onDispose(LiveViewerViewModel viewModel) {
    super.onDispose(viewModel);
  }

  @override
  Widget builder(
    BuildContext context,
    LiveViewerViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: PageView.builder(
        controller: viewModel.pageController,
        scrollDirection: Axis.vertical,
        itemCount: viewModel.videoUrls.length,
        onPageChanged: viewModel.onPageChanged,
        itemBuilder: (context, index) {
          final broadcasterName = viewModel.getBroadcasterName(index);
          return GestureDetector(
            onDoubleTap: viewModel.addLike,
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Stack(
              children: [
                // 1. VIDEO LAYER
                Positioned.fill(
                  child: Stack(
                          fit: StackFit.expand,
                          children: [
                            index == viewModel.currentVideoIndex
                                ? (index < viewModel.sessions.length 
                                    ? viewModel.streamingService.buildVideoView(
                                        channelId: viewModel.sessions[index]['id'].toString(),
                                        remoteUid: viewModel.streamingService.currentRemoteUid,
                                        isBroadcaster: false,
                                      )
                                    : (viewModel.videoController != null && viewModel.videoController!.value.isInitialized 
                                        ? SizedBox.expand(
                                            child: FittedBox(
                                              fit: BoxFit.cover,
                                              child: SizedBox(
                                                width: viewModel.videoController!.value.size.width,
                                                height: viewModel.videoController!.value.size.height,
                                                child: VideoPlayer(viewModel.videoController!),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            color: Colors.black,
                                            decoration: const BoxDecoration(
                                              image: DecorationImage(
                                                image: AssetImage('assets/images/placeholder_live.png'),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            child: Container(
                                              color: Colors.black54,
                                              child: const Center(
                                                child: CircularProgressIndicator(color: kcSecondaryGold),
                                              ),
                                            ),
                                          )
                                      )
                                  )
                                : Container(
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage('assets/images/placeholder_live.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Container(
                                      color: Colors.black54,
                                      child: const Center(
                                        child: CircularProgressIndicator(color: kcSecondaryGold),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                ),

                // 2. GRADIENT OVERLAY
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),

                // 3. UI OVERLAY
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context, viewModel, broadcasterName),
                        const Spacer(),
                        _buildBottomSection(context, viewModel),
                      ],
                    ),
                  ),
                ),

                // 4. FLOATING HEARTS
                ...viewModel.floatingHearts
                    .map((heart) => _buildHeartAnimation(heart)),

                // 5. CLOSE BUTTON
                Positioned(
                  top: 50,
                  right: 20,
                  child: IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),


              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, LiveViewerViewModel viewModel, String username) {
    final initials = viewModel.getBroadcasterInitials(viewModel.currentVideoIndex);
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: kcSecondaryGold.withOpacity(0.2),
          child: Text(initials, style: const TextStyle(color: kcSecondaryGold, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(username,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: kcSecondaryGold,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text("SUIVRE",
                      style: TextStyle(
                          color: kcPrimaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 8)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => _showShoppingBag(context, viewModel),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kcSecondaryGold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shopping_bag_rounded,
                        color: kcPrimaryColor, size: 12),
                    SizedBox(width: 4),
                    Text(
                      "VOIR LES PRODUITS",
                      style: TextStyle(
                          color: kcPrimaryColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 9,
                          letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomSection(
      BuildContext context, LiveViewerViewModel viewModel) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset > 0 ? bottomInset - 16 : 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. CHAT MESSAGES (Scrollable)
          SizedBox(
            height: bottomInset > 0 ? 120 : 180,
            child: ShaderMask(
              shaderCallback: (Rect rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black,
                    Colors.black,
                    Colors.transparent
                  ],
                  stops: [0.0, 0.1, 0.9, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: viewModel.chatMessages.length,
                itemBuilder: (context, index) {
                  final chat = viewModel.chatMessages[index];
                  return _buildChatItem(chat);
                },
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 3. INPUT AREA (RE-DESIGNED)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.emoji_emotions_outlined,
                            color: viewModel.showEmojiPicker
                                ? kcSecondaryGold
                                : Colors.white70,
                            size: 22),
                        onPressed: viewModel.toggleEmojiPicker,
                      ),
                      Expanded(
                        child: TextField(
                          controller: viewModel.chatController,
                          focusNode: viewModel.chatFocusNode,
                          maxLines: 4,
                          minLines: 1,
                          maxLength: 120,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          onTap: () {
                            if (viewModel.showEmojiPicker ||
                                viewModel.showStickerPicker) {
                              viewModel.toggleEmojiPicker();
                            }
                          },
                          decoration: const InputDecoration(
                            hintText: "Envoyer un message...",
                            hintStyle:
                                TextStyle(color: Colors.white38, fontSize: 14),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.sticky_note_2_outlined,
                            color: viewModel.showStickerPicker
                                ? kcSecondaryGold
                                : Colors.white70,
                            size: 20),
                        onPressed: viewModel.toggleStickerPicker,
                      ),
                      if (viewModel.chatController.text.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 6, bottom: 6),
                          child: GestureDetector(
                            onTap: viewModel.sendMessage,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                  color: kcSecondaryGold,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.send_rounded,
                                  color: kcPrimaryColor, size: 18),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (bottomInset == 0) ...[
                const SizedBox(width: 12),
                _buildActionIcon(Icons.favorite_rounded, Colors.red,
                    onTap: viewModel.addLike),
                const SizedBox(width: 8),
                _buildActionIcon(Icons.share_rounded, Colors.white),
              ],
            ],
          ),

          // 4. PICKERS (Emoji / Sticker)
          if (viewModel.showEmojiPicker) ...[
            const SizedBox(height: 10),
            _buildInlineEmojiPicker(viewModel),
          ],
          if (viewModel.showStickerPicker) ...[
            const SizedBox(height: 10),
            _buildInlineStickerPicker(viewModel),
          ],

          const SizedBox(height: 15),

          // 5. CONTACT BUTTON
          if (bottomInset == 0) _buildContactButton(viewModel),
        ],
      ),
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

  Widget _buildCurrentProductMini(BuildContext context,
      Map<String, dynamic> product, LiveViewerViewModel viewModel) {
    return GestureDetector(
      onTap: () => _showQuickBuyForm(context, product, viewModel),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(30),
          border:
              Border.all(color: kcSecondaryGold.withOpacity(0.8), width: 1.5),
          boxShadow: [
            BoxShadow(color: kcSecondaryGold.withOpacity(0.2), blurRadius: 10)
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(product['image'],
                  width: 28, height: 28, fit: BoxFit.cover),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(product['name'],
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
                Text(product['price'],
                    style: const TextStyle(
                        color: kcSecondaryGold,
                        fontSize: 10,
                        fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: kcSecondaryGold, size: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildChatItem(Map<String, String> chat) {
    final isMe = chat['user'] == "Moi";
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${chat['user']}: ",
              style: TextStyle(
                  color: isMe ? Colors.white : kcSecondaryGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          Expanded(
              child: Text(chat['message'] ?? "",
                  style: const TextStyle(color: Colors.white, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  Widget _buildContactButton(LiveViewerViewModel viewModel) {
    return GestureDetector(
      onTap: () {
        // Envoie un message automatique dans le chat du live concernant le produit épinglé s'il y en a un
        final product = viewModel.pinnedProduct ?? (viewModel.currentLiveProducts.isNotEmpty ? viewModel.currentLiveProducts[0] : null);
        if (product != null) {
          viewModel.chatController.text = "Je suis intéressé(e) par ${product['name']} !";
          viewModel.chatFocusNode.requestFocus();
        } else {
          viewModel.chatController.text = "Bonjour, je souhaite vous contacter.";
          viewModel.chatFocusNode.requestFocus();
        }
      },
      child: Container(
      width: double.infinity,
      height: 45,
      decoration: BoxDecoration(
        color: const Color(0xFF03112E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kcSecondaryGold, width: 1),
      ),
      child: const Center(
        child: Text(
          "CONTACTER LE VENDEUR",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 1),
        ),
      ),
      ),
    );
  }

  void _showShoppingBag(BuildContext context, LiveViewerViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Boutique du Live",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Outfit')),
                    IconButton(
                        icon: const Icon(Icons.close, color: Colors.black),
                        onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: viewModel.currentLiveProducts.length,
                  itemBuilder: (context, index) {
                    final product = viewModel.currentLiveProducts[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(product['image'],
                                  width: 60, height: 60, fit: BoxFit.cover)),
                          const SizedBox(width: 15),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(product['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                Text(product['price'],
                                    style: const TextStyle(
                                        color: kcPrimaryColor,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16)),
                              ])),
                          ElevatedButton(
                            onPressed: () =>
                                _showQuickBuyForm(context, product, viewModel),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kcPrimaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text("ACHETER",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQuickBuyForm(BuildContext context, Map<String, dynamic> product,
      LiveViewerViewModel viewModel) {
    final nameController = TextEditingController(text: "Utilisateur PromoGo");
    final phoneController = TextEditingController();
    final locationController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String? errorMessage;
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom +
                    MediaQuery.of(context).padding.bottom +
                    20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 20),
                    const Text("CONFIRMATION DE LA COMMANDE",
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            letterSpacing: 1,
                            color: kcPrimaryColor)),
                    const SizedBox(height: 25),

                    // Recap produit
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey[200]!)),
                      child: Row(
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(product['image'],
                                  width: 50, height: 50, fit: BoxFit.cover)),
                          const SizedBox(width: 15),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(product['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                Text(product['price'],
                                    style: const TextStyle(
                                        color: kcPrimaryColor,
                                        fontWeight: FontWeight.w900)),
                              ])),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    _buildFieldLabel("VOTRE NOM SUR L'APP"),
                    _buildSimpleTextField(nameController, "Nom complet"),
                    const SizedBox(height: 15),
                    _buildFieldLabel("NUMÉRO DE TÉLÉPHONE (Pour le livreur)"),
                    _buildSimpleTextField(phoneController, "Ex: +225 ...",
                        isPhone: true),
                    const SizedBox(height: 15),
                    _buildFieldLabel("LIEU DE LIVRAISON / POINT DE REPÈRE"),
                    _buildSimpleTextField(locationController,
                        "Ex: À côté de la mosquée, Quartier X"),

                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(errorMessage!,
                            style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),

                    const SizedBox(height: 35),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          if (phoneController.text.isEmpty ||
                              locationController.text.isEmpty) {
                            setState(() {
                              errorMessage =
                                  "Veuillez remplir le numéro et le lieu de livraison.";
                            });
                            return;
                          }

                          viewModel.confirmOrder(
                            product: product,
                            buyerName: nameController.text,
                            phone: phoneController.text,
                            location: locationController.text,
                          );

                          Navigator.of(context).pop();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 4),
                              content: Text(
                                  "COMMANDE ENVOYEE. Le vendeur va confirmer votre achat en direct."),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: kcPrimaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15))),
                        child: const Text("ENVOYER VOTRE COMMANDE",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label,
          style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Colors.grey,
              letterSpacing: 1)),
    );
  }

  Widget _buildSimpleTextField(TextEditingController controller, String hint,
      {bool isPhone = false}) {
    return TextField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildInlineEmojiPicker(LiveViewerViewModel viewModel) {
    final emojis = [
      "😀",
      "😂",
      "😍",
      "🙌",
      "🔥",
      "💯",
      "👏",
      "❤️",
      "🌹",
      "🎁",
      "✨",
      "🚀",
      "💎",
      "👑",
      "👗",
      "👠"
    ];
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6, mainAxisSpacing: 10, crossAxisSpacing: 10),
        itemCount: emojis.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => viewModel.addSpecificEmoji(emojis[index]),
          child: Center(
              child: Text(emojis[index], style: const TextStyle(fontSize: 22))),
        ),
      ),
    );
  }

  Widget _buildInlineStickerPicker(LiveViewerViewModel viewModel) {
    final stickers = [
      {"icon": "🎁", "label": "Cadeau"},
      {"icon": "💎", "label": "Diamant"},
      {"icon": "👑", "label": "Couronne"},
      {"icon": "🌹", "label": "Rose"},
      {"icon": "🔥", "label": "Feu"},
      {"icon": "👗", "label": "Robe"},
    ];
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5),
        itemCount: stickers.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => viewModel.sendSpecificSticker(
              stickers[index]['icon']!, stickers[index]['label']!),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(stickers[index]['icon']!,
                    style: const TextStyle(fontSize: 22)),
                Text(stickers[index]['label']!,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 8,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
