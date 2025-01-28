import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
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
  String? sameDayFilter; // Null initially to show "Date"
  bool isSameDaySelected = false; // Checkbox state for Same Day filter

  String? priceFilter; // Null initially to show "Price"
  bool isPriceFilterSelected = false; // Checkbox state for price filter

  String starRating = '4.7'; // Default rating filter
  bool isStarFilterSelected = false; // Checkbox state for star filter

  bool showMoreFilters = false;
  Map<String, bool> extendedFilters = {
    "Option 1": false,
    "Option 2": false,
    "Option 3": false,
  };

  void _applyFilters() {
    Map<String, dynamic> selectedFilters = {};

    // Include Same Day filter if selected
    if (isSameDaySelected && sameDayFilter != null) {
      selectedFilters['Date'] = sameDayFilter;
    }

    // Include price filter if selected
    if (isPriceFilterSelected && priceFilter != null) {
      selectedFilters['Price'] = priceFilter;
    }

    // Include star filter if selected
    if (isStarFilterSelected) {
      selectedFilters['Rating'] = starRating;
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Main options (Date, Price, Rating)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Enable horizontal scrolling
            child: Row(
              children: [
                _buildSameDayOption(), // Custom method for "Same Day" filter
                const SizedBox(width: 12),
                _buildPriceOption(), // Custom method for price filter
                const SizedBox(width: 12),
                _buildStarOption(), // Custom method for star filter
                const SizedBox(width: 12),
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
          ),
          // Show extended filters if expanded
          if (showMoreFilters)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                children: extendedFilters.keys.map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _buildExtendedOption(filter),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  // Custom "Same Day" filter with dropdown menu
  Widget _buildSameDayOption() {
    return Row(
      children: [
        _buildCustomCheckBox(isSameDaySelected, (value) {
          setState(() {
            isSameDaySelected = value; // Toggle checkbox state
          });
          _applyFilters();
        }),
        const SizedBox(width: 6),
        DropdownButton<String>(
          value: sameDayFilter,
          hint: const Text('Date', style: TextStyle(fontSize: 14)),
          icon: const Icon(Icons.arrow_drop_down),
          underline: const SizedBox(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                sameDayFilter = newValue; // Update the selected date filter
              });
            }
          },
          items: ['Same Day', 'Last Week', 'Last Month']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Custom price filter with dropdown menu
  Widget _buildPriceOption() {
    return Row(
      children: [
        _buildCustomCheckBox(isPriceFilterSelected, (value) {
          setState(() {
            isPriceFilterSelected = value; // Toggle checkbox state
          });
          _applyFilters();
        }),
        const SizedBox(width: 6),
        DropdownButton<String>(
          value: priceFilter,
          hint: const Text('Price', style: TextStyle(fontSize: 14)),
          icon: const Icon(Icons.arrow_drop_down),
          underline: const SizedBox(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                priceFilter = newValue; // Update the selected price filter
              });
            }
          },
          items: ['Lowest', 'Highest']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Custom star filter with dropdown menu
  Widget _buildStarOption() {
    return Row(
      children: [
        _buildCustomCheckBox(isStarFilterSelected, (value) {
          setState(() {
            isStarFilterSelected = value; // Toggle checkbox state
          });
          _applyFilters();
        }),
        const SizedBox(width: 6),
        DropdownButton<String>(
          value: starRating,
          icon: const Icon(Icons.arrow_drop_down),
          underline: const SizedBox(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                starRating = newValue; // Update the selected rating
              });
            }
          },
          items: ['4.7', '4.5', '4.0', '3.5']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 16),
                  const SizedBox(width: 4),
                  Text(value, style: const TextStyle(fontSize: 14)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Extended filter option with more spacing
  Widget _buildExtendedOption(String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          extendedFilters[label] = !extendedFilters[label]!;
        });
        _applyFilters();
      },
      child: Row(
        children: [
          _buildCustomCheckBox(extendedFilters[label]!, (value) {
            setState(() {
              extendedFilters[label] = value;
            });
            _applyFilters();
          }),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.black)),
        ],
      ),
    );
  }

  // Custom round checkbox widget
  Widget _buildCustomCheckBox(bool value, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child: Container(
        width: 20,
        height: 20,
        padding: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border:
              Border.all(color: value ? primaryColor : Colors.grey, width: 2),
        ),
        child: value
            ? Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor,
                ),
              )
            : const SizedBox(),
      ),
    );
  }
}
