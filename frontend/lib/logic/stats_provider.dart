import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../core/config.dart';

/// Provider that periodically fetches and provides online user stats.
///
/// It polls the backend every 5 seconds and streams the number of online users.
final statsProvider = StreamProvider.autoDispose<int>((ref) {
  final controller = StreamController<int>();

  // Fetch stats immediately and then every 5 seconds.
  Future<void> fetch() async {
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/stats'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        controller.add(data['users_online'] ?? 0);
      }
    } catch (e) {
      // Silently ignore errors for this non-critical feature.
    }
  }

  fetch();
  final timer = Timer.periodic(const Duration(seconds: 5), (_) => fetch());

  // When the provider is destroyed, cancel the timer and close the stream.
  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });

  return controller.stream;
});
