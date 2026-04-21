import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:frontend/domain/models/rental.dart';
import 'package:frontend/domain/providers/secure_storage_provider.dart';
import 'package:frontend/domain/providers/rental_form_provider.dart';

class RentalFormScreen extends StatefulWidget {
  final Rental? rental;

  const RentalFormScreen({super.key, this.rental});

  @override
  State<RentalFormScreen> createState() => _RentalFormScreenState();
}

class _RentalFormScreenState extends State<RentalFormScreen> {
  late RentalFormProvider _formProvider;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _formProvider = RentalFormProvider();
    if (widget.rental != null) {
      _formProvider.initForEdit(widget.rental!);
    } else {
      _formProvider.initForCreate();
    }
  }

  @override
  void dispose() {
    _formProvider.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final secureStorage = context.read<SecureStorageProvider>();
      final token = await secureStorage.read('token');
      if (token != null) {
        final success = await _formProvider.submit(token);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_formProvider.isEditMode
                  ? 'Property updated successfully!'
                  : 'Property created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else if (_formProvider.error != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_formProvider.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _formProvider,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          title: Text(
            _formProvider.isEditMode ? 'Edit Property' : 'Add Property',
            style: const TextStyle(
              color: Color(0xFFFF385C),
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: const Color(0xFFFF385C),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Consumer<RentalFormProvider>(
          builder: (context, formProvider, child) {
            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSection(
                    title: 'Basic Information',
                    children: [
                      _buildTextField(
                        controller: formProvider.nameController,
                        label: 'Property Name',
                        hint: 'e.g., Beach House',
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: formProvider.descriptionController,
                        label: 'Description',
                        hint: 'Describe your property...',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: formProvider.contactController,
                        label: 'Contact Phone',
                        hint: 'e.g., +1234567890',
                        keyboardType: TextInputType.phone,
                        required: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Capacity',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: formProvider.sizeController,
                              label: 'Size (m²)',
                              hint: 'e.g., 100',
                              keyboardType: TextInputType.number,
                              required: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: formProvider.peopleQuantityController,
                              label: 'Guests',
                              hint: 'e.g., 4',
                              keyboardType: TextInputType.number,
                              required: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: formProvider.roomsController,
                              label: 'Bedrooms',
                              hint: 'e.g., 2',
                              keyboardType: TextInputType.number,
                              required: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: formProvider.bathroomsController,
                              label: 'Bathrooms',
                              hint: 'e.g., 1',
                              keyboardType: TextInputType.number,
                              required: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Location',
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: formProvider.selectedCountry,
                        decoration: const InputDecoration(
                          labelText: 'Country',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: RentalFormProvider.countryList.map((country) {
                          return DropdownMenuItem(
                            value: country,
                            child: Text(country),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            formProvider.setCountry(value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: formProvider.selectedCity,
                        decoration: const InputDecoration(
                          labelText: 'City',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: formProvider.citiesForSelectedCountry.map((city) {
                          return DropdownMenuItem(
                            value: city,
                            child: Text(city),
                          );
                        }).toList(),
                        onChanged: (value) {
                          // Value is set via country change
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: formProvider.locationController,
                        label: 'Address',
                        hint: 'e.g., 123 Beach St',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Pricing',
                    children: [
                      _buildTextField(
                        controller: formProvider.valueNightController,
                        label: 'Price per Night (\$)',
                        hint: 'e.g., 150',
                        keyboardType: TextInputType.number,
                        required: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Images (Max 3)',
                    children: [
                      if (formProvider.images.length < 3)
                        OutlinedButton.icon(
                          onPressed: () async {
                            final image = await _pickImage();
                            if (image != null) {
                              formProvider.addImage(image);
                            }
                          },
                          icon: const Icon(Icons.add_photo_alternate),
                          label: const Text('Add Image'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFF385C),
                          ),
                        ),
                      const SizedBox(height: 8),
                      if (formProvider.images.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(
                            formProvider.images.length,
                            (index) => Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.image,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: GestureDetector(
                                    onTap: () => formProvider.removeImage(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: formProvider.isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF385C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: formProvider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : Text(
                              formProvider.isEditMode
                                  ? 'Update Property'
                                  : 'Create Property',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF385C),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    bool required = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
      ),
      validator: required
          ? (value) {
              if (value == null || value.isEmpty) {
                return '$label is required';
              }
              return null;
            }
          : null,
    );
  }

  Future<File?> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }
}