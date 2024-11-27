import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:flutter/material.dart';

class PaymentSuccessDialog extends StatelessWidget {
  final String serviceName;
  final String hourlyRate;
  final String serviceDuration;
  final String totalAmount;

  const PaymentSuccessDialog({
    super.key,
    required this.serviceName,
    required this.hourlyRate,
    required this.serviceDuration,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(35.0),
      ),
      child: SizedBox(
        width: Utils.hSize(size.width * 0.9),
        height: Utils.vSize(400.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -50.0,
              left: 0.0,
              right: 0.0,
              child: CircleAvatar(
                radius: 50.0,
                backgroundColor: blueColor.withOpacity(0.7),
                child: CircleAvatar(
                  radius: 38,
                  backgroundColor: primaryColor.withOpacity(1),
                  child: const Icon(
                    Icons.check,
                    size: 60.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              top: Utils.vSize(40.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CustomText(
                      text: 'Great',
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                    const SizedBox(height: 8.0),
                    const CustomText(
                      text: 'Payment Success',
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 8.0),
                    const CustomText(
                      textAlign: TextAlign.center,
                      text: 'Payment for plumber successfully done',
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                    const Divider(height: 24.0, color: Colors.grey),
                    const Row(
                      children: [
                        CustomText(
                          text: 'Payment for',
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_box, color: primaryColor),
                              const SizedBox(width: 8.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: serviceName,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(height: 2.0),
                                  CustomText(
                                    text: 'Hourly Rate: $hourlyRate',
                                    fontSize: 12.0,
                                    color: primaryColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          CustomText(
                            text: '+$serviceDuration',
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Divider(height: 24.0, color: Colors.grey),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CustomText(
                          text: 'Total Payment',
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                        CustomText(
                          text: totalAmount,
                          fontSize: 26.0,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
