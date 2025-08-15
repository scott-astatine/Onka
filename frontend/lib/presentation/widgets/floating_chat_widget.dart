import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:onka/presentation/theme.dart';
import 'package:onka/presentation/widgets/chat_input.dart';
import 'package:onka/presentation/widgets/control_bar_widget.dart';

class FloatingChatWidget extends StatelessWidget {
  final List<Map<String, String>> messages;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final bool isExpanded;

  const FloatingChatWidget({
    super.key,
    required this.messages,
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final boxDecoration = BoxDecoration(
      color: AppTheme.surfaceDark.withValues(alpha: .55),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: AppTheme.borderColor.withValues(alpha: .5),
        width: 1,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: isExpanded ? 10.0 : 0.0,
          sigmaY: isExpanded ? 10.0 : 0.0,
        ),
        child: Container(
          decoration: boxDecoration,
          child: Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 48,
                              color: AppTheme.textMuted,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Start a conversation',
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 16,
                              ),
                            ),
                          ],
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
              ChatInput(
                controller: controller,
                focusNode: focusNode,
                onSend: onSend,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
