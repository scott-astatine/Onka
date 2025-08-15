import 'package:flutter/material.dart';
import '../theme.dart';

// --- Other sub-widgets (_NoCameraView, _ControlsWidget, etc.) can remain the same ---
// (Pasting them here to keep the file complete)
class ControlsWidget extends StatelessWidget {
  final bool isMuted;
  final bool isCameraOn;
  final VoidCallback onMuteToggle;
  final VoidCallback onCameraToggle;
  final VoidCallback onNext;

  const ControlsWidget({
    super.key,
    required this.isMuted,
    required this.isCameraOn,
    required this.onMuteToggle,
    required this.onCameraToggle,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(50), // Pill shape
        border: Border.all(color: AppTheme.borderColor, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ControlButton(
            icon: isMuted ? Icons.mic_off : Icons.mic,
            label: 'Mute',
            onPressed: onMuteToggle,
            color: isMuted ? AppTheme.errorColor : AppTheme.textSecondary,
          ),
          ControlButton(
            icon: isCameraOn ? Icons.videocam : Icons.videocam_off,
            label: 'Camera',
            onPressed: onCameraToggle,
            color: isCameraOn ? AppTheme.textSecondary : AppTheme.errorColor,
          ),
          ControlButton(
            icon: Icons.skip_next,
            label: 'Next',
            onPressed: onNext,
            color: AppTheme.primaryColor,
            isPrimary: true,
          ),
        ],
      ),
    );
  }
}

class ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final bool isPrimary;

  const ControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isPrimary ? color : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: isPrimary ? Colors.white : color, size: 28),
            onPressed: onPressed,
            padding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}

class ChatMessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  const ChatMessageBubble({super.key, required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primaryColor : AppTheme.cardDark,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomLeft: isMe
                ? const Radius.circular(20)
                : const Radius.circular(4),
            bottomRight: isMe
                ? const Radius.circular(4)
                : const Radius.circular(20),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        ),
      ),
    );
  }
}
