import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

class WeeklyDateSelector extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;
  final Color primaryColor;

  const WeeklyDateSelector({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
    required this.primaryColor,
  });

  @override
  _WeeklyDateSelectorState createState() => _WeeklyDateSelectorState();
}

class _WeeklyDateSelectorState extends State<WeeklyDateSelector> {
  late DateTime selectedDate;
  late DateTime startOfWeek;
  late DateTime endOfWeek;
  late DateTime currentDate;
  final PageController _pageController = PageController(initialPage: 1000);
  int currentWeekOffset = 0;

  @override
  void initState() {
    super.initState();
    currentDate = DateTime.now();
    selectedDate = currentDate; // Día actual seleccionado por defecto
    _updateWeekRange(selectedDate);
  }

  void _updateWeekRange(DateTime date) {
    setState(() {
      startOfWeek = date.subtract(Duration(days: date.weekday % 7));
      endOfWeek = startOfWeek.add(const Duration(days: 6));
    });
  }

  void _changeWeek(int direction) {
    DateTime newDate = selectedDate.add(Duration(days: direction * 7));
    if (!newDate.isBefore(currentDate)) {
      setState(() {
        selectedDate = newDate;
        _updateWeekRange(selectedDate);
        currentWeekOffset += direction;
        _pageController
            .jumpToPage(1000 + currentWeekOffset); // Sincronizar con PageView
      });
    }
  }

  void _changeMonth(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return SizedBox(
          height: 250,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: selectedDate,
            minimumDate: currentDate,
            onDateTimeChanged: (DateTime newDate) {
              setState(() {
                selectedDate = newDate;
                _updateWeekRange(selectedDate);
                widget.onDateSelected(selectedDate);
                currentWeekOffset =
                    ((selectedDate.difference(currentDate).inDays) / 7).round();
                _pageController.jumpToPage(
                    1000 + currentWeekOffset); // Sincronizar con PageView
              });
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _changeMonth(context),
          child: Text(
            DateFormat('MMMM yyyy').format(selectedDate),
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.primaryColor),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 20),
              onPressed: currentWeekOffset > 0 ? () => _changeWeek(-1) : null,
            ),
            Expanded(
              child: SizedBox(
                height: 60,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    int newOffset = index - 1000;
                    if (newOffset >= 0) {
                      setState(() {
                        _changeWeek(newOffset - currentWeekOffset);
                        currentWeekOffset = newOffset;
                      });
                    } else {
                      _pageController.jumpToPage(1000);
                    }
                  },
                  itemBuilder: (context, index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (i) {
                        DateTime day = startOfWeek.add(Duration(days: i));
                        bool isSelected =
                            DateFormat('yyyy-MM-dd').format(day) ==
                                DateFormat('yyyy-MM-dd').format(selectedDate);
                        bool isPast = day.isBefore(currentDate);

                        return GestureDetector(
                          onTap: isPast
                              ? null
                              : () {
                                  setState(() {
                                    selectedDate = day;
                                  });
                                  widget.onDateSelected(day);
                                },
                          child: Column(
                            children: [
                              Text(
                                DateFormat('EEE').format(day),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isPast
                                      ? Colors.grey
                                      : isSelected
                                          ? widget.primaryColor
                                          : Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                DateFormat('d').format(day),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isPast
                                      ? Colors.grey
                                      : isSelected
                                          ? widget.primaryColor
                                          : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: () => _changeWeek(1),
            ),
          ],
        ),
      ],
    );
  }
}
