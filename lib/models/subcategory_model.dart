class SubcategoryModel {
  final String id;
  final String? categoryId; // For backward compatibility
  final String parentType; // 'category' or 'subcategory'
  final String parentId;
  final String title;
  final String? description;
  final int order;
  final DateTime createdAt;

  SubcategoryModel({
    required this.id,
    this.categoryId,
    required this.parentType,
    required this.parentId,
    required this.title,
    this.description,
    required this.order,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'parentType': parentType,
      'parentId': parentId,
      'title': title,
      'description': description,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SubcategoryModel.fromMap(Map<String, dynamic> map, String id) {
    // Handle both old and new data structure
    final parentType = map['parentType'] ?? 'category';
    final parentId = map['parentId'] ?? map['categoryId'] ?? '';
    
    return SubcategoryModel(
      id: id,
      categoryId: map['categoryId'], // Keep for backward compatibility
      parentType: parentType,
      parentId: parentId,
      title: map['title'] ?? '',
      description: map['description'],
      order: map['order'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
