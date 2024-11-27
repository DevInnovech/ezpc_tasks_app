import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class CustomSliverAppBar extends StatelessWidget {
  const CustomSliverAppBar({super.key, required this.title, this.height = 80.0});
  final double height;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: scaffoldBgColor,
      automaticallyImplyLeading: false,
      toolbarHeight: Utils.vSize(height),
      pinned: true,
      title: CustomAppBar(title: title),
    );
  }
}
