import 'package:flutter/material.dart';
import 'package:onka/presentation/theme.dart';

class VideoContainer extends StatelessWidget {
  final Widget child;
  final String label;
  final Color borderColor;
  final bool isLoading;
  final String? loadingText;

  const VideoContainer({
    super.key,
    required this.child,
    required this.label,
    required this.borderColor,
    this.isLoading = false,
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(14), child: child),
          if (isLoading)
            Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundDark.withValues(alpha: .8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                    if (loadingText != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        loadingText!,
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: .5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
