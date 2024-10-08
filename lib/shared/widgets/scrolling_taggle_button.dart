import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:flutter/material.dart';

import 'custom_text.dart';

class ToggleButtonScrollComponent extends StatefulWidget
    implements PreferredSizeWidget {
  const ToggleButtonScrollComponent({
    Key? key,
    required this.onChange,
    required this.textList,
    this.initialLabelIndex = 0,
  }) : super(key: key);

  final void Function(int index) onChange;
  final int initialLabelIndex;
  final List<String> textList;

  @override
  State<ToggleButtonScrollComponent> createState() =>
      _ToggleButtonScrollComponentState();

  @override
  @override
  Size get preferredSize => Size.fromHeight(Utils.vSize(50.0));
}

class _ToggleButtonScrollComponentState
    extends State<ToggleButtonScrollComponent> {
  late int initialLabelIndex;
  late List<String> textList;

  @override
  void initState() {
    super.initState();
    initialLabelIndex = widget.initialLabelIndex;
    textList = widget.textList;
  }

  List<Widget> getButtons() {
    final childList = <Widget>[];
    textList.asMap().forEach(
      (key, value) {
        childList.add(_buildSingleBtn(key, value));
      },
    );
    return childList;
  }

  Widget _buildSingleBtn(int key, String value) {
    return GestureDetector(
      onTap: () => setState(() {
        initialLabelIndex = key;
        widget.onChange(initialLabelIndex);
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        padding: Utils.symmetric(v: 10.0, h: 16.0),
        margin: Utils.only(
            right: key == textList.length - 1 ? 20.0 : 12.0,
            left: key == 0 ? 20.0 : 0.0),
        decoration: BoxDecoration(
            color: initialLabelIndex == key ? primaryColor : transparent,
            borderRadius: Utils.borderRadius(r: 8.0),
            border: Border.all(color: primaryColor)),
        child: CustomText(
          text: value,
          color: initialLabelIndex == key ? whiteColor : primaryColor,
          fontWeight: FontWeight.w500,
          fontSize: 14.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: Utils.borderRadius(),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: getButtons(),
        ),
      ),
    );
  }
}
