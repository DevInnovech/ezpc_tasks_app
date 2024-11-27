import 'package:ezpc_tasks_app/features/booking/models/booking_details_dto.dart';
import 'package:ezpc_tasks_app/features/booking/presentation/screens/tracking/open_maps.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:flutter/material.dart';

class IncludeService extends StatelessWidget {
  const IncludeService({super.key, required this.service});

  final BookingDetailsDto service;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Utils.only(bottom: 20.0),
      child: Column(
        children: List.generate(
          service.packageFeatures.length,
          (index) => Padding(
            padding: Utils.symmetric(h: 0.0, v: 3.0),
            child: Row(
              children: [
                Padding(
                  padding: Utils.only(top: 2.0),
                  child: const Icon(
                    Icons.check_circle,
                    color: primaryColor,
                    size: 18.0,
                  ),
                ),
                Utils.horizontalSpace(4.0),
                CustomText(
                  text: service.packageFeatures[index],
                  color: grayColor,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BookingDetailsAddress extends StatelessWidget {
  const BookingDetailsAddress({super.key, required this.service});

  final BookingDetailsDto service;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Utils.only(bottom: 20.0),
      child: Column(
        children: [
          _buildSchedule(
              title: 'Booking ID:', value: '#${service.orders.orderId}'),
          _buildSchedule(title: 'Name:', value: service.bookingAddress.name),
          _buildSchedule(title: 'Phone:', value: service.bookingAddress.phone),
          _buildSchedule(title: 'Email:', value: service.bookingAddress.email),
          _buildSchedule(
              title: 'Address:', value: service.bookingAddress.address),
          _buildSchedule(
              title: 'Post Code:', value: service.bookingAddress.postCode),
          _buildSchedule(
              title: 'Order Note:',
              value: service.bookingAddress.orderNote,
              dotted: false),
        ],
      ),
    );
  }
}

class ClientInformation extends StatelessWidget {
  const ClientInformation({super.key, required this.service});

  final BookingDetailsDto service;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Utils.only(bottom: 20.0),
      child: Column(
        children: [
          _buildSchedule(
              title: 'Booking ID:', value: '#${service.orders.orderId}'),
          _buildSchedule(title: 'Name:', value: service.orders.client.name),
          _buildSchedule(title: 'Phone:', value: service.orders.client.phone),
          _buildSchedule(title: 'Email:', value: service.orders.client.email),
          _buildSchedule(
              title: 'Address:',
              value: service.orders.client.address,
              ontap: () => launchMaps(context, service.orders.client.address)),
          _buildSchedule(
              title: 'Schedule:',
              value: Utils.scheduleTimeFormat(service.orders.bookingDate),
              dotted: false),
        ],
      ),
    );
  }
}

Widget _buildSchedule(
    {required String title,
    required String value,
    bool dotted = true,
    Future<void> Function()? ontap}) {
  return Padding(
    padding: Utils.symmetric(h: 0.0, v: 6.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              text: title,
              fontWeight: FontWeight.w500,
              color: blackColor,
            ),
            GestureDetector(
              onTap: () async {
                if (ontap != null) {
                  await ontap(); // Ejecuta la función futura si está disponible
                }
              },
              child: CustomText(
                text: value,
                color: grayColor,
              ),
            ),
          ],
        ),
        Utils.verticalSpace(dotted ? 8.0 : 0.0),
        dotted
            ? Divider(color: grayColor.withOpacity(0.2), thickness: 0.5)
            : const SizedBox(),
      ],
    ),
  );
}
