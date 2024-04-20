import 'package:flutter/services.dart';

class HealthConnectChecker {
  static const platform =
      MethodChannel('com.yourcompany.healthconnect/availability');

  static Future<bool> isHealthConnectAvailable() async {
    try {
      final bool isAvailable = await platform.invokeMethod('checkAvailability');
      return isAvailable;
    } on PlatformException catch (e) {
      print("Failed to check Health Connect availability: '${e.message}'");
      return false;
    }
  }
}
