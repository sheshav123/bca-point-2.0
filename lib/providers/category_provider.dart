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
    debugPrint('🔍 Loading subcategories for $parentType: $parentId');
    
    return _firestore
        .collection('subcategories')
        .snapshots()
        .map((snapshot) {
          debugPrint('📊 Total subcategories in DB: ${snapshot.docs.length}');
          
          final allSubcategories = snapshot.docs
              .map((doc) {
                try {
                  final data = doc.data();
                  debugPrint('📄 Doc ${doc.id}: parentType="${data['parentType']}", parentId="${data['parentId']}", categoryId="${data['categoryId']}"');
                  return SubcategoryModel.fromMap(data, doc.id);
                } catch (e) {
                  debugPrint('❌ Error parsing subcategory ${doc.id}: $e');
                  return null;
                }
              })
              .whereType<SubcategoryModel>()
              .toList();
          
          final filtered = allSubcategories.where((subcat) {
            debugPrint('🔎 Checking ${subcat.title}: parentType="${subcat.parentType}" vs "$parentType", parentId="${subcat.parentId}" vs "$parentId"');
            
            // Handle new structure
            if (subcat.parentType == parentType && subcat.parentId == parentId) {
              debugPrint('✅ Match (new): ${subcat.title}');
              return true;
            }
            // Handle old structure (backward compatibility)
            if (parentType == 'category' && subcat.categoryId == parentId) {
              debugPrint('✅ Match (old): ${subcat.title}');
              return true;
            }
            debugPrint('❌ No match for: ${subcat.title}');
            return false;
          }).toList();
          
          debugPrint('✨ Filtered subcategories: ${filtered.length}');
          filtered.sort((a, b) => a.order.compareTo(b.order));
          return filtered;
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
