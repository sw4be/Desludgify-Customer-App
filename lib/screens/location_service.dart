import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'privacy_settings.dart';

class LocationService {
  static const _lastLatitudeKey = 'last_location_latitude';
  static const _lastLongitudeKey = 'last_location_longitude';

  /// Uses the in-app privacy preference for passive map/tracking reads.
  static Future<Position?> getPositionIfAllowed() async {
    final allowedInApp = await PrivacySettings.getShareLocation();
    if (!allowedInApp) return null;

    return getCurrentPosition();
  }

  /// Requests the OS location permission for an explicit geo-tag action.
  static Future<Position?> getCurrentPosition() async {
    final serviceOn = await Geolocator.isLocationServiceEnabled();
    if (!serviceOn) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    late final Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } on TimeoutException {
      final lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition == null) rethrow;
      position = lastKnownPosition;
    }
    await savePosition(position);
    return position;
  }

  static Future<void> savePosition(Position position) async {
    await saveCoordinates(position.latitude, position.longitude);
  }

  static Future<void> saveCoordinates(double latitude, double longitude) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setDouble(_lastLatitudeKey, latitude);
    await preferences.setDouble(_lastLongitudeKey, longitude);
  }

  static Future<({double latitude, double longitude})?>
  getLastPosition() async {
    final preferences = await SharedPreferences.getInstance();
    final latitude = preferences.getDouble(_lastLatitudeKey);
    final longitude = preferences.getDouble(_lastLongitudeKey);
    if (latitude == null || longitude == null) return null;
    return (latitude: latitude, longitude: longitude);
  }

  /// When user turns ON "Share location" in Privacy.
  static Future<bool> requestPermissionFromPrivacy() async {
    final serviceOn = await Geolocator.isLocationServiceEnabled();
    if (!serviceOn) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }
}
