import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class DeclinedOrderDialog extends StatelessWidget {
  const DeclinedOrderDialog(
      {super.key,
      required this.onDelete,
      required this.buttonText,
      this.text = 'Do you want to Decline\nthis Product?',
      this.verticalLayout = false});

  final String buttonText;
  final VoidCallback onDelete;
  final String text;
  final bool verticalLayout;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              text: text,
              fontSize: 18.0,
              fontWeight: FontWeight.w700,
              color: blackColor,
              textAlign: TextAlign.center,
            ),
            Utils.verticalSpace(20.0),
            verticalLayout
                ? Column(
                    // Alinear botones verticalmente
                    children: [
                      // Botón "No"
                      PrimaryButton(
                        text: 'No',
                        onPressed: () => Navigator.of(context).pop(),
                        borderRadiusSize: 8.0,
                        minimumSize: Size(double.infinity, Utils.vSize(45.0)),
                      ),
                      Utils.verticalSpace(10.0), // Espacio entre botones
                      // Botón "Yes"
                      PrimaryButton(
                        text: buttonText,
                        onPressed: onDelete,
                        bgColor: redColor,
                        borderRadiusSize: 8.0,
                        minimumSize: Size(double.infinity, Utils.vSize(45.0)),
                      ),
                    ],
                  )
                : Row(
                    // Alinear botones horizontalmente
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botón "Decline"
                      Expanded(
                        child: PrimaryButton(
                          text: buttonText,
                          onPressed: onDelete,
                          borderRadiusSize: 8.0,
                          minimumSize: Size(double.infinity, Utils.vSize(45.0)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Botón "Cancel"
                      Expanded(
                        child: PrimaryButton(
                          text: 'Cancel',
                          onPressed: () => Navigator.of(context).pop(),
                          bgColor: redColor,
                          borderRadiusSize: 8.0,
                          minimumSize: Size(double.infinity, Utils.vSize(45.0)),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
