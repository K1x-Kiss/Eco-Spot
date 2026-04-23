import 'package:flutter/foundation.dart';
import 'package:frontend/data/repository_implementations/user_repository.dart';
import 'package:frontend/domain/models/user.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> loadUser(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _userRepository.getCurrentUser(token: token);
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateLocation(String token, String city, String country) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _userRepository.updateLocation(
        token: token,
        city: city,
        country: country,
      );
      if (success) {
        _user = User(
          id: _user?.id ?? '',
          name: _user?.name ?? '',
          surname: _user?.surname ?? '',
          email: _user?.email ?? '',
          currentCity: city,
          currentCountry: country,
          rol: _user?.rol ?? '',
        );
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
