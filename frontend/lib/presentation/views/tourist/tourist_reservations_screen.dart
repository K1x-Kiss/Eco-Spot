import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/domain/models/rental.dart';
import 'package:frontend/domain/providers/tourist_provider.dart';
import 'package:frontend/domain/providers/secure_storage_provider.dart';
import 'package:frontend/presentation/widgets/tourist_sidebar.dart';
import 'package:frontend/presentation/widgets/tourist_bottom_nav.dart';

class TouristReservationsScreen extends StatefulWidget {
  const TouristReservationsScreen({super.key});

  @override
  State<TouristReservationsScreen> createState() =>
      _TouristReservationsScreenState();
}

class _TouristReservationsScreenState extends State<TouristReservationsScreen> {
  late TouristProvider _touristProvider;
  int _currentNavIndex = 2;
  bool _showUpcoming = true;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _touristProvider = TouristProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReservations();
    });
  }

  Future<void> _loadReservations() async {
    final secureStorage = context.read<SecureStorageProvider>();
    final token = await secureStorage.read('token');
    if (token != null) {
      _hasSearched = true;
      await _touristProvider.loadUserReservations(
        token,
        upcoming: _showUpcoming,
      );
    }
  }

  void _toggleUpcoming() {
    setState(() {
      _showUpcoming = !_showUpcoming;
    });
    _loadReservations();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _touristProvider,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          title: const Text(
            'Reservations',
            style: TextStyle(
              color: Color(0xFFFF385C),
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: const Color(0xFFFF385C),
          actions: const [Icon(Icons.notifications)],
        ),
        drawer: const TouristSidebar(),
        body: Column(
          children: [
            _buildFilterToggle(),
            Expanded(child: _buildReservationsList()),
          ],
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
            } else if (index == 3) {
              Navigator.pushNamed(context, 'tourist_profile');
            }
          },
        ),
      ),
    );
  }

  Widget _buildFilterToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilterChip(
            label: const Text('Upcoming'),
            selected: _showUpcoming,
            onSelected: (_) => _toggleUpcoming(),
            selectedColor: const Color(0xFFFF385C).withValues(alpha: 0.2),
            checkmarkColor: const Color(0xFFFF385C),
            labelStyle: TextStyle(
              color: _showUpcoming
                  ? const Color(0xFFFF385C)
                  : Colors.grey[700],
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Past'),
            selected: !_showUpcoming,
            onSelected: (_) => _toggleUpcoming(),
            selectedColor: const Color(0xFFFF385C).withValues(alpha: 0.2),
            checkmarkColor: const Color(0xFFFF385C),
            labelStyle: TextStyle(
              color: !_showUpcoming
                  ? const Color(0xFFFF385C)
                  : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationsList() {
    return Consumer<TouristProvider>(
      builder: (context, touristProvider, child) {
        if (touristProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF385C)),
          );
        }

        final reservations = touristProvider.userReservations;

        if (!_hasSearched) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF385C)),
          );
        }

        if (reservations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  _showUpcoming
                      ? 'No upcoming reservations'
                      : 'No past reservations',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadReservations,
          color: const Color(0xFFFF385C),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              return _buildReservationCard(reservations[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildReservationCard(Map<String, dynamic> item) {
    final name = item['name'] ?? 'Unknown';
    final city = item['city'] ?? '';
    final country = item['country'] ?? '';
    final valueNight = (item['valueNight'] as num?)?.toDouble() ?? 0.0;
    final images = item['images'] as List<dynamic>? ?? [];
    String? imageUrl;

    if (images.isNotEmpty) {
      final firstImage = images.first;
      if (firstImage is Map<String, dynamic>) {
        imageUrl =
            "http://10.0.2.2:8080/images/${firstImage['id']}.${firstImage['extension']}";
      } else if (firstImage is Rental) {
        imageUrl =
            firstImage.images.isNotEmpty ? firstImage.images.first.imageUrl : null;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl != null)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 48),
                  );
                },
              ),
            )
          else
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                height: 150,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 48),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '$city, $country',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                if (valueNight > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    '\$${valueNight.toStringAsFixed(0)}/night',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF385C),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}