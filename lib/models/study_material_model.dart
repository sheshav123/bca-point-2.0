class StudyMaterialModel {
  final String id;
  final String subcategoryId;
  final String title;
  final String? description;
  final String? pdfUrl; // Made optional - can be null if only images
  final List<String> imageUrls; // Support for multiple images
  final int order;
  final DateTime createdAt;
  final bool isAdFree; // Ad-free option

  StudyMaterialModel({
    required this.id,
    required this.subcategoryId,
    required this.title,
    this.description,
    this.pdfUrl, // Optional now
    this.imageUrls = const [],
    required this.order,
    required this.createdAt,
    this.isAdFree = false,
  });

  // Helper to check if material has PDF
  bool get hasPdf => pdfUrl != null && pdfUrl!.isNotEmpty;
  
  // Helper to check if material has images
  bool get hasImages => imageUrls.isNotEmpty;

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
      pdfUrl: map['pdfUrl'], // Can be null
      imageUrls: map['imageUrls'] != null 
          ? List<String>.from(map['imageUrls']) 
          : [],
      order: map['order'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
      isAdFree: map['isAdFree'] ?? false,
    );
  }
}
