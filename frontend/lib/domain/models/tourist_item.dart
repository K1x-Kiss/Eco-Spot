import 'package:frontend/domain/models/rental.dart';

class TouristItem {
  final List<Rental> rentals;
  final List<Map<String, dynamic>> businesses;
  final List<Map<String, dynamic>> experiences;

  TouristItem({
    required this.rentals,
    required this.businesses,
    required this.experiences,
  });

  factory TouristItem.fromJson(Map<String, dynamic> json) {
    return TouristItem(
      rentals:
          (json['rentals'] as List<dynamic>?)
              ?.map((e) => Rental.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      businesses:
          (json['businesses'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      experiences:
          (json['experiences'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }
}

class SearchResult {
  final List<Map<String, dynamic>> results;

  SearchResult({required this.results});

  factory SearchResult.fromJson(dynamic json) {
    if (json is List) {
      return SearchResult(
        results: json.map((e) => e as Map<String, dynamic>).toList(),
      );
    }
    if (json is Map<String, dynamic>) {
      return SearchResult(
        results:
            (json['results'] as List<dynamic>?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
                [],
      );
    }
    return SearchResult(results: []);
  }
}

