import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';
import 'package:promogoai/models/chat_room.dart';
import 'package:promogoai/models/chat_message.dart';
import 'package:promogoai/services/chat_service.dart';
import 'chat_viewmodel.dart';

class ChatView extends StackedView<ChatViewModel> {
  final ChatRoomModel chatRoom;

  const ChatView({Key? key, required this.chatRoom}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ChatViewModel viewModel,
    Widget? child,
  ) {
    final otherUserName = viewModel.currentUserId == chatRoom.buyerId
        ? chatRoom.sellerFullName
        : chatRoom.buyerFullName;

    return Scaffold(
      backgroundColor: kcBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kcPrimaryColor, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: kcPrimaryColor.withOpacity(0.1),
              radius: 18,
              child: Text(
                otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: kcPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            horizontalSpaceSmall,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    otherUserName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: kcPrimaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusText(viewModel),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Product banner
            if (chatRoom.adTitle != null) _buildProductBanner(context),
            
            // Messages stream list
            Expanded(
              child: viewModel.isBusy
                  ? const Center(child: CircularProgressIndicator(color: kcPrimaryColor))
                  : _buildMessageList(viewModel),
            ),
            
            // Bottom input bar
            _buildInputBar(viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildProductBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        children: [
          if (chatRoom.adImageUrl != null && chatRoom.adImageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: chatRoom.adImageUrl!,
                width: 45,
                height: 45,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  width: 45,
                  height: 45,
                  color: kcPrimaryColor.withOpacity(0.05),
                  child: const Icon(Icons.image, size: 20, color: Colors.grey),
                ),
              ),
            )
          else
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: kcPrimaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.shopping_bag_outlined, size: 20, color: kcPrimaryColor),
            ),
          horizontalSpaceMedium,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  chatRoom.adTitle ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kcPrimaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  chatRoom.adPrice ?? '',
                  style: const TextStyle(
                    color: kcSecondaryGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ChatViewModel viewModel) {
    if (viewModel.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: kcPrimaryColor.withOpacity(0.1)),
            verticalSpaceSmall,
            Text(
              'chat.no_messages'.tr(),
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: viewModel.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: viewModel.messages.length,
      itemBuilder: (context, index) {
        final message = viewModel.messages[index];
        final isMe = message.senderId == viewModel.currentUserId;
        return _buildMessageBubble(message, isMe);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessageModel message, bool isMe) {
    final Alignment bubbleAlignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final Color bubbleColor = isMe ? kcPrimaryColor : Colors.white;
    final Color textColor = isMe ? Colors.white : kcPrimaryColorDark;
    
    final String timeStr = DateFormat('HH:mm').format(message.timestamp.toLocal());

    // Check if the message contains product metadata
    String displayContent = message.content;
    String? adImageUrl;
    String? adPrice;
    
    if (message.content.contains('|[AD_INFO:')) {
      final parts = message.content.split('|[AD_INFO:');
      displayContent = parts[0];
      if (parts.length > 1) {
        final meta = parts[1].replaceAll(']', '');
        final metaParts = meta.split('|');
        if (metaParts.isNotEmpty) adImageUrl = metaParts[0];
        if (metaParts.length > 1) adPrice = metaParts[1];
      }
    }

    return Align(
      alignment: bubbleAlignment,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (adImageUrl != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isMe ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: CachedNetworkImage(
                        imageUrl: adImageUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          width: 40,
                          height: 40,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image, size: 16, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayContent.contains(':') 
                                ? displayContent.split(':').last.trim() 
                                : 'Produit',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (adPrice != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              adPrice,
                              style: TextStyle(
                                color: isMe ? kcSecondaryGold : kcPrimaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Text(
              displayContent,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeStr,
                    style: TextStyle(
                      color: isMe ? Colors.white.withOpacity(0.7) : Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.isRead ? Icons.done_all : Icons.done,
                      size: 14,
                      color: message.isRead
                          ? kcSecondaryGold
                          : Colors.white.withOpacity(0.7),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(ChatViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: kcBackgroundColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: viewModel.messageController,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 14, color: kcPrimaryColor),
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'chat.input_hint'.tr(),
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          horizontalSpaceSmall,
          GestureDetector(
            onTap: viewModel.sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: kcSecondaryGold,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusText(ChatViewModel viewModel) {
    if (viewModel.connectionStatus == ChatConnectionState.connecting) {
      return Text(
        'chat.connecting'.tr(),
        style: const TextStyle(
          color: kcSecondaryGold,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    if (viewModel.connectionStatus == ChatConnectionState.disconnected) {
      return Text(
        'chat.offline_status'.tr(),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      );
    }

    if (viewModel.otherUserIsTyping) {
      return Text(
        'chat.typing'.tr(),
        style: const TextStyle(
          color: kcSecondaryGold,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    if (viewModel.otherUserIsOnline) {
      return Text(
        'chat.online'.tr(),
        style: const TextStyle(
          color: kcSuccessColor,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    final lastSeen = viewModel.otherUserLastSeen;
    String status = 'chat.offline'.tr();
    if (lastSeen != null) {
      final difference = DateTime.now().difference(lastSeen);
      if (difference.inMinutes < 1) {
        status = 'chat.last_seen'.tr(args: ['chat.just_now'.tr()]);
      } else if (difference.inMinutes < 60) {
        status = 'chat.last_seen'.tr(args: ['${difference.inMinutes} min']);
      } else if (difference.inHours < 24) {
        status = 'chat.last_seen'.tr(args: ['${difference.inHours} h']);
      } else {
        status = 'chat.last_seen'.tr(args: [DateFormat('dd/MM/yyyy HH:mm').format(lastSeen.toLocal())]);
      }
    }

    return Text(
      status,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 11,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  @override
  ChatViewModel viewModelBuilder(BuildContext context) => ChatViewModel();

  @override
  void onViewModelReady(ChatViewModel viewModel) {
    viewModel.init(chatRoom);
  }
}
