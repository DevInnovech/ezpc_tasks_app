import 'package:ezpc_tasks_app/features/booking/data/booking_provider.dart';
import 'package:ezpc_tasks_app/features/booking/models/booking_data_dto.dart';
import 'package:ezpc_tasks_app/features/booking/models/provider_booking_dto.dart';
import 'package:ezpc_tasks_app/features/booking/presentation/widgets/component/booking_component.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/fetch_error_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/loading_widget.dart';
import 'package:ezpc_tasks_app/shared/widgets/scrolling_taggle_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/*class BookingScreen extends ConsumerWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingListProvider);

    return Scaffold(
      body: bookingState.when(
        loading: () => const LoadingWidget(),
        error: (error, stack) => FetchErrorText(text: error.toString()),
        data: (providerBookingDto) => LoadedBookingWidget(
          bookingDto: providerBookingDto,
        ),
      ),
    );
  }
}

class LoadedBookingWidget extends ConsumerStatefulWidget {
  const LoadedBookingWidget({super.key, required this.bookingDto});

  final ProviderBookingDto bookingDto;

  @override
  ConsumerState<LoadedBookingWidget> createState() =>
      _LoadedBookingWidgetState();
}

class _LoadedBookingWidgetState extends ConsumerState<LoadedBookingWidget> {
  List<BookingDataDto> bookingList = [];
  int _currentIndex = 0;

  @override
  void initState() {
    // print(widget.bookingDto.orders);
    _filtering(_currentIndex);
    super.initState();
  }

  void _filtering(int index) {
    bookingList.clear();
    _currentIndex = index;

    print("Filtrando en el índice: $index"); // Agrega esta línea

    switch (index) {
      case 0:
        bookingList = widget.bookingDto.orders!
            .where((element) => element.orderStatus == "awaiting")
            .toList();
        break;
      case 1:
        bookingList = widget.bookingDto.orders!
            .where((element) => element.orderStatus == "approved")
            .toList();
        break;
      case 2:
        bookingList = widget.bookingDto.orders!
            .where((element) => element.orderStatus == "complete")
            .toList();
        break;
      case 3:
        bookingList = widget.bookingDto.orders!
            .where((element) => element.orderStatus == "decliened")
            .toList();
        break;
    }

    print("Elementos filtrados: ${bookingList.length}"); // Agrega esta línea

    if (mounted) setState(() {});*/
import 'package:ezpc_tasks_app/features/booking/presentation/screens/OrderDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProviderOrdersScreen extends StatelessWidget {
  const ProviderOrdersScreen({super.key});

  Future<List<Map<String, dynamic>>> fetchProviderOrders() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint("No provider is logged in.");
        return [];
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('providerId', isEqualTo: user.uid)
          .get();

      return querySnapshot.docs
          .map((doc) => {'taskId': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      return [];
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFF1E6);
      case 'in progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    /*  final size = MediaQuery.sizeOf(context);
    final list = [
      "Awaiting (${_countOrders("awaiting")})",
      "Approved (${_countOrders("approved")})",
      "Complete (${_countOrders("complete")})",
      "Declined (${_countOrders("decliened")})",
    ];

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          automaticallyImplyLeading: false,
          pinned: true,
          backgroundColor: scaffoldBgColor,
          toolbarHeight: Utils.vSize(75.0),
          centerTitle: true,
          title: const CustomText(
            text: "Booking",
            fontSize: 22.0,
            fontWeight: FontWeight.w700,
            color: blackColor,
          ),
          bottom: ToggleButtonScrollComponent(
            onChange: _filtering,
            textList: list,
            initialLabelIndex: _currentIndex,
          ),
        ),
        bookingList.isNotEmpty
            ? SliverList(
                delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    BookingComponent(booking: bookingList[index]),
                childCount: bookingList.length,
              ))
            : SliverToBoxAdapter(
                child: SizedBox(
                  height: size.height * 0.6,
                  width: size.width,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomImage(
                        url: null,
                        path: KImages.emptyBookingImage,
                      ),
                      CustomText(
                          text: 'Empty Item',
                          fontSize: 22.0,
                          fontWeight: FontWeight.w700)
                    ],
                  ),
                ),
              ),*/
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: const Color(0xFF404C8C),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchProviderOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading orders.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          final orders = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
            itemCount: orders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final order = orders[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailsScreen(order: order),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: const Color(0xFFC0C1C7),
                      width: 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Task Image
                            _buildTaskImage(order),
                            const SizedBox(width: 12.0),
                            // Task Details with Status
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: order['status']?.toLowerCase() ==
                                              'pending'
                                          ? const Color(0xFFFFF1E6)
                                          : getStatusColor(
                                              order['status'] ?? ''),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      order['status']?.toUpperCase() ?? 'N/A',
                                      style: TextStyle(
                                        color: order['status']?.toLowerCase() ==
                                                'pending'
                                            ? const Color(0xFFEA7446)
                                            : Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    order['taskName'] ?? 'Task Name',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  _buildPriceRow(order),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildOrderDetailsContainer(order),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTaskImage(Map<String, dynamic> order) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: order['imageUrl'] != null && order['imageUrl'].isNotEmpty
          ? Image.network(
              order['imageUrl'],
              height: 80,
              width: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholderImage();
              },
            )
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 80,
      width: 80,
      color: Colors.grey[300],
      child: const Icon(
        Icons.image,
        size: 40,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildPriceRow(Map<String, dynamic> order) {
    return Row(
      children: [
        Text(
          '\$${order['price']?.toStringAsFixed(2) ?? '0.00'}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF404C8C),
          ),
        ),
        if (order['discount'] != null)
          Text(
            ' (${order['discount']}% Off)',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.green,
            ),
          ),
      ],
    );
  }

  /* int _countOrders(String status) {
    return widget.bookingDto.orders!
        .where((element) => element.orderStatus == status)
        .length;*/
  Widget _buildOrderDetailsContainer(Map<String, dynamic> order) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Address', order['address'] ?? 'N/A'),
          const Divider(color: Colors.grey),
          _buildDetailRow('Date & Time',
              '${order['date'] ?? 'N/A'} At ${order['time'] ?? 'N/A'}'),
          const Divider(color: Colors.grey),
          _buildDetailRow('Customer', order['customerName'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
