import 'package:flutter/services.dart';

class HealthConnectPermissions {
  static const MethodChannel _channel =
      MethodChannel('com.yourcompany/health_connect');

  static Future<bool> requestPermissions() async {
    try {
      final bool permissionsGranted =
          await _channel.invokeMethod('requestPermissions');
      return permissionsGranted;
    } on PlatformException catch (e) {
      print("Failed to get permissions: '${e.message}'.");
      return false;
    }
  }
}
