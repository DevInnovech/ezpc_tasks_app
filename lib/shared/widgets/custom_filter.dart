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

    // Incluir filtro para "Same Day"
    if (_selectedOptions['Same Day'] == true) {
      selectedFilters['onDemand'] =
          true; // Filtrar por providers con onDemand: true
    }

    // Incluir filtro para precio más bajo
    if (_selectedOptions['Price: Lowest'] == true) {
      selectedFilters['Lowest'] = true; // Filtrar por precio más bajo
    }

    // Incluir filtro para calificación
    if (_selectedOptions['+4.7'] == true) {
      selectedFilters['averageRating'] = [
        true,
        4.7
      ]; // Filtrar por calificación mayor o igual a 4.7
    }

    // Incluir filtros extendidos si están seleccionados
    if (extendedFilters.values.contains(true)) {
      selectedFilters['extendedFilters'] = extendedFilters;
    }

    // Enviar filtros o null si no hay ninguno seleccionado
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
          // Opciones principales (Same Day, Price: Lowest, +4.7)
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

          // Mostrar filtros extendidos si está expandido
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

  // Construcción de una opción principal (Same Day, Price: Lowest, etc.)
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

  // Construcción de una opción extendida
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

  // Checkbox personalizado
  Widget _buildCustomCheckBox(bool value, Function(bool) onChanged) {
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
