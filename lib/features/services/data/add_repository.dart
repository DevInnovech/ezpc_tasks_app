import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/features/services/presentation/componentaddservices/special_days_widget.dart';

// Proveedor para controlar si la licencia es requerida
final isLicenseRequiredProvider = StateProvider<bool>((ref) {
  return false;
});

// Proveedor para preguntas adicionales basadas en la categoría o subcategoría seleccionada
final questionsProvider = StateProvider<List<String>>((ref) {
  return [
    "Allergic to cleaning products?",
    "Language preference?",
    "Number of levels?"
  ];
});

// Proveedor para los días seleccionados
final selectedDaysProvider = StateProvider<List<String>>((ref) {
  return [];
});

// Proveedor para las horas de trabajo seleccionadas
final workingHoursProvider =
    StateProvider<Map<String, Map<String, String>>>((ref) {
  return {
    "Monday": {"start": "8:00 AM", "end": "8:00 PM"},
    "Tuesday": {"start": "8:00 AM", "end": "8:00 PM"},
    "Wednesday": {"start": "8:00 AM", "end": "8:00 PM"},
    "Thursday": {"start": "8:00 AM", "end": "8:00 PM"},
    "Friday": {"start": "8:00 AM", "end": "8:00 PM"},
    "Saturday": {"start": "8:00 AM", "end": "8:00 PM"},
    "Sunday": {"start": "8:00 AM", "end": "8:00 PM"},
    // "All days" no será parte del estado final.
  };
});

// Proveedor para días especiales habilitados
final specialDaysEnabledProvider = StateProvider<bool>((ref) {
  return false;
});

// Proveedor para días especiales
final specialDaysProvider = StateProvider<List<SpecialDay>>((ref) {
  return [];
});

// Proveedor para controlar si el rate de la categoría se aplica a todas las subcategorías
final isRateAppliedToSubcategoriesProvider = StateProvider<bool>((ref) {
  return false; // Valor inicial
});
