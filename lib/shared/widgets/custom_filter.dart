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
  final Map<String, bool> _selectedOptions = {
    'Same Day': false,
    'Price: Lowest': false,
    '+4.7': false,
  };

  bool showMoreFilters = false;
  Map<String, bool> extendedFilters = {
    "Option 1": false,
    "Option 2": false,
    "Option 3": false,
  };

  void _applyFilters() {
    Map<String, dynamic> selectedFilters = {};

    // Include selected main options
    _selectedOptions.forEach((key, value) {
      if (value) selectedFilters[key] = true;
    });

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
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0), // Add margin to the edges
      child: Column(
        children: [
          // Main options (Same Day, Price: Lowest, +4.7)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMainOption('Same Day'),
              _buildMainOption('Price: Lowest'),
              _buildMainOption('+4.7',
                  icon: const Icon(Icons.star, color: Colors.orange)),
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

          // Show extended filters if expanded
          if (showMoreFilters)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                children: extendedFilters.keys.map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(
                        bottom: 8.0), // Adjust spacing between extended options
                    child: _buildExtendedOption(filter),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  // Main filter option with tighter spacing
  Widget _buildMainOption(String label, {Widget? icon}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOptions[label] = !_selectedOptions[label]!;
        });
        _applyFilters();
      },
      child: Row(
        children: [
          _buildCustomCheckBox(_selectedOptions[label]!, (value) {
            setState(() {
              _selectedOptions[label] = value;
            });
            _applyFilters();
          }),
          const SizedBox(
              width: 6), // Reduced spacing between checkbox and label
          Row(
            children: [
              icon ?? const SizedBox(),
              const SizedBox(width: 4), // Adjusted spacing for visibility
              Text(label,
                  style: const TextStyle(fontSize: 14, color: Colors.black)),
            ],
          ),
        ],
      ),
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
          const SizedBox(
              width: 8), // Adjusted spacing between checkbox and text
          Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.black)),
        ],
      ),
    );
  }

  // Custom round checkbox widget without checkmark (just a filled circle with a border gap)
  Widget _buildCustomCheckBox(bool value, Function(bool) onChanged) {
    return Container(
      width: 20, // Adjusted width for better visibility
      height: 20, // Adjusted height for better visibility
      padding: const EdgeInsets.all(2.0), // Padding to create a border gap
      decoration: BoxDecoration(
        shape: BoxShape.circle, // Circular checkbox
        border:
            Border.all(color: value ? primaryColor : primaryColor, width: 2),
      ),
      child: GestureDetector(
        onTap: () {
          onChanged(!value);
        },
        child: value
            ? Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor, // Fill color when checked
                  border: Border.all(
                      color: Colors.white,
                      width: 2), // Inner border to create a small gap
                ),
              )
            : const SizedBox(), // Empty when unchecked
      ),
    );
  }
}
