import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/domain/models/reservation.dart';
import 'package:frontend/domain/providers/host_provider.dart';
import 'package:frontend/domain/providers/secure_storage_provider.dart';

class ReservationsScreen extends StatefulWidget {
  final String rentalId;
  final String rentalName;

  const ReservationsScreen({
    super.key,
    required this.rentalId,
    required this.rentalName,
  });

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  late HostProvider _hostProvider;
  bool _showUpcoming = true;

  @override
  void initState() {
    super.initState();
    _hostProvider = HostProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReservations();
    });
  }

  Future<void> _loadReservations() async {
    final secureStorage = context.read<SecureStorageProvider>();
    final token = await secureStorage.read('token');
    if (token != null) {
      await _hostProvider.loadReservations(
        token,
        widget.rentalId,
        upcoming: _showUpcoming,
      );
    }
  }

  void _toggleFilter() {
    setState(() {
      _showUpcoming = !_showUpcoming;
    });
    _loadReservations();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _hostProvider,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          title: Text(
            widget.rentalName,
            style: const TextStyle(
              color: Color(0xFFFF385C),
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: const Color(0xFFFF385C),
        ),
        body: Consumer<HostProvider>(
          builder: (context, hostProvider, child) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilterChip(
                        label: Text(_showUpcoming ? 'Upcoming' : 'Past'),
                        selected: _showUpcoming,
                        onSelected: (_) => _toggleFilter(),
                        selectedColor: const Color(0xFFFF385C).withValues(alpha: 0.2),
                        checkmarkColor: const Color(0xFFFF385C),
                        labelStyle: TextStyle(
                          color: _showUpcoming
                              ? const Color(0xFFFF385C)
                              : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildReservationsList(hostProvider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildReservationsList(HostProvider hostProvider) {
    if (hostProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF385C)),
      );
    }

    if (hostProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${hostProvider.error}',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadReservations,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (hostProvider.reservations.isEmpty) {
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
              _showUpcoming ? 'No upcoming reservations' : 'No past reservations',
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
        itemCount: hostProvider.reservations.length,
        itemBuilder: (context, index) {
          final reservation = hostProvider.reservations[index];
          return GestureDetector(
            onLongPress: _showUpcoming && !reservation.isCancelled
                ? () => _cancelReservation(context, reservation, hostProvider)
                : null,
            child: _ReservationCard(reservation: reservation),
          );
        },
      ),
    );
  }

  Future<void> _cancelReservation(
    BuildContext context,
    Reservation reservation,
    HostProvider hostProvider,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Reservation'),
        content: Text(
          'Are you sure you want to cancel the reservation for ${reservation.userName} ${reservation.userSurname}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final secureStorage = context.read<SecureStorageProvider>();
      final token = await secureStorage.read('token');
      if (token != null && context.mounted) {
        final success = await hostProvider.cancelReservation(token, reservation.id);
        if (!success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(hostProvider.error ?? 'Failed to cancel reservation'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reservation cancelled'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }
}

class _ReservationCard extends StatelessWidget {
  final Reservation reservation;

  const _ReservationCard({required this.reservation});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reservation #${reservation.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: reservation.isCancelled
                        ? Colors.red[100]
                        : Colors.green[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    reservation.isCancelled ? 'Cancelled' : 'Confirmed',
                    style: TextStyle(
                      color: reservation.isCancelled ? Colors.red : Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${reservation.userName} ${reservation.userSurname}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${reservation.startingDate} - ${reservation.endDate}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}