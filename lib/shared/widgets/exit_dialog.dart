import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_dialog.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExitDialog extends StatelessWidget {
  const ExitDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return CustomDialog(
      icon: KImages.exitFromAppIcon,
      height: size.height * 0.32,
      child: Column(
        children: [
          const CustomText(
            text: 'Are you sure\nYou want to Exit?',
            fontSize: 18.0,
            fontWeight: FontWeight.w700,
            color: blackColor,
            textAlign: TextAlign.center,
          ),
          Utils.verticalSpace(8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PrimaryButton(
                text: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
                borderRadiusSize: 6.0,
                bgColor: blackColor,
                fontSize: 16.0,
                minimumSize: Size(Utils.hSize(125.0), Utils.vSize(52.0)),
              ),
              PrimaryButton(
                text: 'Exit',
                onPressed: () => SystemNavigator.pop(),
                bgColor: redColor,
                borderRadiusSize: 6.0,
                fontSize: 16.0,
                minimumSize: Size(Utils.hSize(125.0), Utils.vSize(52.0)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
