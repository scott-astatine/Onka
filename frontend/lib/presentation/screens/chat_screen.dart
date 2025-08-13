import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../logic/websocket_provider.dart';
import '../../core/webrtc_service.dart';
import '../theme.dart';

/// Modern text chat widget with improved styling
class _TextChatWidget extends StatelessWidget {
  final List<Map<String, String>> messages;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;

  const _TextChatWidget({
    required this.messages,
    required this.controller,
    required this.focusNode,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor, width: 1),
      ),
      child: Column(
        children: [
          // Messages area
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 48,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(height: 8),
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
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[messages.length - 1 - index];
                        final isMe = message['sender'] == 'me';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.7,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? AppTheme.primaryColor
                                    : AppTheme.cardDark,
                                borderRadius: BorderRadius.circular(20)
                                    .copyWith(
                                      bottomLeft: isMe
                                          ? const Radius.circular(20)
                                          : const Radius.circular(4),
                                      bottomRight: isMe
                                          ? const Radius.circular(4)
                                          : const Radius.circular(20),
                                    ),
                              ),
                              child: Text(
                                message['text'] ?? '',
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: AppTheme.textMuted),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => onSend(),
                    onTapOutside: (event) {
                      // Don't unfocus when tapping outside
                    },
                    textInputAction: TextInputAction.send,
                    keyboardType: TextInputType.text,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: onSend,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Video container widget
class _VideoContainer extends StatelessWidget {
  final Widget child;
  final String label;
  final Color borderColor;
  final bool isLoading;
  final String? loadingText;

  const _VideoContainer({
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
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(14), child: child),
          if (isLoading)
            Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundDark.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                      strokeWidth: 3,
                    ),
                    if (loadingText != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        loadingText!,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.backgroundDark.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Main chat screen with modern, responsive design
class ChatScreen extends ConsumerStatefulWidget {
  final String localUserId;
  final String remoteUserId;

  const ChatScreen({
    super.key,
    required this.localUserId,
    required this.remoteUserId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  bool isMuted = false;
  bool isCameraOn = true;
  final List<Map<String, String>> messages = [];
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late final WebRTCService _webrtc;
  String? _peerId;
  bool _connecting = true;

  @override
  void initState() {
    super.initState();
    _webrtc = WebRTCService();
    Future.microtask(() => _initConnection());
  }

  /// Initialize local video/audio and connect to WebSocket signaling server
  Future<void> _initConnection() async {
    try {
      await _webrtc.initRenderers();

      // Add a small delay to ensure renderers are ready
      await Future.delayed(const Duration(milliseconds: 100));

      await _webrtc.getUserMedia();

      // Force a rebuild after video initialization
      if (mounted) {
        setState(() {});
      }

      debugPrint('Video ready: ${_webrtc.isVideoReady}');
      debugPrint('Local stream: ${_webrtc.localStream != null}');

      final ws = ref.read(websocketProvider.notifier);
      ws.connect(widget.localUserId);
    } catch (e) {
      debugPrint('Error in _initConnection: $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize camera: $e')),
        );
      }
    }
  }

  /// Reconnect to a new chat partner
  Future<void> _reconnectToNewChat() async {
    try {
      // Show reconnecting state
      setState(() {
        _connecting = true;
      });

      // First, properly close the current WebRTC connection
      _webrtc.close();

      // Clear the current state
      setState(() {
        messages.clear();
        _peerId = null;
      });

      // Wait a bit before creating new service
      await Future.delayed(const Duration(milliseconds: 500));

      // Create a new WebRTC service instance
      _webrtc = WebRTCService();

      // Reinitialize everything
      await _initConnection();

      debugPrint('Successfully reconnected to new chat');
    } catch (e) {
      debugPrint('Error reconnecting: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to reconnect: $e')));
      }
    }
  }

  /// Toggle camera on/off by enabling/disabling video tracks
  Future<void> _toggleCamera() async {
    setState(() => isCameraOn = !isCameraOn);
    if (_webrtc.localStream != null) {
      for (var track in _webrtc.localStream!.getVideoTracks()) {
        track.enabled = isCameraOn;
      }
    }
  }

  /// WebSocket state listener: handles peer connection and offer creation
  void _wsListener(WebSocketState state) {
    if (state.peerId != null && state.peerId != _peerId) {
      setState(() {
        _peerId = state.peerId;
        _connecting = false;
      });
      // Create and send offer to peer
      _createAndSendOffer();
    } else if (state.peerId == null && _peerId != null) {
      setState(() {
        _peerId = null;
        _connecting = true;
      });
    }
  }

  /// Create and send WebRTC offer to peer
  Future<void> _createAndSendOffer() async {
    try {
      await _webrtc.initPeerConnection({
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
        ],
      });
      final offer = await _webrtc.createOffer();
      await _webrtc.setLocalDescription(offer);
      ref.read(websocketProvider.notifier).send({
        'type': 'offer',
        'sdp': offer.sdp,
        'to': _peerId,
      });
    } catch (e) {
      debugPrint('Error creating offer: $e');
    }
  }

  /// Send a text message
  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      final messageText = _controller.text.trim();
      setState(() {
        messages.add({'sender': 'me', 'text': messageText});
      });
      _controller.clear();

      // Send message to peer via WebSocket
      if (_peerId != null) {
        ref.read(websocketProvider.notifier).send({
          'type': 'chat_message',
          'message': messageText,
          'to': _peerId,
        });
      }

      // Keep focus on the text field after sending
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to WebSocket state changes
    ref.listen<WebSocketState>(websocketProvider, (previous, next) {
      _wsListener(next);
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Video area
              Expanded(
                flex: 2,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Responsive layout: side-by-side on desktop, stacked on mobile
                    final isDesktop = constraints.maxWidth > 800;

                    if (isDesktop) {
                      // Desktop layout: side by side
                      return Row(
                        children: [
                          Expanded(
                            child: _VideoContainer(
                              label: 'Local Video',
                              borderColor: AppTheme.successColor,
                              child: _webrtc.isVideoReady
                                  ? RTCVideoView(
                                      _webrtc.localRenderer,
                                      mirror: true,
                                      objectFit: RTCVideoViewObjectFit
                                          .RTCVideoViewObjectFitCover,
                                    )
                                  : Container(
                                      color: AppTheme.cardDark,
                                      child: const Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.videocam_off,
                                              color: AppTheme.textMuted,
                                              size: 48,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Camera not available',
                                              style: TextStyle(
                                                color: AppTheme.textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _VideoContainer(
                              label: 'Remote Video',
                              borderColor: AppTheme.errorColor,
                              isLoading: _connecting,
                              loadingText: 'Connecting...',
                              child: _connecting
                                  ? Container(color: AppTheme.cardDark)
                                  : RTCVideoView(
                                      _webrtc.remoteRenderer,
                                      objectFit: RTCVideoViewObjectFit
                                          .RTCVideoViewObjectFitCover,
                                    ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Mobile layout: stacked
                      return Column(
                        children: [
                          Expanded(
                            child: _VideoContainer(
                              label: 'Local Video',
                              borderColor: AppTheme.successColor,
                              child: _webrtc.isVideoReady
                                  ? RTCVideoView(
                                      _webrtc.localRenderer,
                                      mirror: true,
                                      objectFit: RTCVideoViewObjectFit
                                          .RTCVideoViewObjectFitCover,
                                    )
                                  : Container(
                                      color: AppTheme.cardDark,
                                      child: const Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.videocam_off,
                                              color: AppTheme.textMuted,
                                              size: 48,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Camera not available',
                                              style: TextStyle(
                                                color: AppTheme.textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: _VideoContainer(
                              label: 'Remote Video',
                              borderColor: AppTheme.errorColor,
                              isLoading: _connecting,
                              loadingText: 'Connecting...',
                              child: _connecting
                                  ? Container(color: AppTheme.cardDark)
                                  : RTCVideoView(
                                      _webrtc.remoteRenderer,
                                      objectFit: RTCVideoViewObjectFit
                                          .RTCVideoViewObjectFitCover,
                                    ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Chat area
              Expanded(
                flex: 1,
                child: _TextChatWidget(
                  messages: messages,
                  controller: _controller,
                  focusNode: _focusNode,
                  onSend: _sendMessage,
                ),
              ),

              const SizedBox(height: 16),

              // Control buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mute button
                    _ControlButton(
                      icon: isMuted ? Icons.mic_off : Icons.mic,
                      label: isMuted ? 'Unmute' : 'Mute',
                      onPressed: () {
                        setState(() => isMuted = !isMuted);
                      },
                      color: isMuted
                          ? AppTheme.errorColor
                          : AppTheme.textSecondary,
                    ),

                    // Camera button
                    _ControlButton(
                      icon: isCameraOn ? Icons.videocam : Icons.videocam_off,
                      label: isCameraOn ? 'Camera Off' : 'Camera On',
                      onPressed: _toggleCamera,
                      color: isCameraOn
                          ? AppTheme.textSecondary
                          : AppTheme.errorColor,
                    ),

                    // Refresh button
                    _ControlButton(
                      icon: Icons.refresh,
                      label: 'Refresh',
                      onPressed: () {
                        _webrtc.refreshVideoRenderer();
                        setState(() {});
                      },
                      color: AppTheme.textSecondary,
                    ),

                    // Next chat button
                    _ControlButton(
                      icon: Icons.skip_next,
                      label: 'Next',
                      onPressed: () {
                        ref.read(websocketProvider.notifier).disconnect();
                        _reconnectToNewChat();
                      },
                      color: AppTheme.primaryColor,
                      isPrimary: true,
                    ),

                    // Report button
                    _ControlButton(
                      icon: Icons.flag,
                      label: 'Report',
                      onPressed: () async {
                        if (_peerId != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('User reported.')),
                          );
                        }
                      },
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _webrtc.close();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

/// Modern control button widget
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final bool isPrimary;

  const _ControlButton({
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
            color: isPrimary ? color : AppTheme.cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPrimary ? Colors.transparent : AppTheme.borderColor,
              width: 1,
            ),
          ),
          child: IconButton(
            icon: Icon(icon, color: isPrimary ? Colors.white : color, size: 24),
            onPressed: onPressed,
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
