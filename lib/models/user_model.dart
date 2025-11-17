class UserModel {
  final String uid;
  final String email;
  final String name;
  final String collegeName;
  final String semester;
  final String? photoUrl;
  final DateTime createdAt;
  final bool adFree;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.collegeName,
    required this.semester,
    this.photoUrl,
    required this.createdAt,
    this.adFree = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'collegeName': collegeName,
      'semester': semester,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'adFree': adFree,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      collegeName: map['collegeName'] ?? '',
      semester: map['semester'] ?? '',
      photoUrl: map['photoUrl'],
      createdAt: DateTime.parse(map['createdAt']),
      adFree: map['adFree'] ?? false,
    );
  }
}
