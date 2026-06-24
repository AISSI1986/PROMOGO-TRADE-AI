import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';
import 'package:promogoai/ui/views/home/home_viewmodel.dart';
import 'mode_ia_viewmodel.dart';

class ModeIaView extends StackedView<ModeIaViewModel> {
  final HomeViewModel? homeViewModel;
  const ModeIaView({Key? key, this.homeViewModel}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ModeIaViewModel viewModel,
    Widget? child,
  ) {
    final double keyboardHeight = MediaQueryData.fromView(View.of(context)).viewInsets.bottom;
    final double bottomPadding = keyboardHeight > 0 ? 0.0 : getBottomNavHeight(context) - 25.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            kcPrimaryColor.withOpacity(0.08),
            kcPrimaryColor.withOpacity(0.15),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // 1. En-tête Langue (Haut)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                PopupMenuButton<String>(
                  initialValue: viewModel.selectedLanguage,
                  onSelected: (lang) {
                    viewModel.setLanguage(lang);
                    if (lang == 'fra') {
                      context.setLocale(const Locale('fr'));
                    } else if (lang == 'eng') {
                      context.setLocale(const Locale('en'));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: kcPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.language, size: 16, color: kcPrimaryColor),
                        horizontalSpaceTiny,
                        Text(
                          viewModel.selectedLanguage.toUpperCase(),
                          style: const TextStyle(
                            color: kcPrimaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'fra', child: Text('🇫🇷 Français')),
                    const PopupMenuItem(value: 'eng', child: Text('🇺🇸 English')),
                    const PopupMenuItem(value: 'hau', child: Text('🇳🇬 Haoussa')),
                    const PopupMenuItem(value: 'ewe', child: Text('🇬🇭 Ewe')),
                    const PopupMenuItem(value: 'mina', child: Text('🇹🇬 Mina')),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),

          // 2. Historique des messages (Milieu)
          Expanded(
            child: ListView.builder(
              controller: viewModel.chatScrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: viewModel.messages.length,
              itemBuilder: (context, index) {
                final message = viewModel.messages[index];
                final bool isSura = message['sender'] == 'sura';
                final String text = message['text'] ?? '';

                return Align(
                  alignment: isSura ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isSura ? Colors.white : kcPrimaryColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isSura ? Radius.zero : const Radius.circular(16),
                        bottomRight: isSura ? const Radius.circular(16) : Radius.zero,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: text.isEmpty && isSura
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(kcPrimaryColor),
                            ),
                          )
                        : MarkdownBody(
                            data: text,
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(
                                color: isSura ? kcDarkGreyColor : Colors.white,
                                fontSize: 14,
                                height: 1.3,
                              ),
                              strong: TextStyle(
                                color: isSura ? kcPrimaryColor : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              listBullet: TextStyle(
                                color: isSura ? kcPrimaryColor : Colors.white,
                              ),
                            ),
                          ),
                  ),
                );
              },
            ),
          ),

          // 3. Zone de suggestions et de saisie (Bas)
          Padding(
            padding: EdgeInsets.only(bottom: keyboardHeight > 0 ? 5 : 12, top: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Suggestions Chips (uniquement si le texte est vide et qu'on n'est pas en train d'écrire/focus)
                ValueListenableBuilder<bool>(
                  valueListenable: viewModel.isTextEmpty,
                  builder: (context, isEmpty, child) {
                    return ValueListenableBuilder<bool>(
                      valueListenable: viewModel.isFocused,
                      builder: (context, isFocused, child) {
                        if (isEmpty && !isFocused && keyboardHeight == 0) {
                          return Container(
                            height: 38,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              children: [
                                _buildChip(
                                  context, 
                                  '🏭 Usines & Fabricants', 
                                  () {
                                    viewModel.sendChatMessage('Quelles sont les usines disponibles sur Promogo et comment les contacter ?');
                                  },
                                ),
                                _buildChip(
                                  context, 
                                  '🔍 Recherche de produits', 
                                  () {
                                    viewModel.sendChatMessage('Comment faire une recherche de produits sur Promogo ?');
                                  },
                                ),
                                _buildChip(
                                  context, 
                                  '🎙️ Live Sale ?', 
                                  () {
                                    viewModel.sendChatMessage('C\'est quoi le Live Sale sur Promogo et comment y participer ?');
                                  },
                                ),
                                _buildChip(
                                  context, 
                                  '📈 Vendre des articles', 
                                  () {
                                    viewModel.sendChatMessage('Quelles sont les étapes pour commencer à vendre des produits sur Promogo ?');
                                  },
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    );
                  },
                ),
                
                // Champ de texte
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 4.0, bottom: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32.0),
                    border: Border.all(color: kcPrimaryColor.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const ValueKey('chat_input_field_key'),
                          controller: viewModel.textController,
                          focusNode: viewModel.inputFocusNode,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              viewModel.sendChatMessage(value);
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'mode_ia.input_hint'.tr(),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          maxLines: 4,
                          minLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ValueListenableBuilder<bool>(
                        valueListenable: viewModel.isTextEmpty,
                        builder: (context, isEmpty, child) {
                          if (!isEmpty) {
                            return GestureDetector(
                              onTap: () {
                                if (viewModel.textController.text.trim().isNotEmpty) {
                                  viewModel.sendChatMessage(viewModel.textController.text);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: kcPrimaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                              ),
                            );
                          } else {
                            return GestureDetector(
                              onTap: () => homeViewModel?.onVoiceIAClicked(),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: kcPrimaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.mic_none, color: kcPrimaryColor, size: 20),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: bottomPadding),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: kcPrimaryColor.withOpacity(0.25),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: kcPrimaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  ModeIaViewModel viewModelBuilder(BuildContext context) => ModeIaViewModel();
}
