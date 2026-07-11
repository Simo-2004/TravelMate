class ChatMessage {
  final String id;
  final String text;
  final bool isFromMe;
  final DateTime sentAt;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isFromMe,
    required this.sentAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isFromMe': isFromMe,
      'sentAt': sentAt.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final text = json['text'];
    final isFromMe = json['isFromMe'];
    final sentAt = json['sentAt'];

    return ChatMessage(
      id: id is String ? id : '',
      text: text is String ? text : '',
      isFromMe: isFromMe is bool ? isFromMe : false,
      sentAt: sentAt is String
          ? (DateTime.tryParse(sentAt) ?? DateTime.now())
          : DateTime.now(),
    );
  }
}
