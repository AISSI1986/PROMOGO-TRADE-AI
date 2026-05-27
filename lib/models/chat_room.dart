import 'package:promogoai/ui/common/api_constants.dart';

class ChatRoomModel {
  final int id;
  final int buyerId;
  final int sellerId;
  final int? adId;
  final String buyerUsername;
  final String sellerUsername;
  final String buyerFullName;
  final String sellerFullName;
  final String buyerPhone;
  final String sellerPhone;
  
  final String? adTitle;
  final String? adPrice;
  final String? adImageUrl;
  
  final String? lastMessageContent;
  final DateTime? lastMessageTime;
  final int unreadCount;
  
  final bool buyerIsOnline;
  final DateTime? buyerLastSeen;
  final bool sellerIsOnline;
  final DateTime? sellerLastSeen;

  ChatRoomModel({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    this.adId,
    required this.buyerUsername,
    required this.sellerUsername,
    required this.buyerFullName,
    required this.sellerFullName,
    required this.buyerPhone,
    required this.sellerPhone,
    this.adTitle,
    this.adPrice,
    this.adImageUrl,
    this.lastMessageContent,
    this.lastMessageTime,
    required this.unreadCount,
    required this.buyerIsOnline,
    this.buyerLastSeen,
    required this.sellerIsOnline,
    this.sellerLastSeen,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    final buyerDetails = json['buyer_details'] as Map<String, dynamic>?;
    final sellerDetails = json['seller_details'] as Map<String, dynamic>?;
    final adDetails = json['ad_details'] as Map<String, dynamic>?;
    final lastMessage = json['last_message'] as Map<String, dynamic>?;

    final String buyerFName = buyerDetails != null ? '${buyerDetails['first_name'] ?? ''} ${buyerDetails['last_name'] ?? ''}'.trim() : '';
    final String sellerFName = sellerDetails != null ? '${sellerDetails['first_name'] ?? ''} ${sellerDetails['last_name'] ?? ''}'.trim() : '';

    String? adImg;
    if (adDetails != null && adDetails['images'] != null && (adDetails['images'] as List).isNotEmpty) {
      String rawUrl = adDetails['images'][0]['image'] as String;
      if (rawUrl.startsWith('/')) {
        adImg = '${ApiConstants.djangoRootUrl}$rawUrl';
      } else if (rawUrl.contains('/media/')) {
        adImg = '${ApiConstants.djangoRootUrl}${rawUrl.substring(rawUrl.indexOf('/media/'))}';
      } else {
        adImg = rawUrl;
      }
    }

    DateTime? lastMsgTime;
    if (lastMessage != null && lastMessage['timestamp'] != null) {
      lastMsgTime = DateTime.parse(lastMessage['timestamp'] as String);
    }

    final bool buyerOnline = buyerDetails != null ? (buyerDetails['is_online'] as bool? ?? false) : false;
    final bool sellerOnline = sellerDetails != null ? (sellerDetails['is_online'] as bool? ?? false) : false;
    
    DateTime? buyerSeen;
    if (buyerDetails != null && buyerDetails['last_seen'] != null) {
      buyerSeen = DateTime.parse(buyerDetails['last_seen'] as String);
    }
    
    DateTime? sellerSeen;
    if (sellerDetails != null && sellerDetails['last_seen'] != null) {
      sellerSeen = DateTime.parse(sellerDetails['last_seen'] as String);
    }

    return ChatRoomModel(
      id: json['id'] as int,
      buyerId: json['buyer'] as int,
      sellerId: json['seller'] as int,
      adId: json['ad'] as int?,
      buyerUsername: buyerDetails != null ? (buyerDetails['username'] as String? ?? '') : '',
      sellerUsername: sellerDetails != null ? (sellerDetails['username'] as String? ?? '') : '',
      buyerFullName: buyerFName.isNotEmpty ? buyerFName : (buyerDetails != null ? (buyerDetails['username'] as String? ?? '') : 'Acheteur'),
      sellerFullName: sellerFName.isNotEmpty ? sellerFName : (sellerDetails != null ? (sellerDetails['username'] as String? ?? '') : 'Vendeur'),
      buyerPhone: buyerDetails != null ? (buyerDetails['call_number'] as String? ?? '') : '',
      sellerPhone: sellerDetails != null ? (sellerDetails['call_number'] as String? ?? '') : '',
      adTitle: adDetails != null ? adDetails['title'] as String? : null,
      adPrice: adDetails != null && adDetails['prix'] != null ? '${adDetails['prix']} F CFA' : null,
      adImageUrl: adImg,
      lastMessageContent: lastMessage != null ? lastMessage['content'] as String? : null,
      lastMessageTime: lastMsgTime,
      unreadCount: json['unread_count'] as int? ?? 0,
      buyerIsOnline: buyerOnline,
      buyerLastSeen: buyerSeen,
      sellerIsOnline: sellerOnline,
      sellerLastSeen: sellerSeen,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyer': buyerId,
      'seller': sellerId,
      'ad': adId,
      'buyer_details': {
        'username': buyerUsername,
        'first_name': buyerFullName.split(' ').first,
        'last_name': buyerFullName.split(' ').length > 1 ? buyerFullName.split(' ').sublist(1).join(' ') : '',
        'call_number': buyerPhone,
        'is_online': buyerIsOnline,
        'last_seen': buyerLastSeen?.toIso8601String(),
      },
      'seller_details': {
        'username': sellerUsername,
        'first_name': sellerFullName.split(' ').first,
        'last_name': sellerFullName.split(' ').length > 1 ? sellerFullName.split(' ').sublist(1).join(' ') : '',
        'call_number': sellerPhone,
        'is_online': sellerIsOnline,
        'last_seen': sellerLastSeen?.toIso8601String(),
      },
      'ad_details': adTitle != null ? {
        'title': adTitle,
        'prix': adPrice?.replaceAll(' F CFA', ''),
        'images': adImageUrl != null ? [{'image': adImageUrl}] : [],
      } : null,
      'last_message': lastMessageContent != null ? {
        'content': lastMessageContent,
        'timestamp': lastMessageTime?.toIso8601String(),
      } : null,
      'unread_count': unreadCount,
    };
  }
}

