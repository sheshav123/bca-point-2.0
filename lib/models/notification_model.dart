class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final String audience;
  final DateTime createdAt;
  final bool read;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.audience,
    required this.createdAt,
    this.read = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'audience': audience,
      'createdAt': createdAt.toIso8601String(),
      'read': read,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      type: map['type'] ?? 'announcement',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      audience: map['audience'] ?? 'all',
      createdAt: DateTime.parse(map['createdAt']),
      read: map['read'] ?? false,
    );
  }

  String get icon {
    switch (type) {
      case 'new_category':
        return '🆕';
      case 'new_material':
        return '📄';
      case 'premium':
        return '👑';
      case 'announcement':
        return '📣';
      case 'update':
        return '🔄';
      default:
        return '📢';
    }
  }
}
