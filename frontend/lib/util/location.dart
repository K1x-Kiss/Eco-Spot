import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:frontend/util/cities.dart';

class LocationUtils {
  static Future<bool> checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    debugPrint('[Location] isLocationServiceEnabled: $serviceEnabled');
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    debugPrint('[Location] checkPermission: $permission');
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      debugPrint('[Location] requestPermission result: $permission');
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('[Location] permission denied forever');
      return false;
    }

    return true;
  }

  static Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkPermission();
      if (!hasPermission) {
        debugPrint('[Location] No permission, returning null');
        return null;
      }

      debugPrint('[Location] Getting current position...');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
      debugPrint('[Location] Got position: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('[Location] Error getting position: $e');
      return null;
    }
  }

  static Future<Map<String, String>?> getCurrentCityAndCountry() async {
    final position = await getCurrentPosition();
    if (position == null) {
      debugPrint('[Location] No position, returning null');
      return null;
    }

    final lat = position.latitude;
    final lng = position.longitude;
    debugPrint('[Location] Looking for city near: $lat, $lng');

    String? detectedCountry;
    String? detectedCity;

    for (final country in CityData.countryList) {
      final nearestCity = CityData.findNearestCity(
        lat,
        lng,
        country,
        CityData.cityCoordinates,
      );

      if (nearestCity != null) {
        debugPrint('[Location] Found city $nearestCity in $country');
        detectedCountry = country;
        detectedCity = nearestCity;
        break;
      }
    }

    if (detectedCountry == null) {
      debugPrint('[Location] No matching city found, returning null (no fallback)');
      return null;
    }

    detectedCity ??= CityData.getCitiesForCountry(detectedCountry).first;

    debugPrint('[Location] Final result: city=$detectedCity, country=$detectedCountry');
    return {
      'city': detectedCity,
      'country': detectedCountry,
    };
  }

  static String findNearestCityFromList(
    double latitude,
    double longitude,
    String preferredCountry,
  ) {
    final nearestCity = CityData.findNearestCity(
      latitude,
      longitude,
      preferredCountry,
      CityData.cityCoordinates,
    );

    return nearestCity ?? 'MEDELLIN';
  }
}