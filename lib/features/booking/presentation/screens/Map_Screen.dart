import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String address;
  final String providerId; // Unique ID for the provider

  const MapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.providerId,
  });

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _isTracking = false;
  Stream<Position>? _positionStream;

  Future<void> _startDriving() async {
    final googleMapsUrl =
        'google.navigation:q=${widget.latitude},${widget.longitude}&mode=d';
    final appleMapsUrl =
        'http://maps.apple.com/?daddr=${widget.latitude},${widget.longitude}&dirflg=d';

    try {
      if (await canLaunch(googleMapsUrl)) {
        await launch(googleMapsUrl); // Open Google Maps
      } else if (await canLaunch(appleMapsUrl)) {
        await launch(appleMapsUrl); // Open Apple Maps for iOS
      } else {
        throw 'Could not launch maps';
      }

      // Start live location tracking
      _startLiveLocationTracking();
    } catch (e) {
      debugPrint('Error launching maps: $e');
    }
  }

  Future<void> _startLiveLocationTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    setState(() {
      _isTracking = true;
    });

    // Start listening to location updates
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );

    _positionStream!.listen((Position position) {
      _updateProviderLocation(position);
    });
  }

  Future<void> _updateProviderLocation(Position position) async {
    try {
      await FirebaseFirestore.instance
          .collection('providers')
          .doc(widget.providerId)
          .update({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      debugPrint(
          'Location updated: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      debugPrint('Error updating location: $e');
    }
  }

  Future<void> _stopTracking() async {
    setState(() {
      _isTracking = false;
    });

    debugPrint('Stopped live location tracking.');
  }

  @override
  Widget build(BuildContext context) {
    final LatLng location = LatLng(widget.latitude, widget.longitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Location'),
        backgroundColor: const Color(0xFF404C8C),
        actions: [
          if (_isTracking)
            IconButton(
              icon: const Icon(Icons.stop, color: Colors.red),
              onPressed: _stopTracking,
            ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: location,
              zoom: 14.0,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('clientAddress'),
                position: location,
                infoWindow: InfoWindow(title: widget.address),
              ),
            },
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _startDriving,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Start Driving",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
