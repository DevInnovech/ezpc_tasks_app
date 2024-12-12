import 'package:ezpc_tasks_app/features/Client_Booking/data%20&%20models/order_details_model.dart';
import 'package:ezpc_tasks_app/features/Client_Booking/data%20&%20models/provider_tracking_provider.dart';
import 'package:ezpc_tasks_app/features/Client_Booking/expandable_status.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart';

class ProviderTrackingScreen extends ConsumerWidget {
  final OrderDetailsDto order;
  final MapController _mapController = MapController(); // Add MapController

  ProviderTrackingScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingState = ref.watch(providerTrackingProvider(order.orderId));

    return Scaffold(
      appBar: AppBar(title: const Text("Seguimiento del Proveedor")),
      body: trackingState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (trackingData) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(trackingData),
                _buildOrderInfo(trackingData),
                _buildMap(trackingData, context),
                _buildProcessIndicator(trackingData.status),
                ExpandableStatusDescription(status: trackingData.status),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  child: PrimaryButton(
                    text: "Report a problem",
                    onPressed: () {},
                    bgColor: Colors.red,
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(trackingData) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(trackingData.providerImageUrl),
          ),
          Column(
            children: [
              Text(trackingData.providerName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.chat,
                      color: primaryColor,
                    ),
                    onPressed: () {
                      // Navegar a la pantalla de chat
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.phone,
                      color: primaryColor,
                    ),
                    onPressed: () {
                      // Iniciar llamada
                    },
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildOrderInfo(trackingData) {
    return Column(
      children: [
        const Text(
          "Order Number",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4), // Space between title and order number
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            trackingData.orderId,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF535769),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMap(trackingData, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height:
            MediaQuery.of(context).size.height * 0.35, // 35% of screen height
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: FlutterMap(
                mapController: _mapController, // Attach controller
                options: MapOptions(
                  initialCenter:
                      trackingData.providerLocation ?? const LatLng(0, 0),
                  initialZoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  if (trackingData.providerLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: trackingData.providerLocation!,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.blue,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.white,
                onPressed: () {
                  // Logic to center the map on the provider's location
                  if (trackingData.providerLocation != null) {
                    _mapController.move(trackingData.providerLocation!, 15.0);
                  }
                },
                child: const Icon(
                  Icons.my_location,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessIndicator(TrackingStatus status) {
    Color activeColor = Colors.blue; // Replace with your primary color
    Color inactiveColor = Colors.grey;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // First Circle with Target Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: activeColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.gps_fixed,
              color: Colors.white,
              size: 28,
            ),
          ),

          // Connecting Line 1
          Container(
            width: 50,
            height: 2,
            color: (status == TrackingStatus.reserved ||
                    status == TrackingStatus.onTheWay ||
                    status == TrackingStatus.atLocation)
                ? activeColor
                : inactiveColor,
          ),

          // Second Circle with Person Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (status == TrackingStatus.onTheWay ||
                      status == TrackingStatus.atLocation)
                  ? activeColor
                  : inactiveColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 28,
            ),
          ),

          // Connecting Line 2
          Container(
            width: 50,
            height: 2,
            color: (status == TrackingStatus.atLocation)
                ? activeColor
                : inactiveColor,
          ),

          // Third Circle with Location Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: status == TrackingStatus.atLocation
                  ? activeColor
                  : inactiveColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
