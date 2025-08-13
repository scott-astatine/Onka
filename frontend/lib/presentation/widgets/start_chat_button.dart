import 'package:flutter/material.dart';
import '../screens/chat_screen.dart';

class StartChatButton extends StatefulWidget {
  const StartChatButton({super.key});

  @override
  State<StartChatButton> createState() => _StartChatButtonState();
}

class _StartChatButtonState extends State<StartChatButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      lowerBound: 0.95,
      upperBound: 1.05,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startChat() async {
    setState(() => _searching = true);
    // Simulate searching for a partner (replace with backend call)
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _searching = false);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(localUserId: 'me', remoteUserId: 'peer'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) => _controller.reverse(),
          onTapCancel: () => _controller.reverse(),
          onTap: _startChat,
          child: ScaleTransition(
            scale: _controller.drive(Tween(begin: 1.0, end: 1.05)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorDark,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'Start Chat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        if (_searching)
          Container(
            color: Colors.black.withValues(alpha: 0.7),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SizedBox(height: 16),
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 24),
                Text(
                  'Searching for a partner...',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
