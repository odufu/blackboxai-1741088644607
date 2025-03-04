import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:ar_flutter_plugin/models/ar_hit_test_result.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/stand_model.dart';
import 'dart:math' show sin, cos, atan2, pi;

class ARService {
  ARSessionManager? _arSessionManager;
  ARObjectManager? _arObjectManager;
  ARLocationManager? _arLocationManager;
  List<ARNode> _nodes = [];
  
  // Initialize AR Session
  Future<bool> initializeAR(
    Function(String) onError,
    Function() onARViewCreated,
  ) async {
    try {
      // Check camera permission
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        onError("Camera permission is required for AR");
        return false;
      }
      return true;
    } catch (e) {
      onError("Error initializing AR: $e");
      return false;
    }
  }

  // Set up AR managers
  void onARViewCreated(
    ARSessionManager arSessionManager,
    ARObjectManager arObjectManager,
    ARLocationManager arLocationManager,
  ) {
    _arSessionManager = arSessionManager;
    _arObjectManager = arObjectManager;
    _arLocationManager = arLocationManager;

    _arSessionManager?.onInitialize().then((_) {
      // Configure basic session settings
      _arSessionManager?.onPlaneOrPointTap = (List<ARHitTestResult> hits) {
        // No-op handler to satisfy the non-null requirement
      };
    });
  }

  // Add direction arrow to guide users
  Future<void> addDirectionArrow(
    double targetLat,
    double targetLong,
    double currentLat,
    double currentLong,
  ) async {
    if (_arObjectManager == null) return;

    // Calculate direction vector
    final bearing = _calculateBearing(
      currentLat,
      currentLong,
      targetLat,
      targetLong,
    );

    // Create arrow node
    final node = ARNode(
      type: NodeType.localGLTF2,
      uri: "assets/models/arrow.gltf",
      scale: Vector3(0.2, 0.2, 0.2),
      position: Vector3(0, 0, -1.0),
      rotation: Vector4(0, bearing, 0, 1),
    );

    try {
      await _arObjectManager?.addNode(node);
      _nodes.add(node);
    } catch (e) {
      print("Error adding arrow node: $e");
    }
  }

  // Update arrow direction based on new position
  Future<void> updateArrowDirection(
    double targetLat,
    double targetLong,
    double currentLat,
    double currentLong,
  ) async {
    if (_arObjectManager == null) return;

    final bearing = _calculateBearing(
      currentLat,
      currentLong,
      targetLat,
      targetLong,
    );

    // Remove existing nodes
    for (final node in _nodes) {
      try {
        await _arObjectManager?.removeNode(node);
      } catch (e) {
        print("Error removing node: $e");
      }
    }
    _nodes.clear();

    // Add new arrow with updated rotation
    await addDirectionArrow(targetLat, targetLong, currentLat, currentLong);
  }

  // Add stand marker when near destination
  Future<void> addStandMarker(Stand stand) async {
    if (_arObjectManager == null) return;

    final node = ARNode(
      type: NodeType.localGLTF2,
      uri: "assets/models/stand_marker.gltf",
      scale: Vector3(0.5, 0.5, 0.5),
      position: Vector3(0, -0.5, -2.0),
    );

    try {
      await _arObjectManager?.addNode(node);
      _nodes.add(node);
    } catch (e) {
      print("Error adding stand marker node: $e");
    }
  }

  // Calculate bearing between two points
  double _calculateBearing(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    // Convert to radians
    startLat *= pi / 180;
    startLng *= pi / 180;
    endLat *= pi / 180;
    endLng *= pi / 180;

    final dLong = endLng - startLng;
    
    final y = sin(dLong) * cos(endLat);
    final x = cos(startLat) * sin(endLat) -
             sin(startLat) * cos(endLat) * cos(dLong);
    
    final bearing = atan2(y, x);
    return bearing * (180 / pi); // Convert back to degrees
  }

  // Clean up AR session
  void dispose() {
    // Clean up nodes
    for (final node in _nodes) {
      try {
        _arObjectManager?.removeNode(node);
      } catch (e) {
        print("Error removing node during disposal: $e");
      }
    }
    _nodes.clear();
    
    // Dispose session
    _arSessionManager?.dispose();
  }
}
