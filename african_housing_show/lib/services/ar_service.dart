import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:vector_math/vector_math_64.dart';
import '../models/stand_model.dart';

class ARService {
  ARSessionManager? _arSessionManager;
  ARObjectManager? _arObjectManager;
  ARLocationManager? _arLocationManager;
  
  // Initialize AR Session
  Future<bool> initializeAR(
    Function(String) onError,
    Function() onARViewCreated,
  ) async {
    try {
      await ARFlutterPlugin.checkAvailability();
      return true;
    } catch (e) {
      onError("AR is not available on this device: $e");
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
      _arSessionManager?.updateConfiguration(
        showFeaturePoints: false,
        showPlanes: false,
        showWorldOrigin: false,
        handleTaps: false,
      );
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

    await _arObjectManager?.addNode(node);
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

    // Update existing arrow rotation
    final nodes = await _arObjectManager?.getNodes() ?? [];
    for (final node in nodes) {
      await _arObjectManager?.updateRotation(
        node,
        Vector4(0, bearing, 0, 1),
      );
    }
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

    await _arObjectManager?.addNode(node);
  }

  // Calculate bearing between two points
  double _calculateBearing(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    final dLong = endLng - startLng;
    
    final y = sin(dLong) * cos(endLat);
    final x = cos(startLat) * sin(endLat) -
             sin(startLat) * cos(endLat) * cos(dLong);
    
    final bearing = atan2(y, x);
    return bearing * (180 / pi); // Convert to degrees
  }

  // Clean up AR session
  void dispose() {
    _arSessionManager?.dispose();
  }
}
