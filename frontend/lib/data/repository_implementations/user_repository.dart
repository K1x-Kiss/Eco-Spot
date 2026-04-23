import 'dart:convert';
import 'package:frontend/domain/models/user.dart';
import 'package:frontend/domain/repository_interfaces/user_interface.dart';
import 'package:http/http.dart' as http;

class UserRepository implements UserInterface {
  final String baseUrl = 'http://10.0.2.2:8080/api/v1/users';
  final http.Client _client = http.Client();

  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  @override
  Future<User?> getCurrentUser({required String token}) async {
    final uri = Uri.parse('$baseUrl/me');

    final response = await _client.get(uri, headers: _headers(token));

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    return null;
  }

  @override
  Future<bool> updateLocation({
    required String token,
    required String city,
    required String country,
  }) async {
    final uri = Uri.parse('$baseUrl/location');

    final response = await _client.patch(
      uri,
      headers: _headers(token),
      body: jsonEncode({
        'city': city,
        'country': country,
      }),
    );

    return response.statusCode == 200;
  }
}