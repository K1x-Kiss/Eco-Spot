import 'package:geolocator/geolocator.dart';
import 'package:frontend/util/cities.dart';

class LocationUtils {
  static Future<Position?> getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return position;
    } catch (e) {
      return null;
    }
  }

  static Map<String, String>? getNearestCity(
    double latitude,
    double longitude,
  ) {
    String? nearestCity;
    String? nearestCountry;
    double minDistance = double.infinity;

    for (final country in CityData.countryList) {
      for (final cityName in CityData.getCitiesForCountry(country)) {
        final cityCoords = CityData.cityCoordinates[cityName];
        if (cityCoords == null) continue;

        final cityLat = cityCoords['lat']!;
        final cityLng = cityCoords['lng']!;
        final distance = _calculateDistance(
          latitude,
          longitude,
          cityLat,
          cityLng,
        );

        if (distance < minDistance) {
          minDistance = distance;
          nearestCity = cityName;
          nearestCountry = country;
        }
      }
    }

    if (nearestCity == null || nearestCountry == null) {
      return null;
    }

    return {'city': nearestCity, 'country': nearestCountry};
  }

  static double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadius = 6371;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    final a =
        _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(lat1)) *
            _cos(_toRadians(lat2)) *
            _sin(dLng / 2) *
            _sin(dLng / 2);
    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degrees) => degrees * 3.141592653589793 / 180;
  static double _sin(double x) => _taylorSin(x);
  static double _cos(double x) => _taylorCos(x);
  static double _sqrt(double x) => _newtonSqrt(x);
  static double _atan2(double y, double x) => _approxAtan2(y, x);

  static double _taylorSin(double x) {
    x = x % (2 * 3.141592653589793);
    if (x > 3.141592653589793) x -= 2 * 3.141592653589793;
    if (x < -3.141592653589793) x += 2 * 3.141592653589793;
    double result = x;
    double term = x;
    for (int n = 1; n <= 10; n++) {
      term *= -x * x / ((2 * n) * (2 * n + 1));
      result += term;
    }
    return result;
  }

  static double _taylorCos(double x) {
    x = x % (2 * 3.141592653589793);
    if (x > 3.141592653589793) x -= 2 * 3.141592653589793;
    if (x < -3.141592653589793) x += 2 * 3.141592653589793;
    double result = 1;
    double term = 1;
    for (int n = 1; n <= 10; n++) {
      term *= -x * x / ((2 * n - 1) * (2 * n));
      result += term;
    }
    return result;
  }

  static double _newtonSqrt(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 20; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  static double _approxAtan2(double y, double x) {
    if (x == 0) {
      if (y > 0) return 3.141592653589793 / 2;
      if (y < 0) return -3.141592653589793 / 2;
      return 0;
    }
    double atan = _taylorAtan(y / x);
    if (x < 0) {
      if (y >= 0) return atan + 3.141592653589793;
      return atan - 3.141592653589793;
    }
    return atan;
  }

  static double _taylorAtan(double x) {
    if (x.abs() > 1) {
      if (x > 1) return 3.141592653589793 / 2 - _taylorAtan(1 / x);
      return -3.141592653589793 / 2 - _taylorAtan(1 / x);
    }
    double result = x;
    double term = x;
    for (int n = 1; n <= 20; n++) {
      term *= -x * x;
      result += term / (2 * n + 1);
    }
    return result;
  }
}

