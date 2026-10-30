enum MessageSender {
  user,
  ai;

  String get value => name;

  static MessageSender fromString(String val) {
    if (val.toLowerCase() == 'ai' || val.toLowerCase() == 'model' || val.toLowerCase() == 'assistant') {
      return MessageSender.ai;
    }
    return MessageSender.user;
  }
}

class ChatMessage {
  final String sender; // 'user' | 'ai'
  final String text;
  final DateTime timestamp;

  const ChatMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
  });

  bool get isUser => sender == 'user';
  bool get isAi => sender == 'ai';

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      sender: json['sender'] as String? ?? 'user',
      text: json['text'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  ChatMessage copyWith({
    String? sender,
    String? text,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      sender: sender ?? this.sender,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
