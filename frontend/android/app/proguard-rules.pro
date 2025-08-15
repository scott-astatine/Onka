# ProGuard rules for flutter_webrtc
# This prevents R8 from stripping away necessary classes in release builds.
-keep class org.webrtc.** { *; }