import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import '../models/subcategory_model.dart';
import '../models/study_material_model.dart';

class CategoryProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadCategories() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('categories')
          .orderBy('order')
          .get();

      _categories = snapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading categories: $e');
    }
  }

  Stream<List<SubcategoryModel>> getSubcategories(String categoryId) {
    return _firestore
        .collection('subcategories')
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) {
          final subcategories = snapshot.docs
              .map((doc) => SubcategoryModel.fromMap(doc.data(), doc.id))
              .toList();
          // Sort in memory instead of using orderBy
          subcategories.sort((a, b) => a.order.compareTo(b.order));
          return subcategories;
        });
  }

  // Get subcategories by parent (category or subcategory) - handles both old and new data
  Stream<List<SubcategoryModel>> getSubcategoriesByParent(String parentType, String parentId) {
    return _firestore
        .collection('subcategories')
        .snapshots()
        .map((snapshot) {
          final subcategories = snapshot.docs
              .map((doc) => SubcategoryModel.fromMap(doc.data(), doc.id))
              .where((subcat) {
                // Handle new structure
                if (subcat.parentType == parentType && subcat.parentId == parentId) {
                  return true;
                }
                // Handle old structure (backward compatibility)
                if (parentType == 'category' && subcat.categoryId == parentId) {
                  return true;
                }
                return false;
              })
              .toList();
          subcategories.sort((a, b) => a.order.compareTo(b.order));
          return subcategories;
        });
  }

  Stream<List<StudyMaterialModel>> getStudyMaterials(String subcategoryId) {
    return _firestore
        .collection('studyMaterials')
        .where('subcategoryId', isEqualTo: subcategoryId)
        .snapshots()
        .map((snapshot) {
          final materials = snapshot.docs
              .map((doc) => StudyMaterialModel.fromMap(doc.data(), doc.id))
              .toList();
          // Sort in memory instead of using orderBy
          materials.sort((a, b) => a.order.compareTo(b.order));
          return materials;
        });
  }
}
