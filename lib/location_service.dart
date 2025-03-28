import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';


class LocationService {
  /// Request both foreground and background location permissions
  static Future<void> requestLocationPermission() async {
    // Request foreground permission
    var status = await Permission.location.request();

    if (status.isGranted) {
      // Check background location permission
      var backgroundStatus = await Permission.locationAlways.status;

      if (!backgroundStatus.isGranted) {
        backgroundStatus = await Permission.locationAlways.request();
      }

      if (backgroundStatus.isGranted) {
        debugPrint("Background Location Permission Granted");
      } else {
        debugPrint("Background Location Permission Denied");

      }
    } else if (status.isDenied) {
      debugPrint("Location Permission Denied");
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  static Future<bool> checkLocationPermission() async {
    // Check foreground location permission
    final foregroundStatus = await Permission.location.status;

    // Check background location permission
    final backgroundStatus = await Permission.locationAlways.status;

    // Return true only if both permissions are granted
    return foregroundStatus.isGranted && backgroundStatus.isGranted;
  }


}
