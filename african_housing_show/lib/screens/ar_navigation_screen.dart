import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import '../models/stand_model.dart';
import '../services/ar_service.dart';
import '../services/location_service.dart';
import '../widgets/error_dialog.dart';

class ARNavigationScreen extends StatefulWidget {
  const ARNavigationScreen({super.key});

  @override
  State<ARNavigationScreen> createState() => _ARNavigationScreenState();
}

class _ARNavigationScreenState extends State<ARNavigationScreen> {
  final ARService _arService = ARService();
  final LocationService _locationService = LocationService();
  Stand? _targetStand;
  bool _isInitialized = false;
  String _distance = '';
  String _direction = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAR();
    });
  }

  Future<void> _initializeAR() async {
    _targetStand = ModalRoute.of(context)!.settings.arguments as Stand?;
    if (_targetStand == null) {
      Navigator.pop(context);
      return;
    }

    final arAvailable = await _arService.initializeAR(
      (error) => _showError(error),
      () => setState(() => _isInitialized = true),
    );

    if (!arAvailable) {
      if (!mounted) return;
      await ErrorDialog.show(
        context: context,
        title: 'AR Not Available',
        message: 'Your device does not support AR features.',
        buttonText: 'OK',
        onButtonPressed: () => Navigator.pop(context),
      );
      return;
    }

    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    _locationService.getLocationStream().listen((position) {
      if (_targetStand != null) {
        final distance = _locationService.calculateDistance(
          position.latitude,
          position.longitude,
          _targetStand!.latitude,
          _targetStand!.longitude,
        );

        final bearing = _locationService.getBearing(
          position.latitude,
          position.longitude,
          _targetStand!.latitude,
          _targetStand!.longitude,
        );

        setState(() {
          _distance = distance < 1000
              ? '${distance.toStringAsFixed(0)}m'
              : '${(distance / 1000).toStringAsFixed(1)}km';
          _direction = _getDirectionFromBearing(bearing);
        });

        // Update AR direction arrow
        _arService.updateArrowDirection(
          _targetStand!.latitude,
          _targetStand!.longitude,
          position.latitude,
          position.longitude,
        );

        // Show stand marker if within 10 meters
        if (distance <= 10 && _isInitialized) {
          _arService.addStandMarker(_targetStand!);
        }
      }
    });
  }

  String _getDirectionFromBearing(double bearing) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((bearing + 22.5) % 360 / 45).floor();
    return directions[index];
  }

  void _showError(String message) {
    if (!mounted) return;
    ErrorDialog.show(
      context: context,
      title: 'Error',
      message: message,
      buttonText: 'OK',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // AR View
          ARView(
            onARViewCreated: (arSessionManager, arObjectManager, arLocationManager) {
              _arService.onARViewCreated(
                arSessionManager,
                arObjectManager,
                arLocationManager,
              );
            },
          ),
          // Navigation Overlay
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.black.withOpacity(0.5),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Navigating to ${_targetStand?.name ?? ''}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Navigation Info
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.black.withOpacity(0.3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoCard(
                        icon: Icons.location_on,
                        label: 'Distance',
                        value: _distance,
                      ),
                      _buildInfoCard(
                        icon: Icons.compass_calibration,
                        label: 'Direction',
                        value: _direction,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Help Text
          if (!_isInitialized)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _arService.dispose();
    super.dispose();
  }
}
