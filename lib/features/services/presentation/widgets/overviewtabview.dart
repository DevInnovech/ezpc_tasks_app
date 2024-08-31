import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/features/services/models/services_model.dart';

class OverViewTabView extends StatelessWidget {
  const OverViewTabView({super.key, required this.services});

  final ServiceProductStateModel services;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText(
          text: 'About Service',
          fontSize: 22.0,
          fontWeight: FontWeight.w700,
        ),
        Utils.verticalSpace(10.0),
        Html(data: services.details),
        ...List.generate(
          services.benefits.length,
          (index) => Padding(
            padding: Utils.symmetric(h: 0.0).copyWith(top: 5.0),
            child: Row(
              children: [
                Padding(
                  padding: Utils.only(top: 2.0),
                  child: const Icon(
                    Icons.check_circle,
                    color: primaryColor,
                    size: 18.0,
                  ),
                ),
                Utils.horizontalSpace(4.0),
                CustomText(
                  text: services.benefits[index],
                  color: grayColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
