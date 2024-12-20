import 'package:ezpc_tasks_app/features/booking/presentation/screens/ProviderOrderDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String address;
  final String providerId;
  final String bookingId; // Booking document ID

  const MapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.providerId,
    required this.bookingId,
  });

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _isLoading = false;
  String _currentStatus = "pending"; // Local state for ProviderStatus
  late Stream<DocumentSnapshot> _providerStatusStream;

  @override
  void initState() {
    super.initState();
    // Initialize the ProviderStatus stream
    _providerStatusStream = FirebaseFirestore.instance
        .collection('bookings')
        .doc(widget.bookingId)
        .snapshots();

    // Initialize the ProviderStatus field if it doesn't exist
    _initializeProviderStatus();
  }

  Future<void> _initializeProviderStatus() async {
    final bookingDoc =
        FirebaseFirestore.instance.collection('bookings').doc(widget.bookingId);

    try {
      final snapshot = await bookingDoc.get();
      if (!snapshot.exists || !snapshot.data()!.containsKey('ProviderStatus')) {
        // Set a default ProviderStatus if it doesn't exist
        await bookingDoc.update({
          'ProviderStatus': 'pending',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      setState(() {
        _currentStatus = snapshot.data()?['ProviderStatus'] ?? 'pending';
      });
    } catch (e) {
      debugPrint('Error initializing ProviderStatus: $e');
    }
  }

  Future<void> _startDriving() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final googleMapsUrl =
          'google.navigation:q=${widget.latitude},${widget.longitude}&mode=d';
      final appleMapsUrl =
          'http://maps.apple.com/?daddr=${widget.latitude},${widget.longitude}&dirflg=d';

      if (await canLaunch(googleMapsUrl)) {
        await launch(googleMapsUrl);
      } else if (await canLaunch(appleMapsUrl)) {
        await launch(appleMapsUrl);
      } else {
        throw 'Could not launch maps';
      }

      // Update Firestore with the new ProviderStatus
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .update({
        'ProviderStatus': 'on_the_way',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local state after successful Firestore write
      setState(() {
        _currentStatus = 'on_the_way';
        _isLoading = false;
      });

      debugPrint('ProviderStatus updated to "on_the_way"');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error starting driving: $e');
    }
  }

  Future<void> _markAsArrived() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Actualiza Firestore con el nuevo estado 'arrived'
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .update({
        'ProviderStatus': 'arrived',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Carga toda la información del booking desde Firestore
      final bookingSnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .get();

      if (!bookingSnapshot.exists) {
        throw Exception("Booking document not found.");
      }

      final bookingData = bookingSnapshot.data()!;

      // Actualiza el estado local y navega a la pantalla OrderDetailsScreen
      setState(() {
        _currentStatus = 'arrived';
        _isLoading = false;
      });

      // Navegar a OrderDetailsScreen con toda la información del booking
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderDetailsScreen(
            order: bookingData, // Pasar todos los datos del booking
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error marking as arrived: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng location = LatLng(widget.latitude, widget.longitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Location'),
        backgroundColor: const Color(0xFF404C8C),
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
            child: StreamBuilder<DocumentSnapshot>(
              stream: _providerStatusStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final bookingData =
                    snapshot.data!.data() as Map<String, dynamic>;
                final currentStatus =
                    bookingData['ProviderStatus'] ?? _currentStatus;

                return ElevatedButton(
                  onPressed: _isLoading
                      ? null // Disable the button while processing
                      : currentStatus == 'on_the_way'
                          ? _markAsArrived
                          : _startDriving,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLoading
                        ? Colors.grey
                        : currentStatus == 'on_the_way'
                            ? Colors.green
                            : Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          currentStatus == 'on_the_way'
                              ? "I've Arrived"
                              : "Start Driving",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
