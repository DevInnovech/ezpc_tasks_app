import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:flutter/material.dart';

import 'custom_text.dart';

class CustomForm extends StatelessWidget {
  final String label;
  final Widget child;
  final double bottomSpace;

  const CustomForm({
    super.key,
    required this.label,
    required this.child,
    this.bottomSpace = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: label,
          color: blackColor.withOpacity(0.9),
        ),
        Utils.verticalSpace(10.0),
        child,
        Utils.verticalSpace(bottomSpace),
      ],
    );
  }
}
