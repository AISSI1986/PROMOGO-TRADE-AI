class ChatMessageModel {
  final int id;
  final int roomId;
  final int senderId;
  final String senderUsername;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final bool isPending;

  ChatMessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderUsername,
    required this.content,
    required this.timestamp,
    required this.isRead,
    this.isPending = false,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as int,
      roomId: json['room'] as int? ?? json['room_id'] as int,
      senderId: json['sender'] as int? ?? json['sender_id'] as int,
      senderUsername: json['sender_username'] as String? ?? '',
      content: json['content'] as String? ?? '',
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['is_read'] as bool? ?? false,
      isPending: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'sender_id': senderId,
      'sender_username': senderUsername,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
    };
  }
}

