class CategoryModel {
  final String id;
  final String title;
  final String? description;
  final int order;
  final bool isPremium;
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.title,
    this.description,
    required this.order,
    this.isPremium = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'order': order,
      'isPremium': isPremium,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'],
      order: map['order'] ?? 0,
      isPremium: map['isPremium'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
