import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/modern_button.dart';
import '../services/data_service.dart';
import '../services/location_service.dart';
import '../models/stand_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DataService _dataService = DataService();
  final LocationService _locationService = LocationService();
  List<Stand> _nearbyStands = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNearbyStands();
  }

  Future<void> _loadNearbyStands() async {
    setState(() => _isLoading = true);
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        final stands = await _dataService.getNearbyStands(
          position.latitude,
          position.longitude,
          1000, // Search within 1km radius
        );
        setState(() => _nearbyStands = stands);
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'African Housing Show',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () => Navigator.pushNamed(context, '/admin-login'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Find Exhibition Stands',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ModernButton(
                    text: 'Search Stands',
                    icon: Icons.search,
                    onPressed: () => Navigator.pushNamed(context, '/stands'),
                    isFullWidth: true,
                  ),
                  const SizedBox(height: 12),
                  ModernOutlinedButton(
                    text: 'Start AR Navigation',
                    icon: Icons.view_in_ar,
                    onPressed: () => Navigator.pushNamed(context, '/ar-navigation'),
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
            // Nearby Stands Section
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _nearbyStands.isEmpty
                      ? const Center(
                          child: Text(
                            'No nearby stands found',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _nearbyStands.length,
                          itemBuilder: (context, index) {
                            final stand = _nearbyStands[index];
                            return _buildStandCard(stand);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandCard(Stand stand) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          '/stand-details',
          arguments: stand,
        ),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.store,
                      size: 30,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stand.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stand.exhibitorName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
