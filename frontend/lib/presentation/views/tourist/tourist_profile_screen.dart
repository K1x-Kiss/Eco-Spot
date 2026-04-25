import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/domain/providers/user_provider.dart';
import 'package:frontend/domain/providers/secure_storage_provider.dart';
import 'package:frontend/presentation/widgets/tourist_sidebar.dart';
import 'package:frontend/presentation/widgets/tourist_bottom_nav.dart';
import 'package:frontend/util/location.dart';
import 'package:frontend/util/cities.dart';

class TouristProfileScreen extends StatefulWidget {
  const TouristProfileScreen({super.key});

  @override
  State<TouristProfileScreen> createState() => _TouristProfileScreenState();
}

class _TouristProfileScreenState extends State<TouristProfileScreen> {
  late UserProvider _userProvider;
  int _currentNavIndex = 3;

  @override
  void initState() {
    super.initState();
    _userProvider = UserProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUser();
    });
  }

  Future<void> _loadUser() async {
    final secureStorage = context.read<SecureStorageProvider>();
    final token = await secureStorage.read('token');
    if (token != null) {
      await _userProvider.loadUser(token);
    }
  }

  Future<void> _updateLocation() async {
    final secureStorage = context.read<SecureStorageProvider>();
    
    final position = await LocationUtils.getCurrentPosition();
    if (position == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to get location. Please enable GPS.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    debugPrint('Profile Location: lat=${position.latitude}, lng=${position.longitude}');

    final currentLocation = LocationUtils.getNearestCity(position.latitude, position.longitude);
    if (currentLocation == null) {
      return;
    }

    debugPrint('Profile Location: city=${currentLocation['city']}, country=${currentLocation['country']}');

    await secureStorage.writeLocation(
      currentLocation['city']!,
      currentLocation['country']!,
    );

    final token = await secureStorage.read('token');
    if (token != null) {
      await _userProvider.updateLocation(
        token,
        currentLocation['city']!,
        currentLocation['country']!,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Location updated to ${currentLocation['city']}, ${currentLocation['country']}',
            ),
            backgroundColor: const Color(0xFFFF385C),
          ),
        );
      }
    }
  }

  Future<void> _showCityPicker() async {
    String? selectedCity;
    String? selectedCountry;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setSheetState) {
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select City',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: CityData.countryList.length,
                        itemBuilder: (context, countryIndex) {
                          final country = CityData.countryList[countryIndex];
                          final cities = CityData.getCitiesForCountry(country);
                          return ExpansionTile(
                            title: Text(country),
                            children: cities.map((city) {
                              return ListTile(
                                title: Text(city.replaceAll('_', ' ')),
                                onTap: () {
                                  selectedCity = city;
                                  selectedCountry = country;
                                  Navigator.pop(context);
                                },
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );

    if (selectedCity != null && selectedCountry != null) {
      await _saveManualLocation(selectedCity!, selectedCountry!);
    }
  }

  Future<void> _saveManualLocation(String city, String country) async {
    final secureStorage = context.read<SecureStorageProvider>();
    await secureStorage.writeLocation(city, country);

    final token = await secureStorage.read('token');
    if (token != null) {
      await _userProvider.updateLocation(token, city, country);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location updated to $city, $country'),
            backgroundColor: const Color(0xFFFF385C),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _userProvider,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          title: const Text(
            'Profile',
            style: TextStyle(
              color: Color(0xFFFF385C),
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: const Color(0xFFFF385C),
          actions: [
              IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: _updateLocation,
              ),
              const Icon(Icons.notifications),
            ],
        ),
        drawer: const TouristSidebar(),
        body: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            if (userProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF385C)),
              );
            }

            if (userProvider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${userProvider.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadUser,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final user = userProvider.user;
            if (user == null) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF385C)),
              );
            }

            return RefreshIndicator(
              onRefresh: _loadUser,
              color: const Color(0xFFFF385C),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFFFF385C),
                        child: Text(
                          '${user.name.isNotEmpty ? user.name[0] : ''}${user.surname.isNotEmpty ? user.surname[0] : ''}',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        '${user.name} ${user.surname}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF385C).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.rol,
                          style: const TextStyle(
                            color: Color(0xFFFF385C),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Account Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(Icons.email, 'Email', user.email),
                            const Divider(),
                            _buildInfoRow(
                              Icons.location_on,
                              'Current City',
                              user.currentCity ?? 'Not set',
                              showEdit: true,
                              onEdit: _showCityPicker,
                            ),
                            const Divider(),
                            _buildInfoRow(
                              Icons.flag,
                              'Current Country',
                              user.currentCountry ?? 'Not set',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: TouristBottomNav(
          currentIndex: _currentNavIndex,
          onTap: (index) {
            setState(() {
              _currentNavIndex = index;
            });
            if (index == 0) {
              Navigator.pushReplacementNamed(context, 'tourist_home');
            } else if (index == 1) {
              Navigator.pushNamed(context, 'tourist_search');
            } else if (index == 2) {
              Navigator.pushNamed(context, 'tourist_reservations');
            }
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool showEdit = false, VoidCallback? onEdit}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          if (showEdit && onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: onEdit,
              color: const Color(0xFFFF385C),
            ),
        ],
      ),
    );
  }
}