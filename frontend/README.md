# OnKa Frontend (Flutter)

ConnectSphere is a modern, cross-platform Omegle-like video chat application. This directory contains the Flutter frontend for Android, iOS, Linux, and web.

## Features

- **Anonymous Access:** No account required to start chatting.
- **Random Pairing:** Connects you with a random user via the backend.
- **WebRTC Video Chat:** Peer-to-peer video using WebRTC.
- **Text Chat:** Send messages during video calls.
- **Skip/Next:** Instantly disconnect and find a new partner.
- **Reporting:** Report inappropriate users.
- **Modern UI:** Minimalist, beautiful, responsive design with light/dark mode.

## Directory Structure

```
lib/
├── main.dart                # App entry point
├── core/                    # Core services (e.g., webrtc_service.dart)
├── data/                    # Data models (e.g., message.dart)
├── logic/                   # State management (Riverpod providers)
├── presentation/            # UI Layer
│   ├── screens/             # Screens (home_screen.dart, chat_screen.dart)
│   ├── widgets/             # Reusable UI components
│   └── theme.dart           # App theme, colors, fonts
assets/
└── fonts/                   # Inter font files
```

## Key Technologies

- **Flutter 3.x**: Single codebase for Android/iOS/web/Linux
- **Riverpod**: State management
- **flutter_webrtc**: WebRTC video/audio
- **http**: REST API calls

## Setup Instructions

1. **Install Flutter**: [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
2. **Install dependencies:**
   ```
   flutter pub get
   ```
3. **Run the app:**
   ```
   flutter run
   ```
   (Choose your target device: Android/iOS/web/Linux)
4. **Fonts:**
   - Uses the Inter font (see `pubspec.yaml` and `assets/fonts/`).
5. **WebRTC:**
   - For Android/iOS, no extra setup is needed.
   - For web, ensure you use a compatible version of `flutter_webrtc` and follow [flutter-webrtc/web setup](https://pub.dev/packages/flutter_webrtc#web-support).

## Customization

- Update `lib/core/webrtc_service.dart` for custom STUN/TURN servers.
- Theming is in `lib/presentation/theme.dart`.

## Contact

For issues or contributions, see the main project repository.
