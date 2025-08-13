import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widgets/start_chat_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? usersOnline;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchUsersOnline();
    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _fetchUsersOnline(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchUsersOnline() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.105:8000/api/stats'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          usersOnline = data['users_online'] ?? 0;
        });
      }
    } catch (_) {
      setState(() {
        usersOnline = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to onka',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const StartChatButton(),
            const SizedBox(height: 24),
            Text(
              usersOnline == null
                  ? 'Users Online: ...'
                  : 'Users Online: $usersOnline',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
