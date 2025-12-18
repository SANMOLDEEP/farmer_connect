import 'package:cloud_firestore/cloud_firestore.dart';

class FarmingTip {
  final String id;
  final String title;
  final String category;
  final String season;
  final String content;
  final DateTime? addedDate;

  FarmingTip({
    required this.id,
    required this.title,
    required this.category,
    required this.season,
    required this.content,
    this.addedDate,
  });

  factory FarmingTip.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final Timestamp? ts = data['addedDate'] as Timestamp?;
    return FarmingTip(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? 'All',
      season: data['season'] ?? 'All',
      content: data['content'] ?? '',
      addedDate: ts?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'season': season,
      'content': content,
      'addedDate': addedDate != null
          ? Timestamp.fromDate(addedDate!)
          : FieldValue.serverTimestamp(),
    };
  }
}
