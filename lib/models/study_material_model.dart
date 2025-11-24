class StudyMaterialModel {
  final String id;
  final String subcategoryId;
  final String title;
  final String? description;
  final String pdfUrl;
  final List<String> imageUrls; // New: Support for multiple images
  final int order;
  final DateTime createdAt;
  final bool isAdFree; // New: Ad-free option

  StudyMaterialModel({
    required this.id,
    required this.subcategoryId,
    required this.title,
    this.description,
    required this.pdfUrl,
    this.imageUrls = const [],
    required this.order,
    required this.createdAt,
    this.isAdFree = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subcategoryId': subcategoryId,
      'title': title,
      'description': description,
      'pdfUrl': pdfUrl,
      'imageUrls': imageUrls,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
      'isAdFree': isAdFree,
    };
  }

  factory StudyMaterialModel.fromMap(Map<String, dynamic> map, String id) {
    return StudyMaterialModel(
      id: id,
      subcategoryId: map['subcategoryId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      pdfUrl: map['pdfUrl'] ?? '',
      imageUrls: map['imageUrls'] != null 
          ? List<String>.from(map['imageUrls']) 
          : [],
      order: map['order'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
      isAdFree: map['isAdFree'] ?? false,
    );
  }
}
