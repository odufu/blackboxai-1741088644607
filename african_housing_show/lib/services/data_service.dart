import 'dart:async';
import 'dart:math' show sin, cos, sqrt, atan2, pi;
import '../models/stand_model.dart';

class DataService {
  // Simulate a database of stands
  final List<Stand> _stands = [];

  // Get all stands
  Future<List<Stand>> getAllStands() async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    return _stands;
  }

  // Get stand by ID
  Future<Stand?> getStandById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _stands.firstWhere((stand) => stand.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search stands by name or exhibitor
  Future<List<Stand>> searchStands(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _stands.where((stand) {
      final searchLower = query.toLowerCase();
      return stand.name.toLowerCase().contains(searchLower) ||
             stand.exhibitorName.toLowerCase().contains(searchLower);
    }).toList();
  }

  // Add new stand (admin function)
  Future<bool> addStand(Stand stand) async {
    try {
      _stands.add(stand);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Update stand (admin function)
  Future<bool> updateStand(Stand updatedStand) async {
    try {
      final index = _stands.indexWhere((s) => s.id == updatedStand.id);
      if (index != -1) {
        _stands[index] = updatedStand;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Delete stand (admin function)
  Future<bool> deleteStand(String id) async {
    try {
      _stands.removeWhere((stand) => stand.id == id);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get nearby stands based on user location
  Future<List<Stand>> getNearbyStands(double userLat, double userLng, double radiusInMeters) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _stands.where((stand) {
      final distance = _calculateDistance(
        userLat,
        userLng,
        stand.latitude,
        stand.longitude,
      );
      return distance <= radiusInMeters;
    }).toList();
  }

  // Calculate distance between two points using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Earth's radius in meters
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    
    final double a = (
      sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
      sin(dLon / 2) * sin(dLon / 2)
    );
    
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  // Helper function to convert degrees to radians
  double _toRadians(double degree) {
    return degree * (pi / 180);
  }
}
