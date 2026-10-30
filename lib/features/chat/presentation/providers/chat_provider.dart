import 'dart:convert';
import 'package:dermascan_ai/core/constants/api_endpoints.dart';
import 'package:dermascan_ai/features/chat/domain/chat_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier()
      : super(
          ChatState(
            messages: [
              ChatMessage(
                sender: 'ai',
                text:
                    'Hello! I am your AI Skin Assistant for DermaScan AI. How can I help you understand your skin concerns or guide you through the app today?',
                timestamp: DateTime.now(),
              ),
            ],
          ),
        );

  Future<void> sendMessage(String userText) async {
    final trimmed = userText.trim();
    if (trimmed.isEmpty) return;

    final userMessage = ChatMessage(
      sender: 'user',
      text: trimmed,
      timestamp: DateTime.now(),
    );

    // Append user message immediately and set loading state
    final updatedMessages = List<ChatMessage>.from(state.messages)..add(userMessage);
    state = state.copyWith(
      messages: updatedMessages,
      isLoading: true,
      clearError: true,
    );

    try {
      // Build conversation history for context
      final historyPayload = state.messages
          .take(state.messages.length - 1)
          .map((m) => {
                'role': m.isUser ? 'user' : 'model',
                'content': m.text,
              })
          .toList();

      final response = await http
          .post(
            Uri.parse(ApiEndpoints.chat),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'message': trimmed,
              'history': historyPayload,
            }),
          )
          .timeout(const Duration(seconds: 25));

      String aiReplyText = '';

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Handle various response wrappers: { reply }, { data: { response } }, { response }
        if (decoded.containsKey('reply') && decoded['reply'] != null) {
          aiReplyText = decoded['reply'].toString();
        } else if (decoded.containsKey('data') && decoded['data'] is Map<String, dynamic>) {
          final dataObj = decoded['data'] as Map<String, dynamic>;
          aiReplyText = (dataObj['response'] ?? dataObj['reply'] ?? '').toString();
        } else if (decoded.containsKey('response') && decoded['response'] != null) {
          aiReplyText = decoded['response'].toString();
        }

        if (aiReplyText.trim().isEmpty) {
          aiReplyText =
              'I received your message. Please remember to consult a licensed dermatologist for clinical diagnoses and treatment.';
        }
      } else {
        try {
          final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
          final msg = errorBody['error']?['message'] ?? errorBody['message'];
          aiReplyText = msg != null
              ? '$msg'
              : 'Our AI Assistant is currently processing a high volume of requests. Please try again or consult a dermatologist.';
        } catch (_) {
          aiReplyText =
              'I am having trouble connecting to the server right now. Please check your internet connection or try again in a moment.';
        }
      }

      final aiMessage = ChatMessage(
        sender: 'ai',
        text: aiReplyText.trim(),
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: List<ChatMessage>.from(state.messages)..add(aiMessage),
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      final fallbackAiMessage = ChatMessage(
        sender: 'ai',
        text:
            'I could not reach the DermaScan AI server. If you are experiencing concerning skin changes, rash, or irritation, we strongly advise scheduling an evaluation with a local dermatologist.',
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: List<ChatMessage>.from(state.messages)..add(fallbackAiMessage),
        isLoading: false,
        error: 'Network connection issue: $e',
      );
    }
  }

  void clearChat() {
    state = ChatState(
      messages: [
        ChatMessage(
          sender: 'ai',
          text:
              'Chat cleared. How can I assist you with your skin health or using DermaScan AI today?',
          timestamp: DateTime.now(),
        ),
      ],
      isLoading: false,
      error: null,
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});
