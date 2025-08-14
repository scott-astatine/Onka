/// Centralized configuration for the application.
class AppConfig {
  // Use this for physical device testing.
  // Replace with your local IP address (find with `ifconfig` or `ipconfig`).
  static const String _localIp = '192.168.0.105';

  // Use this for emulator/simulator testing.
  // static const String _localIp = '10.0.2.2'; // Android emulator
  // static const String _localIp = 'localhost'; // iOS simulator or desktop

  static const String baseUrl = 'http://$_localIp:8000';
  static const String websocketUrl = 'ws://$_localIp:8000';
}
