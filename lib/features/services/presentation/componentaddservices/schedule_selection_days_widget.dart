import 'package:ezpc_tasks_app/features/services/data/add_repository.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/widgets/customcheckbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DaysSelector extends ConsumerWidget {
  const DaysSelector(
      {super.key,
      required List<String> initialSelection,
      required Null Function(List<String> selectedDays) onDaysSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDays = ref.watch(selectedDaysProvider);

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: scaffoldBgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          title: const Text(
            'Days',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          childrenPadding: EdgeInsets.zero,
          tilePadding: EdgeInsets.zero,
          collapsedIconColor: primaryColor,
          iconColor: primaryColor,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomCheckboxListTile(
                        title: 'Monday',
                        value: selectedDays.contains('Monday'),
                        onChanged: (bool? value) {
                          _toggleDaySelection(ref, 'Monday', value);
                        },
                        activeColor: primaryColor,
                        checkColor: Colors.white,
                        titleColor: Colors.grey,
                      ),
                      CustomCheckboxListTile(
                        title: 'Tuesday',
                        value: selectedDays.contains('Tuesday'),
                        onChanged: (bool? value) {
                          _toggleDaySelection(ref, 'Tuesday', value);
                        },
                        activeColor: primaryColor,
                        checkColor: Colors.white,
                        titleColor: Colors.grey,
                      ),
                      CustomCheckboxListTile(
                        title: 'Wednesday',
                        value: selectedDays.contains('Wednesday'),
                        onChanged: (bool? value) {
                          _toggleDaySelection(ref, 'Wednesday', value);
                        },
                        activeColor: primaryColor,
                        checkColor: Colors.white,
                        titleColor: Colors.grey,
                      ),
                      CustomCheckboxListTile(
                        title: 'Thursday',
                        value: selectedDays.contains('Thursday'),
                        onChanged: (bool? value) {
                          _toggleDaySelection(ref, 'Thursday', value);
                        },
                        activeColor: primaryColor,
                        checkColor: Colors.white,
                        titleColor: Colors.grey,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomCheckboxListTile(
                        title: 'Friday',
                        value: selectedDays.contains('Friday'),
                        onChanged: (bool? value) {
                          _toggleDaySelection(ref, 'Friday', value);
                        },
                        activeColor: primaryColor,
                        checkColor: Colors.white,
                        titleColor: Colors.grey,
                      ),
                      CustomCheckboxListTile(
                        title: 'Saturday',
                        value: selectedDays.contains('Saturday'),
                        onChanged: (bool? value) {
                          _toggleDaySelection(ref, 'Saturday', value);
                        },
                        activeColor: primaryColor,
                        checkColor: Colors.white,
                        titleColor: Colors.grey,
                      ),
                      CustomCheckboxListTile(
                        title: 'Sunday',
                        value: selectedDays.contains('Sunday'),
                        onChanged: (bool? value) {
                          _toggleDaySelection(ref, 'Sunday', value);
                        },
                        activeColor: primaryColor,
                        checkColor: Colors.white,
                        titleColor: Colors.grey,
                      ),
                      CustomCheckboxListTile(
                        title: 'All days',
                        value: selectedDays.contains('All days'),
                        onChanged: (bool? value) {
                          _toggleDaySelection(ref, 'All days', value);
                          if (value == true) {
                            ref.read(selectedDaysProvider.notifier).state = [
                              'Monday',
                              'Tuesday',
                              'Wednesday',
                              'Thursday',
                              'Friday',
                              'Saturday',
                              'Sunday',
                              'All days'
                            ];
                          }
                        },
                        activeColor: primaryColor,
                        checkColor: Colors.white,
                        titleColor: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleDaySelection(WidgetRef ref, String day, bool? isSelected) {
    final selectedDays = ref.read(selectedDaysProvider.notifier).state;
    if (isSelected == true) {
      ref.read(selectedDaysProvider.notifier).state = [...selectedDays, day];
    } else {
      ref.read(selectedDaysProvider.notifier).state =
          selectedDays.where((d) => d != day).toList();
    }
  }
}
