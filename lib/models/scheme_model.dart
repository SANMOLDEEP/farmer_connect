import 'package:cloud_firestore/cloud_firestore.dart';

class GovernmentScheme {
  final String id;
  final String schemeName;
  final String category;
  final String description;
  final String benefits;
  final String eligibility;
  final String howToApply;
  final String documentsRequired;
  final String officialWebsite;
  final String contactNumber;
  final bool isActive;
  final DateTime addedDate;

  GovernmentScheme({
    required this.id,
    required this.schemeName,
    required this.category,
    required this.description,
    required this.benefits,
    required this.eligibility,
    required this.howToApply,
    required this.documentsRequired,
    required this.officialWebsite,
    required this.contactNumber,
    this.isActive = true,
    required this.addedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'schemeName': schemeName,
      'category': category,
      'description': description,
      'benefits': benefits,
      'eligibility': eligibility,
      'howToApply': howToApply,
      'documentsRequired': documentsRequired,
      'officialWebsite': officialWebsite,
      'contactNumber': contactNumber,
      'isActive': isActive,
      'addedDate': Timestamp.fromDate(addedDate),
    };
  }

  factory GovernmentScheme.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GovernmentScheme(
      id: doc.id,
      schemeName: data['schemeName'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      benefits: data['benefits'] ?? '',
      eligibility: data['eligibility'] ?? '',
      howToApply: data['howToApply'] ?? '',
      documentsRequired: data['documentsRequired'] ?? '',
      officialWebsite: data['officialWebsite'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      isActive: data['isActive'] ?? true,
      addedDate: data['addedDate'] != null 
          ? (data['addedDate'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}