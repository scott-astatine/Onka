/// Centralized configuration for the application.
class AppConfig {
  static const String _localIp = '192.168.0.105';
  static const String port = '8080';

  static const String baseUrl = 'http://$_localIp:$port';
  static const String websocketUrl = 'ws://$_localIp:$port';
}
