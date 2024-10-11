import 'package:ezpc_tasks_app/features/booking/models/booking_data_dto.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class BookingComponent extends StatelessWidget {
  const BookingComponent({super.key, required this.booking});

  final BookingDataDto booking;

  @override
  Widget build(BuildContext context) {
    final service = booking.service;
    return Container(
      padding: Utils.symmetric(v: 20.0, h: 12.0),
      margin: Utils.symmetric(v: 12.0, h: 16.0),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(Utils.radius(10.0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                height: Utils.vSize(100.0),
                width: Utils.vSize(100.0),
                margin: Utils.only(right: 10.0),
                child: ClipRRect(
                  borderRadius: Utils.borderRadius(r: 6.0),
                  child: CustomImage(
                    url: null,
                    path: service!.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: Utils.symmetric(h: 8.0, v: 5.0),
                          decoration: BoxDecoration(
                            color: Utils.getBgColor(
                                booking.orderStatus.toString()),
                            borderRadius: Utils.borderRadius(r: 6.0),
                          ),
                          child: CustomText(
                            text: Utils.orderStatus(
                                booking.orderStatus.toString()),
                            color:
                                Utils.textColor(booking.orderStatus.toString()),
                          ),
                        ),
                        CustomText(
                          text: Utils.scheduleTimeFormat(booking.createdAt),
                          fontWeight: FontWeight.w500,
                          color: grayColor,
                        ),
                      ],
                    ),
                    Utils.verticalSpace(10.0),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: Utils.hSize(210.0),
                        maxHeight: Utils.vSize(70.0),
                      ),
                      child: CustomText(
                        text: service.name,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        maxLine: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            height: 1.0,
            color: grayColor.withOpacity(0.1),
            margin: Utils.symmetric(h: 0.0, v: 10.0),
          ),
          _buildSchedule(
              title: 'Booking ID:', value: '#${booking.orderId.toString()}'),
          _buildSchedule(
              title: 'Schedule:',
              value:
                  '${booking.scheduleTimeSlot} ${Utils.scheduleTimeFormat(booking.bookingDate)}'),
          Utils.verticalSpace(12.0),
          PrimaryButton(
            text: booking.orderStatus == "approved"
                ? 'Track Booking'
                : 'View Details',
            onPressed: () {
              if (booking.orderStatus == "approved") {
                // Navigate to Booking Tracking Screen for approved bookings
                Navigator.pushNamed(
                  context,
                  RouteNames
                      .bookingTrackingScreen, // Update to your tracking route
                  arguments: booking.orderId.toString(),
                );
              } else {
                // Navigate to other details page for non-approved bookings
                Navigator.pushNamed(
                  context,
                  RouteNames.bookingDetailsScreen,
                  arguments: booking.orderId.toString(),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSchedule({required String title, required String value}) {
    return Padding(
      padding: Utils.symmetric(h: 0.0, v: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: title,
            fontWeight: FontWeight.w500,
            color: blackColor,
          ),
          CustomText(
            text: value,
            color: grayColor,
          ),
        ],
      ),
    );
  }
}
