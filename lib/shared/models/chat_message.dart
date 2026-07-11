class ChatMessage {
  final String id;
  final String text;
  final bool isFromMe;
  final DateTime sentAt;

  /// When set, this message carries a trip attachment: the id of a trip
  /// from TripCatalog rendered as a tappable trip card inside the bubble.
  final String? attachedTripId;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isFromMe,
    required this.sentAt,
    this.attachedTripId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isFromMe': isFromMe,
      'sentAt': sentAt.toIso8601String(),
      'attachedTripId': attachedTripId,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final text = json['text'];
    final isFromMe = json['isFromMe'];
    final sentAt = json['sentAt'];
    final attachedTripId = json['attachedTripId'];

    return ChatMessage(
      id: id is String ? id : '',
      text: text is String ? text : '',
      isFromMe: isFromMe is bool ? isFromMe : false,
      sentAt: sentAt is String
          ? (DateTime.tryParse(sentAt) ?? DateTime.now())
          : DateTime.now(),
      attachedTripId: attachedTripId is String && attachedTripId.isNotEmpty
          ? attachedTripId
          : null,
    );
  }
}
