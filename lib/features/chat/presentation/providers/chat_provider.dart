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
      final fallbackReply = _getClinicalFallback(trimmed);
      final fallbackAiMessage = ChatMessage(
        sender: 'ai',
        text: fallbackReply,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: List<ChatMessage>.from(state.messages)..add(fallbackAiMessage),
        isLoading: false,
        clearError: true,
      );
    }
  }

  static String _getClinicalFallback(String message) {
    final q = message.toLowerCase();

    if (q.contains('eczema') || q.contains('rash') || q.contains('itch') || q.contains('dermatitis') || q.contains('dry')) {
      return 'Common symptoms of **Eczema (Atopic Dermatitis)** include:\n\n'
          '• **Intense itching (pruritus)**, frequently worsening at night\n'
          '• **Dry, sensitive, cracked, or leathery skin**\n'
          '• **Red to brownish-gray patches**, especially on hands, wrists, neck, inner elbows, and knees\n'
          '• **Small, raised bumps** that may weep fluid and form crusts when scratched\n'
          '• **Raw, sensitive, or swollen skin** from persistent rubbing\n\n'
          '**Self-Care & Management Tips:**\n'
          '1. **Hydrate skin**: Apply thick, ceramide-rich creams or ointments within 3 minutes after bathing.\n'
          '2. **Gentle bathing**: Use lukewarm water and mild, fragrance-free, soap-free cleansers.\n'
          '3. **Anti-itch care**: Over-the-counter 1% hydrocortisone cream can temporarily calm acute flare-ups.\n'
          '4. **Avoid triggers**: Wear soft cotton fabrics and minimize exposure to harsh detergents.\n\n'
          '💡 *Tip: Check our **Nearby Care** screen to find certified dermatologists in your area for personalized prescription topicals.*';
    }

    if (q.contains('acne') || q.contains('pimple') || q.contains('blemish') || q.contains('zit')) {
      return '**Acne Vulgaris Management & Insights:**\n\n'
          '• **Causes**: Excess sebum (oil), trapped dead skin cells, and *C. acnes* bacteria clogging follicles.\n'
          '• **Key Ingredients**:\n'
          '  - **Salicylic Acid (BHA)**: Unclogs pores, dissolves blackheads and whiteheads.\n'
          '  - **Benzoyl Peroxide**: Kills acne-causing bacteria and reduces inflammation.\n'
          '  - **Niacinamide**: Reduces redness, oiliness, and post-inflammatory marks.\n'
          '• **Daily Habits**: Wash twice daily with gentle foaming cleanser, never pop or squeeze lesions, and always apply a non-comedogenic SPF.\n\n'
          'For persistent or cystic acne, a dermatologist can prescribe topical retinoids or oral medications.';
    }

    if (q.contains('mole') || q.contains('melanoma') || q.contains('cancer') || q.contains('spot')) {
      return 'When examining moles or suspicious pigmented lesions, dermatologists rely on the **ABCDE Rule**:\n\n'
          '• **A - Asymmetry**: One half does not match the other half.\n'
          '• **B - Border**: Jagged, scalloped, or blurred margins.\n'
          '• **C - Color**: Uneven color with shades of tan, brown, black, white, red, or blue.\n'
          '• **D - Diameter**: Larger than 6 mm (approx. pencil eraser size).\n'
          '• **E - Evolving**: Any change in size, shape, color, or symptoms like itching, oozing, or bleeding.\n\n'
          '⚠️ *If you notice any of these signs, please visit a certified dermatologist promptly. You can find nearby specialists on the **Nearby Care** tab.*';
    }

    if (q.contains('scan') || q.contains('camera') || q.contains('photo') || q.contains('picture') || q.contains('upload')) {
      return '**How to Get the Best Results with DermaScan AI:**\n\n'
          '1. **Natural Lighting**: Take photos in bright, indirect daylight without harsh flash glare or shadows.\n'
          '2. **Optimal Distance**: Keep the camera lens 10–15 cm from the skin lesion.\n'
          '3. **Clear Focus**: Tap the screen to ensure the lesion is sharp and centered in the targeting crosshairs.\n'
          '4. **Single Lesion**: Focus on one lesion at a time for maximum deep-learning diagnostic accuracy.\n\n'
          'Tap the **Scan** button in the bottom navigation to start!';
    }

    if (q.contains('doctor') || q.contains('clinic') || q.contains('hospital') || q.contains('nearby') || q.contains('appointment')) {
      return 'You can find trusted dermatologists, clinics, and tertiary medical centers near your current location directly in the **Nearby Care** tab.\n\n'
          '• View verified doctor profiles and distance\n'
          '• One-tap phone calling for appointments\n'
          '• Instant Google Maps turn-by-turn navigation\n'
          '• Filter by specialty (Dermatologist, Pediatric, General Practice)';
    }

    return 'Thank you for your question. For all unusual rashes, persistent itching, spreading redness, or changing moles, early clinical assessment provides the best outcomes.\n\n'
        'You can use DermaScan AI\'s **Scan** feature for instant visual triage, or open the **Nearby Care** map to connect with licensed dermatologists near you.';
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
