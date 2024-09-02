import 'package:ezpc_tasks_app/features/withdraw/model.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:flutter/material.dart';

class WithdrawComponent extends StatelessWidget {
  const WithdrawComponent({super.key, required this.withdraw});
  final WithdrawModel withdraw;

  @override
  Widget build(BuildContext context) {
    final String typeTrasations = withdraw.typetrasations ? "+" : "-";

    final active = withdraw.status == 1;
    return Container(
      width: double.infinity,
      padding: Utils.symmetric(v: 12.0),
      margin: Utils.symmetric(v: 6.0),
      decoration:
          BoxDecoration(color: whiteColor, borderRadius: Utils.borderRadius()),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: Utils.only(top: 6.0, right: 10.0),
            child: CircleAvatar(
              backgroundColor: scaffoldBgColor,
              maxRadius: Utils.radius(22.0),
              child: CustomImage(
                  path: KImages.paymentIcon,
                  height: Utils.vSize(32.0),
                  width: Utils.vSize(32.0)),
            ),
          ),
          Expanded(
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: withdraw.method,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                  color: blackColor,
                ),
                /* Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomText(
                      text: withdraw.method,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      color: blackColor,
                    ),
                    CustomText(
                      text: "$type_trasations\$" +
                          withdraw.totalAmount.toString(),
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ],
                ),
              */
                Utils.verticalSpace(4.0),
                CustomText(
                  //text: '3:02 PM - Aug 22, 2021',
                  text: Utils.dataAndTimeFormat(withdraw.createdAt),
                  fontSize: 12.0,
                  fontWeight: FontWeight.w400,
                  color: grayColor,
                ),
                /* Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      //text: '3:02 PM - Aug 22, 2021',
                      text: Utils.dataAndTimeFormat(withdraw.createdAt),
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: grayColor,
                    ),
                 Container(
                      height: Utils.vSize(28.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: active
                              ? greenColor.withOpacity(0.2)
                              : redColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(24.0)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 2.0),
                        child: CustomText(
                          text:
                              Utils.withdrawStatus(withdraw.status.toString()),
                          color: active ? greenColor : redColor,
                        ),
                      ),
                    ),
                  ],
                ),*/
              ],
            ),
          ),
          CustomText(
            text: "$typeTrasations\$${withdraw.totalAmount}",
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ],
      ),
    );
  }
}
