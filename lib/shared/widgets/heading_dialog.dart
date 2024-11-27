import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:flutter/material.dart';

import 'custom_text.dart';

class DialogHeading extends StatelessWidget {
  const DialogHeading({
    super.key,
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              text: title,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: blackColor,
            ),
            GestureDetector(
              onTap: onTap,
              child: Container(
                height: Utils.vSize(35.0),
                width: Utils.hSize(35.0),
                alignment: Alignment.center,
                //padding: Utils.only(bottom: 10.0),
                decoration: BoxDecoration(
                  borderRadius: Utils.borderRadius(r: 8.0),
                  border: Border.all(color: grayColor.withOpacity(0.5)),
                ),
                child: const Icon(Icons.clear),
              ),
            ),
          ],
        ),
        Container(
          height: 1.0,
          color: grayColor.withOpacity(0.2),
          margin: Utils.symmetric(h: 0.0, v: 12.0),
        ),
      ],
    );
  }
}
