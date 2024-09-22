import 'package:ezpc_tasks_app/shared/widgets/customcheckbox.dart';
import 'package:flutter/material.dart';

import 'package:ezpc_tasks_app/shared/widgets/customcheckbox.dart';
import 'package:flutter/material.dart';

class GenericFilterWidget extends StatefulWidget {
  final Function(Map<String, dynamic>? selectedFilters) onFilterSelected;

  const GenericFilterWidget({
    super.key,
    required this.onFilterSelected,
  });

  @override
  _GenericFilterWidgetState createState() => _GenericFilterWidgetState();
}

class _GenericFilterWidgetState extends State<GenericFilterWidget> {
  String? _selectedOption;
  double? _selectedRating;
  bool showMoreFilters = false;
  Map<String, bool> extendedFilters = {
    "Option 1": false,
    "Option 2": false,
    "Option 3": false,
  };

  void _applyFilters() {
    Map<String, dynamic> selectedFilters = {};

    if (_selectedOption != null) {
      selectedFilters['option'] = _selectedOption;
    }
    if (_selectedRating != null) {
      selectedFilters['rating'] = _selectedRating;
    }

    // Include extended filters if any are selected
    if (extendedFilters.values.contains(true)) {
      selectedFilters['extendedFilters'] = extendedFilters;
    }

    if (selectedFilters.isEmpty) {
      widget.onFilterSelected(null);
    } else {
      widget.onFilterSelected(selectedFilters);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedOption = 'Same Day';
                });
                _applyFilters();
              },
              child: Row(
                children: [
                  Radio<String>(
                    value: 'Same Day',
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value;
                      });
                      _applyFilters();
                    },
                  ),
                  const Text('Same Day'),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedOption = 'Price: Lowest';
                });
                _applyFilters();
              },
              child: Row(
                children: [
                  Radio<String>(
                    value: 'Price: Lowest',
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value;
                      });
                      _applyFilters();
                    },
                  ),
                  const Text('Price: Lowest'),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRating = 4.7;
                });
                _applyFilters();
              },
              child: Row(
                children: [
                  Radio<double>(
                    value: 4.7,
                    groupValue: _selectedRating,
                    onChanged: (value) {
                      setState(() {
                        _selectedRating = value;
                      });
                      _applyFilters();
                    },
                  ),
                  const Icon(Icons.star, color: Colors.orange),
                  const Text('+4.7'),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {
                setState(() {
                  showMoreFilters = !showMoreFilters;
                });
              },
            ),
          ],
        ),
        if (showMoreFilters)
          Column(
            children: extendedFilters.keys.map((filter) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    extendedFilters[filter] = !extendedFilters[filter]!;
                    _applyFilters();
                  });
                },
                child: Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: extendedFilters[filter],
                      onChanged: (value) {
                        setState(() {
                          extendedFilters[filter] = value ?? false;
                        });
                        _applyFilters();
                      },
                    ),
                    Text(filter),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
