import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_dialog.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class ServiceDeleteDialog extends StatelessWidget {
  const ServiceDeleteDialog({
    super.key,
    required this.onTap,
    this.title = 'Do you want Delete\nthis Service?',
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return CustomDialog(
      icon: KImages.trashIcon2,
      height: size.height * 0.3,
      child: Column(
        children: [
          CustomText(
            text: title,
            fontSize: 18.0,
            fontWeight: FontWeight.w700,
            color: blackColor,
            textAlign: TextAlign.center,
          ),
          Utils.verticalSpace(6.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PrimaryButton(
                text: 'Not Now',
                onPressed: () => Navigator.of(context).pop(),
                borderRadiusSize: 6.0,
                bgColor: blackColor,
                minimumSize: Size(Utils.hSize(125.0), Utils.vSize(52.0)),
              ),
              PrimaryButton(
                text: 'Delete',
                onPressed: onTap,
                // onPressed: () => Navigator.of(context).pop(),
                bgColor: redColor,
                borderRadiusSize: 6.0,
                minimumSize: Size(Utils.hSize(125.0), Utils.vSize(52.0)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
