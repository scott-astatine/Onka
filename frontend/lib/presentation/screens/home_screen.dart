import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../logic/stats_provider.dart';
import '../../logic/auth_provider.dart';
import 'chat_screen.dart';
import '../widgets/start_chat_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _startChat(BuildContext context, WidgetRef ref) async {
    // Generate a unique ID for this user session
    final localUserId = const Uuid().v4();

    // This is the POST request to the backend to get a token.
    await ref.read(authProvider.notifier).login(localUserId);

    // Navigate to the chat screen
    // It's good practice to check if the widget is still mounted before navigating.
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(localUserId: localUserId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to OnKa',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            StartChatButton(
              onPressed: () => _startChat(context, ref),
            ),
            const SizedBox(height: 48),
            stats.when(
              data: (usersOnline) => Text('Users Online: $usersOnline',
                  style: const TextStyle(fontSize: 16)),
              loading: () => const Text('Users Online: ...',
                  style: TextStyle(fontSize: 16)),
              error: (err, stack) => const Text('Users Online: -',
                  style: TextStyle(fontSize: 16, color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
