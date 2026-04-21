import 'dart:convert';
import 'dart:io';
import 'package:frontend/domain/models/rental.dart';
import 'package:frontend/domain/models/reservation.dart';
import 'package:frontend/domain/repository_interfaces/host_interface.dart';
import 'package:http/http.dart' as http;

class HostRepository implements HostInterface {
  final String baseUrl = 'http://10.0.2.2:8080/api/v1/host';
  final http.Client _client = http.Client();

  Map<String, String> _headers(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  String _getMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }

  @override
  Future<Rental?> createRental({
    required String token,
    required String name,
    String? description,
    required String contact,
    required int size,
    required int peopleQuantity,
    required int rooms,
    required int bathrooms,
    required String city,
    required String country,
    String? location,
    required double valueNight,
    List<File>? images,
  }) async {
    final uri = Uri.parse('$baseUrl/rentals');
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll({'Authorization': 'Bearer $token'});
    request.fields.addAll({
      'name': name,
      'description': description ?? '',
      'contact': contact,
      'size': size.toString(),
      'peopleQuantity': peopleQuantity.toString(),
      'rooms': rooms.toString(),
      'bathrooms': bathrooms.toString(),
      'city': city,
      'country': country,
      'location': location ?? '',
      'valueNight': valueNight.toString(),
    });

    if (images != null) {
      for (final image in images) {
        final bytes = await image.readAsBytes();
        final contentType = http.MediaType.parse(_getMimeType(image.path));
        request.files.add(
          http.MultipartFile.fromBytes(
            'images',
            bytes,
            filename: image.path.split('/').last,
            contentType: contentType,
          ),
        );
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    // Server returns 201 with empty body on success
    if (response.statusCode == 201) {
      return Rental(
        id: '',
        name: name,
        description: description,
        contact: contact,
        size: size,
        peopleQuantity: peopleQuantity,
        rooms: rooms,
        bathrooms: bathrooms,
        city: city,
        country: country,
        location: location,
        valueNight: valueNight,
        isEnable: true,
        reviewAverage: 0.0,
        images: [],
      );
    }
    return null;
  }

  @override
  Future<Rental?> updateRental({
    required String token,
    required String rentalId,
    required String name,
    String? description,
    required String contact,
    required int size,
    required int peopleQuantity,
    required int rooms,
    required int bathrooms,
    required String city,
    required String country,
    String? location,
    required double valueNight,
    List<File>? images,
  }) async {
    final uri = Uri.parse('$baseUrl/rentals/$rentalId');
    final request = http.MultipartRequest('PUT', uri);

    request.headers.addAll({'Authorization': 'Bearer $token'});
    request.fields.addAll({
      'name': name,
      'description': description ?? '',
      'contact': contact,
      'size': size.toString(),
      'peopleQuantity': peopleQuantity.toString(),
      'rooms': rooms.toString(),
      'bathrooms': bathrooms.toString(),
      'city': city,
      'country': country,
      'location': location ?? '',
      'valueNight': valueNight.toString(),
    });

    if (images != null) {
      for (final image in images) {
        final bytes = await image.readAsBytes();
        final contentType = http.MediaType.parse(_getMimeType(image.path));
        request.files.add(
          http.MultipartFile.fromBytes(
            'images',
            bytes,
            filename: image.path.split('/').last,
            contentType: contentType,
          ),
        );
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    // Server returns 200 with empty body on success
    if (response.statusCode == 200) {
      return Rental(
        id: rentalId,
        name: name,
        description: description,
        contact: contact,
        size: size,
        peopleQuantity: peopleQuantity,
        rooms: rooms,
        bathrooms: bathrooms,
        city: city,
        country: country,
        location: location,
        valueNight: valueNight,
        isEnable: true,
        reviewAverage: 0.0,
        images: [],
      );
    }
    return null;
  }

  @override
  Future<bool> deleteRental({
    required String token,
    required String rentalId,
  }) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/rentals/$rentalId'),
      headers: _headers(token),
    );

    return response.statusCode == 200;
  }

  @override
  Future<List<Rental>> getRentals({
    required String token,
    bool includeDisabled = false,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/rentals',
    ).replace(queryParameters: {'includeDisabled': includeDisabled.toString()});

    final response = await _client.get(uri, headers: _headers(token));

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((e) => Rental.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<bool> toggleRentalEnable({
    required String token,
    required String rentalId,
    required bool enabled,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/rentals/$rentalId/enable',
    ).replace(queryParameters: {'enabled': enabled.toString()});

    final response = await _client.patch(uri, headers: _headers(token));

    return response.statusCode == 200;
  }

  @override
  Future<List<Reservation>> getReservations({
    required String token,
    required String rentalId,
    bool upcoming = true,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/rentals/$rentalId/reservations',
    ).replace(queryParameters: {'upcoming': upcoming.toString()});

    final response = await _client.get(uri, headers: _headers(token));

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((e) => Reservation.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<bool> cancelReservation({
    required String token,
    required String reservationId,
  }) async {
    final response = await _client.patch(
      Uri.parse('$baseUrl/reservations/$reservationId/cancel'),
      headers: _headers(token),
    );

    return response.statusCode == 200;
  }
}

