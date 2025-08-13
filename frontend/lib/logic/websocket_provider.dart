import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final websocketProvider =
    StateNotifierProvider<WebSocketNotifier, WebSocketState>((ref) {
      return WebSocketNotifier();
    });

class WebSocketState {
  final bool connected;
  final String? peerId;
  final String? error;
  WebSocketState({this.connected = false, this.peerId, this.error});

  WebSocketState copyWith({bool? connected, String? peerId, String? error}) =>
      WebSocketState(
        connected: connected ?? this.connected,
        peerId: peerId ?? this.peerId,
        error: error ?? this.error,
      );
}

class WebSocketNotifier extends StateNotifier<WebSocketState> {
  WebSocketChannel? _channel;

  WebSocketNotifier() : super(WebSocketState());

  void connect(String clientId) {
    final url = 'ws://localhost:8000/ws/$clientId';
    _channel = WebSocketChannel.connect(Uri.parse(url));
    _channel!.stream.listen(_onMessage, onError: _onError, onDone: _onDone);
    state = state.copyWith(connected: true, error: null);
  }

  void disconnect() {
    _channel?.sink.close();
    state = WebSocketState();
  }

  void _onMessage(dynamic message) {
    final data = jsonDecode(message);
    if (data['type'] == 'peer_found') {
      state = state.copyWith(peerId: data['peer_id']);
    } else if (data['type'] == 'peer_disconnected') {
      state = state.copyWith(peerId: null);
    }
    // Handle other signaling messages as needed
  }

  void _onError(error) {
    state = state.copyWith(error: error.toString(), connected: false);
  }

  void _onDone() {
    state = state.copyWith(connected: false);
  }

  void send(dynamic data) {
    _channel?.sink.add(jsonEncode(data));
  }
}
