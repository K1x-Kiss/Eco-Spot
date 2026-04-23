import 'package:frontend/domain/models/user.dart';

abstract class UserInterface {
  Future<User?> getCurrentUser({required String token});

  Future<bool> updateLocation({
    required String token,
    required String city,
    required String country,
  });
}

