import 'package:flutter/material.dart';
import '../models/stand_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/modern_button.dart';
import '../services/location_service.dart';

class StandDetailsScreen extends StatefulWidget {
  const StandDetailsScreen({super.key});

  @override
  State<StandDetailsScreen> createState() => _StandDetailsScreenState();
}

class _StandDetailsScreenState extends State<StandDetailsScreen> {
  final LocationService _locationService = LocationService();
  String _distance = '';

  @override
  void initState() {
    super.initState();
    _updateDistance();
  }

  Future<void> _updateDistance() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null && mounted) {
      final stand = ModalRoute.of(context)!.settings.arguments as Stand;
      final distance = _locationService.calculateDistance(
        position.latitude,
        position.longitude,
        stand.latitude,
        stand.longitude,
      );
      setState(() {
        _distance = distance < 1000
            ? '${distance.toStringAsFixed(0)}m away'
            : '${(distance / 1000).toStringAsFixed(1)}km away';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final stand = ModalRoute.of(context)!.settings.arguments as Stand;

    return Scaffold(
      appBar: CustomAppBar(
        title: stand.name,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stand Image or Placeholder
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                image: stand.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(stand.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: stand.imageUrl == null
                  ? Center(
                      child: Icon(
                        Icons.store,
                        size: 80,
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  : null,
            ),
            // Stand Information
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Distance Chip
                  if (_distance.isNotEmpty)
                    Chip(
                      label: Text(_distance),
                      avatar: const Icon(Icons.location_on, size: 16),
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    ),
                  const SizedBox(height: 16),
                  // Exhibitor Information
                  Text(
                    'Exhibitor Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.business, 'Company', stand.exhibitorName),
                  _buildInfoRow(Icons.phone, 'Contact', stand.exhibitorContact),
                  const Divider(height: 32),
                  // Stand Description
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stand.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Additional Information
                  if (stand.additionalInfo != null) ...[
                    Text(
                      'Additional Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ...stand.additionalInfo!.entries.map((entry) {
                      return _buildInfoRow(
                        Icons.info_outline,
                        entry.key,
                        entry.value.toString(),
                      );
                    }).toList(),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ModernButton(
            text: 'Navigate to Stand',
            icon: Icons.navigation,
            onPressed: () => Navigator.pushNamed(
              context,
              '/ar-navigation',
              arguments: stand,
            ),
            isFullWidth: true,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
