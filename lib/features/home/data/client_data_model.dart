import 'package:ezpc_tasks_app/features/services/models/client_services_models.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashBoardProfileProvider = FutureProvider<DashBoard>((ref) async {
  // Simulación de datos del perfil de usuario
  return DashBoard(
    name: 'John Doe',
    email: 'john.doe@example.com',
    imageUrl: 'https://example.com/profile.jpg',
    totalBookings: 15,
    completedBookings: 12,
    activeBookings: 3,
  );
});

// Clase Dashboard simulada
class DashBoard {
  final String name;
  final String email;
  final String imageUrl;
  final int totalBookings;
  final int completedBookings;
  final int activeBookings;

  DashBoard({
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.totalBookings,
    required this.completedBookings,
    required this.activeBookings,
  });
}

// Simulación del proveedor de lista de servicios
final serviceListProvider =
    FutureProvider<List<ServiceClientModel>>((ref) async {
  // Simulación de lista de servicios para el cliente
  return [
    ServiceClientModel(
      name: 'Home Cleaning',
      slug: 'home-cleaning',
      price: '100.00',
      categoryId: '1',
      subCategoryId: '1.1',
      details: 'Professional home cleaning services.',
      image: KImages.s01,
      packageFeature: ['Eco-friendly', 'Fast service'],
      benefits: ['Free consultation', 'Satisfaction guaranteed'],
      whatYouWillProvide: ['All cleaning materials included'],
      licenseDocument: 'https://example.com/license.pdf',
      workingDays: ['Monday', 'Wednesday', 'Friday'],
      workingHours: [
        {'day': 'Monday', 'from': '08:00 AM', 'to': '05:00 PM'},
        {'day': 'Wednesday', 'from': '09:00 AM', 'to': '06:00 PM'},
        {'day': 'Friday', 'from': '10:00 AM', 'to': '07:00 PM'},
      ],
      specialDays: [
        {'date': '2024-12-25', 'from': '10:00 AM', 'to': '02:00 PM'},
      ],
    ),
    ServiceClientModel(
      name: 'Plumbing Services',
      slug: 'plumbing-services',
      price: '150.00',
      categoryId: '2',
      subCategoryId: '2.1',
      details: 'Expert plumbing services for residential properties.',
      image: KImages.s01,
      packageFeature: ['Certified plumbers', 'Fast response'],
      benefits: ['Emergency service', '1-year warranty'],
      whatYouWillProvide: ['Tools and materials'],
      licenseDocument: 'https://example.com/license.pdf',
      workingDays: ['Tuesday', 'Thursday'],
      workingHours: [
        {'day': 'Tuesday', 'from': '09:00 AM', 'to': '05:00 PM'},
        {'day': 'Thursday', 'from': '09:00 AM', 'to': '05:00 PM'},
      ],
      specialDays: [],
    ),
    ServiceClientModel(
      name: 'Electrical Repair',
      slug: 'electrical-repair',
      price: '200.00',
      categoryId: '3',
      subCategoryId: '3.1',
      details: 'Expert electrical repair services for homes and offices.',
      image: KImages.s01,
      packageFeature: ['24/7 service', 'Licensed technicians'],
      benefits: ['Free safety inspection', '1-year warranty on repairs'],
      whatYouWillProvide: ['All necessary equipment'],
      licenseDocument: 'https://example.com/license.pdf',
      workingDays: ['Monday', 'Wednesday'],
      workingHours: [
        {'day': 'Monday', 'from': '08:00 AM', 'to': '05:00 PM'},
        {'day': 'Wednesday', 'from': '09:00 AM', 'to': '06:00 PM'},
      ],
      specialDays: [],
    ),
  ];
});

final privacyPolicyProvider = FutureProvider<String>((ref) async {
  // Simulación de política de privacidad
  return '''
    Privacy Policy for Our Services:

    We are committed to protecting your privacy. All personal information provided
    will be used in accordance with the law and our privacy policy terms. Your data
    will never be shared with third parties without your consent.
  ''';
});

final faqProvider = FutureProvider<List<Faq>>((ref) async {
  // Simulación de lista de FAQs
  return [
    Faq(
        question: 'How can I book a service?',
        answer: 'You can book a service directly through our app or website.'),
    Faq(
        question: 'What payment methods are accepted?',
        answer: 'We accept credit cards, PayPal, and direct bank transfers.'),
    Faq(
        question: 'Can I cancel a booking?',
        answer:
            'Yes, cancellations are allowed up to 24 hours before the service time.'),
  ];
});

// Clase FAQ simulada
class Faq {
  final String question;
  final String answer;

  Faq({
    required this.question,
    required this.answer,
  });
}
