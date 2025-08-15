import 'package:flutter/material.dart';
import 'package:onka/presentation/theme.dart';
import 'package:onka/presentation/widgets/chat_input.dart';
import 'package:onka/presentation/widgets/control_bar_widget.dart';

class BigScreenChatWidget extends StatelessWidget {
  final List<Map<String, String>> messages;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;

  const BigScreenChatWidget({
    super.key,
    required this.messages,
    required this.controller,
    required this.focusNode,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withValues(alpha: .66),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: Border(
          left: BorderSide(
            color: AppTheme.borderColor.withValues(alpha: .5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Chat',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: AppTheme.textPrimary),
            ),
          ),
          const Divider(height: 1, thickness: 0.6, color: AppTheme.borderColor),
          // Message List
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      'No messages yet.',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message['sender'] == 'me';
                      return ChatMessageBubble(
                        text: message['text'] ?? '',
                        isMe: isMe,
                      );
                    },
                  ),
          ),
          // Input
          ChatInput(
            controller: controller,
            focusNode: focusNode,
            onSend: onSend,
          ),
        ],
      ),
    );
  }
}
