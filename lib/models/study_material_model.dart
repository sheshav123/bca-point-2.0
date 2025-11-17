class StudyMaterialModel {
  final String id;
  final String subcategoryId;
  final String title;
  final String? description;
  final String pdfUrl;
  final int order;
  final DateTime createdAt;

  StudyMaterialModel({
    required this.id,
    required this.subcategoryId,
    required this.title,
    this.description,
    required this.pdfUrl,
    required this.order,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subcategoryId': subcategoryId,
      'title': title,
      'description': description,
      'pdfUrl': pdfUrl,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StudyMaterialModel.fromMap(Map<String, dynamic> map, String id) {
    return StudyMaterialModel(
      id: id,
      subcategoryId: map['subcategoryId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      pdfUrl: map['pdfUrl'] ?? '',
      order: map['order'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
