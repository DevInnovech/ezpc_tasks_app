import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:flutter/material.dart';

class SingleExpansionTile extends StatefulWidget {
  const SingleExpansionTile({
    Key? key,
    this.isExpand = false,
    this.heading = 'Include Service',
    required this.child,
  }) : super(key: key);
  final bool isExpand;
  final String heading;
  final Widget child;

  @override
  State<SingleExpansionTile> createState() => _SingleExpansionTileState();
}

class _SingleExpansionTileState extends State<SingleExpansionTile> {
  bool itemExpand = false;

  @override
  Widget build(BuildContext context) {
    //const color = Color(0xFFE3E3E3);
    print('item-expand $itemExpand');
    return Container(
      width: double.infinity,
      // alignment: Alignment.centerLeft,
      margin: Utils.symmetric(h: 16.0, v: 5.0).copyWith(bottom: 2.0),
      decoration: BoxDecoration(
        color: whiteColor,
        border: Border.all(color: grayColor.withOpacity(0.2)),
        borderRadius: Utils.borderRadius(),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: transparent),
        child: ExpansionTile(
          // expandedAlignment: Alignment.centerLeft,
          onExpansionChanged: (bool expand) {
            print('expanded $expand');
            setState(() => itemExpand = expand);
          },
          initiallyExpanded: widget.isExpand,
          tilePadding: Utils.symmetric(h: 16.0),
          childrenPadding: Utils.symmetric(h: 16.0),
          title: CustomText(
            text: widget.heading,
            color: blackColor,
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
          children: [
            widget.child,
          ],
        ),
      ),
    );
  }
}
