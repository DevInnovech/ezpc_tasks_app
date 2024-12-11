import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/services/models/category_model.dart';
import 'package:ezpc_tasks_app/features/services/models/subcategory_model.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Category>> getCategories() async {
    try {
      final querySnapshot = await _firestore.collection('categories').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Category(
          id: data['id'],
          name: data['name'],
          pathImage: data['pathImage'],
          subCategories: (data['subCategories'] as List<dynamic>?)!
              .map((subCategory) => SubCategory(
                    additionalOptions:
                        (subCategory['additionalOptions'] as List<dynamic>?)
                                ?.cast<String>() ??
                            [],
                    id: '',
                    name: '',
                  ))
              .toList(),
          categoryId: '',
        );
      }).toList();
    } catch (e) {
      throw Exception('Error loading categories: $e');
    }
  }
}
