import 'dart:developer' as developer;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationHelper {
  // Get current city name using GPS
  static Future<String?> getCurrentCity() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        developer.log('Location services are disabled');
        return null;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          developer.log('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        developer.log('Location permissions are permanently denied');
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      // Reverse geocode to get address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        // Return city name, fallback to locality or subAdministrativeArea
        return placemark.locality ??
            placemark.subAdministrativeArea ??
            placemark.administrativeArea;
      }

      return null;
    } catch (e) {
      developer.log('Error getting location: $e');
      return null;
    }
  }

  // Get a random city for privacy (fallback option)
  static String getRandomCity() {
    final cities = [
      'New York',
      'London',
      'Tokyo',
      'Paris',
      'Sydney',
      'Berlin',
      'Moscow',
      'Toronto',
      'Madrid',
      'Rome',
      'Amsterdam',
      'Vienna',
      'Prague',
      'Warsaw',
      'Stockholm',
      'Copenhagen',
      'Helsinki',
      'Oslo',
      'Dublin',
      'Edinburgh'
    ];
    return cities[DateTime.now().millisecondsSinceEpoch % cities.length];
  }

  // Check if location permission is granted
  static Future<bool> hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  // Request location permission
  static Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }
}
