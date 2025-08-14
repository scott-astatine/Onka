import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:onka/presentation/widgets/big_screen_chat_widget.dart';
import 'package:onka/presentation/widgets/control_bar_widget.dart';
import 'package:onka/presentation/widgets/floating_chat_widget.dart';
import 'package:onka/presentation/widgets/video_container.dart';
import '../../core/webrtc_service.dart';
import '../../logic/websocket_provider.dart';
import '../theme.dart';


final webrtcServiceProvider = Provider.autoDispose<WebRTCService>((ref) {
  final service = WebRTCService();
  ref.onDispose(() => service.close());
  return service;
});


class ChatScreen extends ConsumerStatefulWidget {
  final String localUserId;

  const ChatScreen({super.key, required this.localUserId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  // UI State
  bool _isMuted = false;
  bool _isCameraOn = true;
  bool _isConnecting = true;
  bool _isChatExpanded = false; // Used only for mobile floating chat
  String? _peerId;

  Offset _pipOffset = Offset.zero;
  final GlobalKey _pipKey = GlobalKey();

  // Chat State
  final List<Map<String, String>> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Set initial PIP position after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      final safeArea = MediaQuery.of(context).padding;
      setState(() {
        // Default position: top right corner
        _pipOffset = Offset(screenWidth - 120 - 16, safeArea.top + 16);
      });
      _initConnection();
    });

    // Listen to focus changes to expand/collapse the chat on mobile
    _textFocusNode.addListener(() {
      if (_textFocusNode.hasFocus != _isChatExpanded) {
        setState(() => _isChatExpanded = _textFocusNode.hasFocus);
      }
    });
  }

  // --- Core Logic & Signaling between peer and signaling server

  Future<void> _initConnection() async {
    setState(() => _isConnecting = true);
    final webrtc = ref.read(webrtcServiceProvider);

    try {
      await webrtc.initRenderers();
      await webrtc.getUserMedia();
      if (mounted) setState(() {});
      ref.read(websocketProvider.notifier).connect(widget.localUserId);
    } catch (e) {
      debugPrint('❌ Error in _initConnection: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize camera/mic: $e')),
        );
      }
    }
  }

  Future<void> _findNewPartner() async {
    ref.read(websocketProvider.notifier).disconnect();
    ref.invalidate(webrtcServiceProvider);

    setState(() {
      _messages.clear();
      _peerId = null;
      _isConnecting = true;
    });

    await Future.delayed(const Duration(milliseconds: 200));
    await _initConnection();
  }

  void _toggleCamera() {
    final webrtc = ref.read(webrtcServiceProvider);
    if (webrtc.localStream != null) {
      final newCameraState = !_isCameraOn;
      webrtc.localStream!.getVideoTracks().forEach((track) {
        track.enabled = newCameraState;
      });
      setState(() => _isCameraOn = newCameraState);
    }
  }

  void _toggleMute() {
    final webrtc = ref.read(webrtcServiceProvider);
    if (webrtc.localStream != null) {
      final newMuteState = !_isMuted;
      // Note: For audio, enabled=true means unmuted.
      webrtc.localStream!.getAudioTracks().forEach((track) {
        track.enabled = !newMuteState;
      });
      setState(() => _isMuted = newMuteState);
    }
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;
    final messageText = _textController.text.trim();
    setState(() {
      _messages.insert(0, {'sender': 'me', 'text': messageText});
    });
    _textController.clear();

    if (_peerId != null) {
      ref.read(websocketProvider.notifier).send({
        'type': 'chat_message',
        'message': messageText,
        'to': _peerId,
      });
    }
    _textFocusNode.requestFocus();
  }

  void _handleWebSocketState(WebSocketState state) {
    if (state.peerId != null && state.peerId != _peerId) {
      setState(() {
        _peerId = state.peerId;
        _isConnecting = false;
      });
      _initAndSendOffer();
    } else if (state.peerId == null && _peerId != null) {
      setState(() {
        _peerId = null;
        _isConnecting = true;
        _messages.clear();
      });
    }

    final data = state.data;
    if (data != null) {
      switch (data['type']) {
        case 'offer':
          _initAndSendAnswer(data);
          break;
        case 'answer':
          _handleAnswer(data);
          break;
        case 'candidate':
          _handleCandidate(data);
          break;
        case 'chat_message':
          _handleChatMessage(data);
          break;
      }
    }
  }

  Future<void> _initPeerConnection() async {
    final webrtc = ref.read(webrtcServiceProvider);
    final wsNotifier = ref.read(websocketProvider.notifier);
    await webrtc.initPeerConnection(
      configuration: {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
        ],
      },
      onIceCandidate: (candidate) {
        wsNotifier.send({
          'type': 'candidate',
          'candidate': candidate.toMap(),
          'to': _peerId,
        });
      },
      onTrack: (stream) {
        if (mounted) setState(() {});
      },
    );
  }

  Future<void> _initAndSendOffer() async {
    try {
      await _initPeerConnection();
      final webrtc = ref.read(webrtcServiceProvider);
      final offer = await webrtc.createOffer();
      await webrtc.setLocalDescription(offer);
      ref.read(websocketProvider.notifier).send({
        'type': 'offer',
        'sdp': offer.sdp,
        'to': _peerId,
      });
    } catch (e) {
      debugPrint('❌ Error creating offer: $e');
    }
  }

  Future<void> _initAndSendAnswer(Map<String, dynamic> offerMessage) async {
    try {
      await _initPeerConnection();
      final webrtc = ref.read(webrtcServiceProvider);
      await webrtc.setRemoteDescription(
        RTCSessionDescription(offerMessage['sdp'], offerMessage['type']),
      );
      final answer = await webrtc.createAnswer();
      await webrtc.setLocalDescription(answer);
      ref.read(websocketProvider.notifier).send({
        'type': 'answer',
        'sdp': answer.sdp,
        'to': _peerId,
      });
    } catch (e) {
      debugPrint('❌ Error handling offer and creating answer: $e');
    }
  }

  Future<void> _handleAnswer(Map<String, dynamic> message) async {
    final webrtc = ref.read(webrtcServiceProvider);
    try {
      await webrtc.setRemoteDescription(
        RTCSessionDescription(message['sdp'], message['type']),
      );
    } catch (e) {
      debugPrint('❌ Error handling answer: $e');
    }
  }

  Future<void> _handleCandidate(Map<String, dynamic> message) async {
    final webrtc = ref.read(webrtcServiceProvider);
    try {
      await webrtc.addIceCandidate(
        RTCIceCandidate(
          message['candidate']['candidate'],
          message['candidate']['sdpMid'],
          message['candidate']['sdpMLineIndex'],
        ),
      );
    } catch (e) {
      debugPrint('❌ Error adding ICE candidate: $e');
    }
  }

  void _handleChatMessage(Map<String, dynamic> message) {
    setState(() {
      _messages.insert(0, {'sender': 'peer', 'text': message['message']});
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<WebSocketState>(
      websocketProvider,
      (_, next) => _handleWebSocketState(next),
    );

    return PopScope(
      canPop: !_isChatExpanded, // You can only pop if the chat is NOT expanded
      onPopInvokedWithResult: (bool didPop, k) {
        // This runs *after* the pop attempt.
        if (didPop) return; // If it popped, we're done.
        _textFocusNode.unfocus(); // If it didn't pop, collapse the chat.
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        resizeToAvoidBottomInset: false,

        // Use LayoutBuilder to choose the UI based on screen width
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Define a breakpoint for switching between layouts
            const double desktopBreakpoint = 700.0;
            final bool isDesktop = constraints.maxWidth > desktopBreakpoint;

            if (isDesktop) {
              return _buildDesktopLayout();
            } else {
              return _buildMobileLayout();
            }
          },
        ),
      ),
    );
  }

  /// Builds the UI for wide screens (Desktop).
  Widget _buildDesktopLayout() {
    final webrtc = ref.watch(webrtcServiceProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Row(
        children: [
          // Video section on the left
          SizedBox(
            width: screenWidth * 0.4, // Take up 40% of the screen width
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: VideoContainer(
                      label: 'Remote Video',
                      borderColor: AppTheme.errorColor,
                      isLoading: _isConnecting,
                      loadingText: 'Searching...',
                      child: RTCVideoView(
                        webrtc.remoteRenderer,
                        objectFit: RTCVideoViewObjectFit
                            .RTCVideoViewObjectFitContain, // Fit inside container
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: VideoContainer(
                      label: 'Local Video',
                      borderColor: AppTheme.successColor,
                      child: webrtc.isVideoReady
                          ? RTCVideoView(
                              webrtc.localRenderer,
                              mirror: true,
                              objectFit: RTCVideoViewObjectFit
                                  .RTCVideoViewObjectFitContain, // Fit inside container
                            )
                          : const _NoCameraView(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Chat and Controls section on the right
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Expanded(
                  // This is the permanent chat area for desktop
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: BigScreenChatWidget(
                      messages: _messages,
                      controller: _textController,
                      focusNode: _textFocusNode,
                      onSend: _sendMessage,
                    ),
                  ),
                ),
                // Controls are at the bottom of the chat column
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ControlsWidget(
                    isMuted: _isMuted,
                    isCameraOn: _isCameraOn,
                    onMuteToggle: _toggleMute,
                    onCameraToggle: _toggleCamera,
                    onNext: _findNewPartner,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the UI for narrow screens (Mobile).
  Widget _buildMobileLayout() {
    final webrtc = ref.watch(webrtcServiceProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    final screenSize = MediaQuery.of(context).size;
    final safeArea = MediaQuery.of(context).padding;

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;

    final collapsedChatHeight = 200.0;
    final availableHeight =
        screenSize.height - (keyboardHeight + safeArea.top + safeArea.bottom);
    final expandedChatHeight = availableHeight - 120;

    return GestureDetector(
      onTap: () {
        if (_isChatExpanded) {
          _textFocusNode.unfocus();
          setState(() => _isChatExpanded = false);
        }
      },
      child: GestureDetector(
        onTap: () => _textFocusNode.unfocus(),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // --- Video Area ---
              // On mobile, we stack videos for a picture-in-picture effect
              Positioned.fill(
                bottom: screenHeight * .3,
                child: VideoContainer(
                  label: 'Remote Video',
                  borderColor: AppTheme.errorColor,
                  isLoading: _isConnecting,
                  loadingText: 'Searching...',
                  child: RTCVideoView(
                    webrtc.remoteRenderer,
                    objectFit: RTCVideoViewObjectFit
                        .RTCVideoViewObjectFitContain, // Fit inside container
                  ),
                ),
              ),
              // Local video as a small overlay
              Positioned(
                left: _pipOffset.dx,
                top: _pipOffset.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      // Get the size of the PIP widget
                      final pipSize = _pipKey.currentContext!.size!;
                      // Calculate new offset and clamp it to screen bounds
                      double newDx = (_pipOffset.dx + details.delta.dx).clamp(
                        0.0,
                        screenSize.width - pipSize.width,
                      );
                      double newDy = (_pipOffset.dy + details.delta.dy).clamp(
                        safeArea.top,
                        screenSize.height - pipSize.height - safeArea.bottom,
                      );
                      _pipOffset = Offset(newDx, newDy);
                    });
                  },
                  child: SizedBox(
                    key: _pipKey,
                    width: 120,
                    height: 160,
                    child: VideoContainer(
                      label: 'You',
                      borderColor: AppTheme.successColor,
                      child: webrtc.isVideoReady
                          ? RTCVideoView(
                              webrtc.localRenderer,
                              mirror: true,
                              objectFit: RTCVideoViewObjectFit
                                  .RTCVideoViewObjectFitContain,
                            )
                          : const _NoCameraView(),
                    ),
                  ),
                ),
              ),

              // NEW: Keyboard-aware Animated Chat Box
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                bottom: isKeyboardOpen ? keyboardHeight : 100.0,
                left: 16,
                right: 16,
                height: isKeyboardOpen
                    ? expandedChatHeight
                    : collapsedChatHeight,
                child: FloatingChatWidget(
                  messages: _messages,
                  controller: _textController,
                  focusNode: _textFocusNode,
                  onSend: _sendMessage,
                  isExpanded: _isChatExpanded || isKeyboardOpen,
                ),
              ),

              // --- Controls Area ---
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: ControlsWidget(
                  isMuted: _isMuted,
                  isCameraOn: _isCameraOn,
                  onMuteToggle: _toggleMute,
                  onCameraToggle: _toggleCamera,
                  onNext: _findNewPartner,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoCameraView extends StatelessWidget {
  const _NoCameraView();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.cardDark,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off, color: AppTheme.textMuted, size: 48),
            SizedBox(height: 8),
            Text(
              'Camera not available',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
