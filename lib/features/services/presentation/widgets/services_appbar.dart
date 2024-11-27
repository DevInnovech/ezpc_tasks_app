import 'package:dotted_border/dotted_border.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:flutter/material.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';

class ServiceAppBar extends StatelessWidget {
  const ServiceAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, RouteNames.addNewServiceScreen),
      child: Container(
        padding: Utils.symmetric(v: 12.0),
        color: scaffoldBgColor,
        child: Container(
          height: Utils.hSize(50.0),
          margin: Utils.symmetric(),
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: Utils.borderRadius(),
          ),
          child: DottedBorder(
            padding: Utils.symmetric(v: 14.0),
            borderType: BorderType.RRect,
            radius: Radius.circular(Utils.radius(10.0)),
            color: blueColor,
            dashPattern: const [6, 3],
            strokeCap: StrokeCap.square,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_box_rounded,
                  color: grayColor,
                ),
                Utils.horizontalSpace(5.0),
                const CustomText(
                  text: "Add New Service",
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  color: grayColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
