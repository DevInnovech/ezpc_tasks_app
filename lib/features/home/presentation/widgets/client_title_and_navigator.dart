import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:flutter/material.dart';

class ClientTitleAndNavigator extends StatelessWidget {
  const ClientTitleAndNavigator({
    super.key,
    required this.title,
    required this.press,
  });
  final String title;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: press,
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: textColor,
                fontSize: 22,
                fontFamily: 'Work Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Text(
              'See All',
              style: TextStyle(
                color: Color(0xFF2969FF),
                fontSize: 14,
                fontFamily: 'Work Sans',
                fontWeight: FontWeight.w500,
                height: 1.43,
              ),
            ),
            Utils.horizontalSpace(6),
            const Icon(Icons.arrow_forward, color: primaryColor),
          ],
        ),
      ),
    );
  }
}
