import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/data/repository_implementations/host_repository.dart';
import 'package:frontend/domain/models/rental.dart';
import 'package:frontend/util/cities.dart';

class RentalFormProvider extends ChangeNotifier {
  final HostRepository _hostRepository = HostRepository();

  bool isEditMode = false;
  String? rentalId;
  bool isLoading = false;
  String? error;
  List<File> images = [];

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final contactController = TextEditingController();
  final sizeController = TextEditingController();
  final peopleQuantityController = TextEditingController();
  final roomsController = TextEditingController();
  final bathroomsController = TextEditingController();
  final locationController = TextEditingController();
  final valueNightController = TextEditingController();

  String selectedCity = 'MEDELLIN';
  String selectedCountry = 'COLOMBIA';

  static List<String> get countryList => CityData.countryList;

  List<String> get citiesForSelectedCountry =>
      CityData.getCitiesForCountry(selectedCountry);

  void initForCreate() {
    isEditMode = false;
    rentalId = null;
    _clearControllers();
    selectedCity = 'MEDELLIN';
    selectedCountry = 'COLOMBIA';
    images = [];
    notifyListeners();
  }

  void initForEdit(Rental rental) {
    isEditMode = true;
    rentalId = rental.id;
    nameController.text = rental.name;
    descriptionController.text = rental.description ?? '';
    contactController.text = rental.contact;
    sizeController.text = rental.size.toString();
    peopleQuantityController.text = rental.peopleQuantity.toString();
    roomsController.text = rental.rooms.toString();
    bathroomsController.text = rental.bathrooms.toString();
    locationController.text = rental.location ?? '';
    valueNightController.text = rental.valueNight.toString();
    selectedCity = rental.city;
    selectedCountry = rental.country;
    images = [];
    notifyListeners();
  }

  void _clearControllers() {
    nameController.clear();
    descriptionController.clear();
    contactController.clear();
    sizeController.clear();
    peopleQuantityController.clear();
    roomsController.clear();
    bathroomsController.clear();
    locationController.clear();
    valueNightController.clear();
  }

  void setCountry(String country) {
    selectedCountry = country;
    selectedCity = CityData.getCitiesForCountry(country).firstOrNull ?? 'MEDELLIN';
    notifyListeners();
  }

  void addImage(File image) {
    if (images.length >= 3) return;

    final extension = image.path.split('.').last.toLowerCase();
    final allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

    if (!allowedExtensions.contains(extension)) {
      error = 'Only jpg, png, and webp images are allowed';
      notifyListeners();
      return;
    }

    images.add(image);
    notifyListeners();
  }

  void removeImage(int index) {
    if (index >= 0 && index < images.length) {
      images.removeAt(index);
      notifyListeners();
    }
  }

  Future<bool> submit(String token) async {
    if (nameController.text.isEmpty ||
        contactController.text.isEmpty ||
        sizeController.text.isEmpty ||
        peopleQuantityController.text.isEmpty ||
        roomsController.text.isEmpty ||
        bathroomsController.text.isEmpty ||
        valueNightController.text.isEmpty) {
      error = 'Please fill all required fields';
      notifyListeners();
      return false;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final name = nameController.text;
      final description = descriptionController.text.isEmpty
          ? null
          : descriptionController.text;
      final contact = contactController.text;
      final size = int.tryParse(sizeController.text) ?? 0;
      final peopleQuantity = int.tryParse(peopleQuantityController.text) ?? 0;
      final rooms = int.tryParse(roomsController.text) ?? 0;
      final bathrooms = int.tryParse(bathroomsController.text) ?? 0;
      final location = locationController.text.isEmpty
          ? null
          : locationController.text;
      final valueNight = double.tryParse(valueNightController.text) ?? 0.0;

      bool success;
      if (isEditMode && rentalId != null) {
        final result = await _hostRepository.updateRental(
          token: token,
          rentalId: rentalId!,
          name: name,
          description: description,
          contact: contact,
          size: size,
          peopleQuantity: peopleQuantity,
          rooms: rooms,
          bathrooms: bathrooms,
          city: selectedCity,
          country: selectedCountry,
          location: location,
          valueNight: valueNight,
          images: images.isEmpty ? null : images,
        );
        success = result != null;
      } else {
        final result = await _hostRepository.createRental(
          token: token,
          name: name,
          description: description,
          contact: contact,
          size: size,
          peopleQuantity: peopleQuantity,
          rooms: rooms,
          bathrooms: bathrooms,
          city: selectedCity,
          country: selectedCountry,
          location: location,
          valueNight: valueNight,
          images: images.isEmpty ? null : images,
        );
        success = result != null;
      }

      isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    contactController.dispose();
    sizeController.dispose();
    peopleQuantityController.dispose();
    roomsController.dispose();
    bathroomsController.dispose();
    locationController.dispose();
    valueNightController.dispose();
    super.dispose();
  }
}