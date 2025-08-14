import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/config.dart'; // Assuming you have a config file for the URL

/// Provides the WebSocketNotifier to the app.
final websocketProvider =
    StateNotifierProvider<WebSocketNotifier, WebSocketState>((ref) {
  return WebSocketNotifier();
});

/// Represents the state of the WebSocket connection.
class WebSocketState {
  final bool connected;
  final String? peerId;
  final String? error;
  // **FIX 1: Added a 'data' property to hold the latest message.**
  // This is the crucial change that allows the UI to receive signaling messages.
  final Map<String, dynamic>? data;

  WebSocketState({
    this.connected = false,
    this.peerId,
    this.error,
    this.data,
  });

  WebSocketState copyWith({
    bool? connected,
    String? peerId,
    String? error,
    Map<String, dynamic>? data,
    bool clearPeerId = false, // Helper to explicitly nullify peerId
  }) {
    return WebSocketState(
      connected: connected ?? this.connected,
      // If clearPeerId is true, set peerId to null, otherwise use the new value or the old one.
      peerId: clearPeerId ? null : peerId ?? this.peerId,
      error: error ?? this.error,
      data: data ?? this.data,
    );
  }
}

/// Manages the WebSocket connection and its state.
class WebSocketNotifier extends StateNotifier<WebSocketState> {
  WebSocketChannel? _channel;

  WebSocketNotifier() : super(WebSocketState());

  /// Connects to the WebSocket server with the given client ID.
  void connect(String clientId) {
    if (state.connected) return; // Avoid reconnecting if already connected

    final url = '${AppConfig.websocketUrl}/ws/$clientId';
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _channel!.stream.listen(_onMessage, onError: _onError, onDone: _onDone);
      state = state.copyWith(connected: true, error: null);
      print("✅ WebSocket connected to: $url");
    } catch (e) {
      print("❌ WebSocket connection error: $e");
      state = state.copyWith(error: e.toString(), connected: false);
    }
  }

  /// Closes the WebSocket connection and resets the state.
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    state = WebSocketState(); // Reset to initial state
    print("🔌 WebSocket disconnected.");
  }

  /// Handles incoming messages from the WebSocket server.
  void _onMessage(dynamic message) {
    try {
      final data = jsonDecode(message) as Map<String, dynamic>;
      print("⬇️ Received WS message: $data");

      // **FIX 2: Pass ALL messages to the state via the 'data' property.**
      // This ensures the UI is notified of every message, not just peer_found.
      switch (data['type']) {
        case 'peer_found':
          state = state.copyWith(peerId: data['peer_id'], data: data);
          break;
        case 'peer_disconnected':
          // Use the helper flag to explicitly set peerId to null.
          state = state.copyWith(clearPeerId: true, data: data);
          break;
        default:
          // For offer, answer, candidate, etc., just pass the data through.
          state = state.copyWith(data: data);
      }
    } catch (e) {
      print("❌ Error decoding message: $e");
    }
  }

  /// Handles errors on the WebSocket stream.
  void _onError(error) {
    print("❌ WebSocket error: $error");
    state = state.copyWith(error: error.toString(), connected: false);
  }

  /// Handles the closing of the WebSocket stream.
  void _onDone() {
    print("WebSocket connection done.");
    state = state.copyWith(connected: false, clearPeerId: true);
  }

  /// Sends data to the WebSocket server.
  void send(Map<String, dynamic> data) {
    if (_channel != null && state.connected) {
      final message = jsonEncode(data);
      print("⬆️ Sending WS message: $message");
      _channel!.sink.add(message);
    } else {
      print("⚠️ Tried to send message, but WebSocket is not connected.");
    }
  }
}

