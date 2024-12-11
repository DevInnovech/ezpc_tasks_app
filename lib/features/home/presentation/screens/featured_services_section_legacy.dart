import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ezpc_tasks_app/features/home/models/service_item.dart';

class FeaturedServicesSection extends StatelessWidget {
  const FeaturedServicesSection({super.key});

  Future<List<ServiceItem>> _fetchFeaturedServices() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('makeFeatured', isEqualTo: 1) // Filtrar servicios destacados
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ServiceItem(
          id: data['id'] != null ? int.tryParse(data['id'].toString()) ?? 0 : 0,
          name: "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}",
          price: (data['price'] != null ? data['price'].toDouble() : 0.0),
          image: data['imageUrl'] ?? '',
          providerId: data['providerId'] ?? '',
          averageRating: data['averageRating'] ?? '0.0',
          slug: '',
          categoryId: data['categoryId'] ?? '',
          makeFeatured: data['makeFeatured'] != null
              ? int.tryParse(data['makeFeatured'].toString()) ?? 0
              : 0,
          isBanned: data['isBanned'] != null
              ? int.tryParse(data['isBanned'].toString()) ?? 0
              : 0,
          status: data['status'] != null
              ? int.tryParse(data['status'].toString()) ?? 0
              : 0,
          details: data['details'] ?? '',
          createdAt: data['createdAt'] ?? '',
          approveByAdmin: data['approveByAdmin'] != null
              ? int.tryParse(data['approveByAdmin'].toString()) ?? 0
              : 0,
          totalReview: data['totalReview'] != null
              ? int.tryParse(data['totalReview'].toString()) ?? 0
              : 0,
          totalOrder: data['totalOrder'] != null
              ? int.tryParse(data['totalOrder'].toString()) ?? 0
              : 0,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error al cargar servicios destacados: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ServiceItem>>(
      future: _fetchFeaturedServices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final services = snapshot.data ?? [];

        if (services.isEmpty) {
          return const Center(child: Text('No featured services available.'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Services',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/all-featured-services');
                    },
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              height: 250, // Altura de la lista de servicios
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return FeaturedServiceCard(service: service);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class FeaturedServiceCard extends StatelessWidget {
  final ServiceItem service;

  const FeaturedServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.network(
              service.image,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              service.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'by ${service.providerId}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${service.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.yellow, size: 16),
                    Text(
                      service.averageRating ?? '0',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Lógica para la acción del botón "Book Now"
              },
              child: const Text('Book Nowss'),
            ),
          ),
        ],
      ),
    );
  }
}
