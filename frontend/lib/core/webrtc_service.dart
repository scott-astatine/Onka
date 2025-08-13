import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io' show Platform;

class WebRTCService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  RTCVideoRenderer localRenderer = RTCVideoRenderer();
  RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  // Getter for local stream
  MediaStream? get localStream => _localStream;

  // Check if video is ready
  bool get isVideoReady =>
      _localStream != null && _localStream!.getVideoTracks().isNotEmpty;

  // Check if the service is properly initialized
  bool _initialized = false;
  bool get isInitialized => _initialized;

  // Force refresh the video renderer
  void refreshVideoRenderer() {
    if (_localStream != null) {
      // Clear the renderer first
      localRenderer.srcObject = null;

      // Re-set the stream on the main thread after a short delay
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (_localStream != null) {
            localRenderer.srcObject = _localStream;
          }
        });
      });
    }
  }

  Future<void> initRenderers() async {
    try {
      await localRenderer.initialize();
      await remoteRenderer.initialize();
      _initialized = true;
      debugPrint('Video renderers initialized successfully');
    } catch (e) {
      debugPrint('Error initializing renderers: $e');
      _initialized = false;
      rethrow;
    }
  }

  Future<void> getUserMedia() async {
    try {
      // Request permissions first
      await _requestPermissions();

      // First try with video constraints
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {
          'facingMode': 'user',
          'width': {'ideal': 640, 'min': 320},
          'height': {'ideal': 480, 'min': 240},
          'frameRate': {'ideal': 30, 'min': 15},
        },
      });

      // Set the stream to renderer on the main thread
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_localStream != null) {
          localRenderer.srcObject = _localStream;
        }
      });

      debugPrint(
        'Local stream obtained: ${_localStream?.getVideoTracks().length} video tracks',
      );
    } catch (e) {
      debugPrint('Error getting user media: $e');
      // Try with audio only if video fails
      try {
        _localStream = await navigator.mediaDevices.getUserMedia({
          'audio': true,
          'video': false,
        });
        debugPrint('Fallback to audio-only stream');
      } catch (audioError) {
        debugPrint('Error getting audio-only stream: $audioError');
        rethrow;
      }
    }
  }

  /// Request camera and microphone permissions
  Future<void> _requestPermissions() async {
    // Skip permission requests on desktop/web platforms
    if (kIsWeb || Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      debugPrint('Skipping permission request on desktop/web platform');
      return;
    }

    // On mobile platforms, permissions will be requested by the system
    // when getUserMedia is called, so we don't need to handle them explicitly here
    debugPrint('Permission request skipped - will be handled by system');
  }

  Future<void> initPeerConnection(Map<String, dynamic> config) async {
    _peerConnection = await createPeerConnection(config);
    _peerConnection?.onTrack = (event) {
      if (event.track.kind == 'video') {
        _remoteStream = event.streams[0];
        remoteRenderer.srcObject = _remoteStream;
      }
    };
    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });
  }

  Future<RTCSessionDescription> createOffer() async {
    return await _peerConnection!.createOffer();
  }

  Future<void> setLocalDescription(RTCSessionDescription desc) async {
    await _peerConnection!.setLocalDescription(desc);
  }

  Future<void> setRemoteDescription(RTCSessionDescription desc) async {
    await _peerConnection!.setRemoteDescription(desc);
  }

  Future<RTCSessionDescription> createAnswer() async {
    return await _peerConnection!.createAnswer();
  }

  Future<void> addIceCandidate(RTCIceCandidate candidate) async {
    await _peerConnection!.addCandidate(candidate);
  }

  void close() {
    try {
      // Stop all tracks in the local stream
      _localStream?.getTracks().forEach((track) {
        track.stop();
      });

      // Close peer connection
      _peerConnection?.close();

      // Clear renderers
      localRenderer.srcObject = null;
      remoteRenderer.srcObject = null;

      // Dispose renderers
      localRenderer.dispose();
      remoteRenderer.dispose();

      // Clear streams
      _localStream = null;
      _remoteStream = null;
      _peerConnection = null;
      _initialized = false;

      debugPrint('WebRTC service closed successfully');
    } catch (e) {
      debugPrint('Error closing WebRTC service: $e');
    }
  }
}
