import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String name;
  final String? phoneNumber;
  final String? location;
  final String role; // 'user' or 'admin'
  final DateTime createdAt;
  final String? avatarUrl;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.location,
    this.role = 'user',
    required this.createdAt,
    this.avatarUrl,
  });

  bool get isAdmin => role == 'admin';

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'],
      location: data['location'],
      role: data['role'] ?? 'user',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      avatarUrl: data['avatarUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'location': location,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'avatarUrl': avatarUrl,
    };
  }

  // Get initials for avatar
  String get initials {
    List<String> parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}