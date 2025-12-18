import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommunityPost {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String title;
  final String content;
  final String category;
  final List<String> imageUrls;
  final int likes;
  final int commentsCount;
  final List<String> likedBy;
  final DateTime createdAt;
  final String? location;

  CommunityPost({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar = '',
    required this.title,
    required this.content,
    required this.category,
    this.imageUrls = const [],
    this.likes = 0,
    this.commentsCount = 0,
    this.likedBy = const [],
    required this.createdAt,
    this.location,
  });

  // From Firestore
  factory CommunityPost.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CommunityPost(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      userAvatar: data['userAvatar'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      category: data['category'] ?? 'General',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      likes: data['likes'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      location: data['location'],
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'title': title,
      'content': content,
      'category': category,
      'imageUrls': imageUrls,
      'likes': likes,
      'commentsCount': commentsCount,
      'likedBy': likedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'location': location,
    };
  }
}

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final DateTime createdAt;
  final int likes;
  final List<String> likedBy;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userAvatar = '',
    required this.content,
    required this.createdAt,
    this.likes = 0,
    this.likedBy = const [],
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      postId: data['postId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      userAvatar: data['userAvatar'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
      'likedBy': likedBy,
    };
  }
}

// Categories for posts
class PostCategory {
  static const String all = 'All';
  static const String crops = 'Crops';
  static const String weather = 'Weather';
  static const String diseases = 'Diseases';
  static const String equipment = 'Equipment';
  static const String marketplace = 'Marketplace';
  static const String success = 'Success Stories';
  static const String question = 'Questions';
  static const String general = 'General';

  static List<String> get allCategories => [
    all, crops, weather, diseases, equipment, 
    marketplace, success, question, general
  ];

  // ✅ FIXED - Added quotes around keys
  static Map<String, IconData> get categoryIcons => {
    'Crops': Icons.eco,
    'Weather': Icons.wb_sunny,
    'Diseases': Icons.bug_report,
    'Equipment': Icons.agriculture,
    'Marketplace': Icons.shopping_bag,
    'Success Stories': Icons.emoji_events,
    'Questions': Icons.help_outline,
    'General': Icons.forum,
  };
}