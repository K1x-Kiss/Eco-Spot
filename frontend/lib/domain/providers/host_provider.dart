import 'package:flutter/foundation.dart';
import 'package:frontend/data/repository_implementations/host_repository.dart';
import 'package:frontend/domain/models/rental.dart';
import 'package:frontend/domain/models/reservation.dart';

class HostProvider extends ChangeNotifier {
  final HostRepository _hostRepository = HostRepository();

  List<Rental> _rentals = [];
  List<Reservation> _reservations = [];
  bool _isLoading = false;
  String? _error;

  List<Rental> get rentals => _rentals;
  List<Reservation> get reservations => _reservations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRentals(String token, {bool includeDisabled = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _rentals = await _hostRepository.getRentals(
        token: token,
        includeDisabled: includeDisabled,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleRentalEnable(String token, String rentalId, bool enabled) async {
    try {
      final success = await _hostRepository.toggleRentalEnable(
        token: token,
        rentalId: rentalId,
        enabled: enabled,
      );

      if (success) {
        final index = _rentals.indexWhere((r) => r.id == rentalId);
        if (index != -1) {
          final oldRental = _rentals[index];
          _rentals[index] = Rental(
            id: oldRental.id,
            name: oldRental.name,
            description: oldRental.description,
            contact: oldRental.contact,
            size: oldRental.size,
            peopleQuantity: oldRental.peopleQuantity,
            rooms: oldRental.rooms,
            bathrooms: oldRental.bathrooms,
            city: oldRental.city,
            country: oldRental.country,
            location: oldRental.location,
            valueNight: oldRental.valueNight,
            isEnable: enabled,
            reviewAverage: oldRental.reviewAverage,
            images: oldRental.images,
          );
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> deleteRental(String token, String rentalId) async {
    try {
      final success = await _hostRepository.deleteRental(
        token: token,
        rentalId: rentalId,
      );

      if (success) {
        _rentals.removeWhere((r) => r.id == rentalId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> loadReservations(String token, String rentalId, {bool upcoming = true}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reservations = await _hostRepository.getReservations(
        token: token,
        rentalId: rentalId,
        upcoming: upcoming,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelReservation(String token, String reservationId) async {
    try {
      final success = await _hostRepository.cancelReservation(
        token: token,
        reservationId: reservationId,
      );

      if (success) {
        _reservations.removeWhere((r) => r.id == reservationId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}