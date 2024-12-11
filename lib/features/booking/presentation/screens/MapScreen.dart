import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {}; // Set to hold the markers

  // Initial position of the map
  static const LatLng _center =
      LatLng(37.7749, -122.4194); // Example: San Francisco

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // Add a marker on the map (could be changed to dynamic data)
  void _addMarker(LatLng position) {
    final String markerId = position.toString();
    final Marker marker = Marker(
      markerId: MarkerId(markerId),
      position: position,
      infoWindow: InfoWindow(
          title: 'Marker at ${position.latitude}, ${position.longitude}'),
    );

    setState(() {
      _markers.add(marker);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Screen'),
        backgroundColor: const Color(0xFF404C8C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: _center,
          zoom: 12.0,
        ),
        markers: _markers,
        onTap: _addMarker, // Add a marker when the user taps on the map
      ),
    );
  }
}
