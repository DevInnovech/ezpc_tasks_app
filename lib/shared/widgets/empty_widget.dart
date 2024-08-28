import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:flutter/material.dart';

import 'custom_image.dart';
import 'custom_text.dart';

class EmptyWidget extends StatelessWidget {
  EmptyWidget({
    super.key,
    required this.image,
    required this.text,
    this.space = 10.0,
    this.height = 0.0,
  });

  final String image;
  final String text;
  final double space;
  double height;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    height = size.height * 0.6;
    return SliverToBoxAdapter(
      child: SizedBox(
        height: height,
        width: size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomImage(
              path: image,
            ),
            Utils.verticalSpace(space),
            CustomText(text: text, fontSize: 22.0, fontWeight: FontWeight.w700)
          ],
        ),
      ),
    );
  }
}
