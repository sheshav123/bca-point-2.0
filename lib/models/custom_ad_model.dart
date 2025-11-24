class CustomAdModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String buttonText;
  final String buttonLink;
  final bool isEnabled;
  final int order;
  final DateTime createdAt;

  CustomAdModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.buttonText,
    required this.buttonLink,
    required this.isEnabled,
    required this.order,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'buttonText': buttonText,
      'buttonLink': buttonLink,
      'isEnabled': isEnabled,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CustomAdModel.fromMap(Map<String, dynamic> map, String id) {
    return CustomAdModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      buttonText: map['buttonText'] ?? 'Click Here',
      buttonLink: map['buttonLink'] ?? '',
      isEnabled: map['isEnabled'] ?? false,
      order: map['order'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
