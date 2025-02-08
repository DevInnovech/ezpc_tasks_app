import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:flutter/material.dart';

class CustomFilterWidgetCopy extends StatefulWidget {
  final Function(Map<String, dynamic>? selectedFilters) onFilterSelected;

  const CustomFilterWidgetCopy({
    super.key,
    required this.onFilterSelected,
  });

  @override
  _CustomFilterWidgetCopyState createState() => _CustomFilterWidgetCopyState();
}

class _CustomFilterWidgetCopyState extends State<CustomFilterWidgetCopy> {
  final Map<String, bool> _selectedOptionsCopy = {
    'Same Day': false,
    'Price: Lowest': false,
    '+4.7': false,
  };

  bool showMoreFiltersCopy = false;
  Map<String, bool> extendedFiltersCopy = {
    "Option 1": false,
    "Option 2": false,
    "Option 3": false,
  };

  void _applyFiltersCopy() {
    Map<String, dynamic> selectedFiltersCopy = {};

    if (_selectedOptionsCopy['Same Day'] == true) {
      selectedFiltersCopy['onDemand'] = true;
    }

    if (_selectedOptionsCopy['Price: Lowest'] == true) {
      selectedFiltersCopy['Lowest'] = true;
    }

    if (_selectedOptionsCopy['+4.7'] == true) {
      selectedFiltersCopy['averageRating'] = [
        true,
        4.7
      ]; // Se agrega correctamente
    }

    if (extendedFiltersCopy.values.contains(true)) {
      selectedFiltersCopy['extendedFilters'] = extendedFiltersCopy;
    }

    widget.onFilterSelected(
        selectedFiltersCopy.isEmpty ? null : selectedFiltersCopy);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMainOptionCopy('Same Day'),
              _buildMainOptionCopy('Price: Lowest'),
              _buildMainOptionCopy('+4.7',
                  icon: Icon(
                    Icons.star,
                    color: _selectedOptionsCopy['+4.7'] == true
                        ? Colors.orangeAccent
                        : Colors.orange,
                    size: _selectedOptionsCopy['+4.7'] == true ? 28 : 24,
                  )),
              IconButton(
                icon: const Icon(Icons.more_horiz),
                onPressed: () {
                  setState(() {
                    showMoreFiltersCopy = !showMoreFiltersCopy;
                  });
                },
              ),
            ],
          ),
          if (showMoreFiltersCopy)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                children: extendedFiltersCopy.keys.map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _buildExtendedOptionCopy(filter),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainOptionCopy(String label, {Widget? icon}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOptionsCopy[label] = !_selectedOptionsCopy[label]!;
        });
        _applyFiltersCopy();
      },
      child: Row(
        children: [
          _buildCustomCheckBoxCopy(_selectedOptionsCopy[label]!, (value) {
            setState(() {
              _selectedOptionsCopy[label] = value;
            });
            _applyFiltersCopy();
          }),
          const SizedBox(width: 6),
          Row(
            children: [
              icon ?? const SizedBox(),
              const SizedBox(width: 4),
              Text(label,
                  style: const TextStyle(fontSize: 14, color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExtendedOptionCopy(String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          extendedFiltersCopy[label] = !extendedFiltersCopy[label]!;
        });
        _applyFiltersCopy();
      },
      child: Row(
        children: [
          _buildCustomCheckBoxCopy(extendedFiltersCopy[label]!, (value) {
            setState(() {
              extendedFiltersCopy[label] = value;
            });
            _applyFiltersCopy();
          }),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildCustomCheckBoxCopy(bool value, Function(bool) onChanged) {
    return Container(
      width: 20,
      height: 20,
      padding: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: value ? primaryColor : Colors.grey, width: 2),
      ),
      child: GestureDetector(
        onTap: () {
          onChanged(!value);
        },
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
