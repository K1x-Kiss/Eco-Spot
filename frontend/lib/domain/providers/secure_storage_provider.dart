import 'package:flutter/foundation.dart';
import 'package:frontend/data/secure_storage.dart';

class SecureStorageProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  static const String keyDetectedCity = 'detectedCity';
  static const String keyDetectedCountry = 'detectedCountry';

  Future<void> write(String key, String value) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await SecureStorage.write(key, value);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> writeLocation(String city, String country) async {
    await write(keyDetectedCity, city);
    await write(keyDetectedCountry, country);
  }

  Future<String?> readDetectedCity() async {
    return read(keyDetectedCity);
  }

  Future<String?> readDetectedCountry() async {
    return read(keyDetectedCountry);
  }

  Future<Map<String, String>?> readLocation() async {
    final city = await readDetectedCity();
    final country = await readDetectedCountry();
    if (city != null && country != null) {
      return {'city': city, 'country': country};
    }
    return null;
  }

  Future<String?> read(String key) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await SecureStorage.read(key);
      return result;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await SecureStorage.deleteAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}