import 'package:ezpc_tasks_app/features/booking/data/booking_provider.dart';
import 'package:ezpc_tasks_app/features/booking/models/booking_details_dto.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_curve_shape.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'declined_order_dialog.dart';

class DetailBottomSection extends ConsumerWidget {
  const DetailBottomSection({
    super.key,
    required this.bookingDetails,
    required this.panelController,
  });

  final BookingDetailsDto bookingDetails;
  final PanelController panelController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingRepository = ref.read(bookingRepositoryProvider);
    final total = double.parse(bookingDetails.orders.totalAmount.toString()) +
        double.parse(bookingDetails.orders.additionalAmount.toString());

    return Container(
      width: double.infinity,
      height: Utils.vSize(301.0),
      decoration: const BoxDecoration(
        boxShadow: [],
      ),
      child: CustomPaint(
        painter: CustomCurveShape(),
        child: Padding(
          padding: Utils.symmetric(v: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    panelController.isPanelOpen
                        ? panelController.close()
                        : panelController.open();
                  },
                  child: CustomImage(
                    url: null,
                    path: KImages.lineIcon,
                    color: blackColor.withOpacity(0.8),
                  ),
                ),
              ),
              Utils.verticalSpace(16.0),
              const CustomText(
                text: 'Billing Info',
                color: blackColor,
                fontWeight: FontWeight.w500,
                fontSize: 22.0,
              ),
              Container(
                margin: Utils.symmetric(h: 0.0, v: 14.0),
                color: grayColor.withOpacity(0.2),
                height: 0.5,
              ),
              _billInfo(
                'Package Fee',
                bookingDetails.orders.totalAmount.toString(),
                redColor,
              ),
              Utils.verticalSpace(12.0),
              _billInfo(
                'Extra Service',
                bookingDetails.orders.additionalAmount.toString(),
                redColor,
                color: redColor,
              ),
              Container(
                margin: Utils.symmetric(h: 0.0, v: 14.0),
                color: grayColor.withOpacity(0.2),
                height: 0.5,
              ),
              _billInfo(
                'Total Amount',
                total.toString(),
                blackColor,
                fontWeight: FontWeight.w700,
              ),
              Utils.verticalSpace(20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PrimaryButton(
                    text: 'Accept',
                    onPressed: () => showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => DeclinedOrderDialog(
                              onDelete: () async {
                                await bookingRepository.acceptBooking(
                                  bookingDetails.orders.id.toString(),
                                );
                                print(
                                    'Booking accepted: ${bookingDetails.orders.id}');
                              },
                              buttonText: 'Accept',
                              text: 'Do you want to Accept this task?',
                              verticalLayout:
                                  false, // Habilitar disposición vertical
                            )),
                    minimumSize: Size(Utils.hSize(160.0), Utils.vSize(52.0)),
                  ),
                  PrimaryButton(
                    text: 'Decline',
                    onPressed: () => showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => DeclinedOrderDialog(
                        buttonText: 'Decline',
                        text: "Do you want to decline this task?",
                        verticalLayout: false,
                        onDelete: () async {
                          await bookingRepository.declineBooking(
                            bookingDetails.orders.id.toString(),
                          );
                          print(
                              'Booking declined: ${bookingDetails.orders.id}');
                        },
                      ),
                    ),
                    bgColor: redColor,
                    minimumSize: Size(Utils.hSize(160.0), Utils.vSize(52.0)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _billInfo(String title, String price, Color color2,
      {Color color = blackColor, FontWeight fontWeight = FontWeight.w500}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          text: title,
          fontSize: 14.0,
          fontWeight: fontWeight,
          color: color,
        ),
        CustomText(
          text: price,
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          color: color2,
        ),
      ],
    );
  }
}
