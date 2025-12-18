import 'package:cloud_firestore/cloud_firestore.dart';

class Equipment {
  final String id;
  final String equipmentName;
  final String category; // Tractor, Harvester, Pump, etc.
  final double pricePerDay;
  final double? pricePerHour;
  final String description;
  final String specifications;
  final String imageUrl;
  final String ownerName;
  final String ownerPhone;
  final String location;
  final DateTime postedDate;
  final bool isAvailable;
  final String? whatsappNumber;
  final int yearOfManufacture;
  final String condition; // Excellent, Good, Fair

  Equipment({
    required this.id,
    required this.equipmentName,
    required this.category,
    required this.pricePerDay,
    this.pricePerHour,
    required this.description,
    required this.specifications,
    required this.imageUrl,
    required this.ownerName,
    required this.ownerPhone,
    required this.location,
    required this.postedDate,
    this.isAvailable = true,
    this.whatsappNumber,
    required this.yearOfManufacture,
    required this.condition,
  });

  Map<String, dynamic> toMap() {
    return {
      'equipmentName': equipmentName,
      'category': category,
      'pricePerDay': pricePerDay,
      'pricePerHour': pricePerHour,
      'description': description,
      'specifications': specifications,
      'imageUrl': imageUrl,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'location': location,
      'postedDate': Timestamp.fromDate(postedDate),
      'isAvailable': isAvailable,
      'whatsappNumber': whatsappNumber,
      'yearOfManufacture': yearOfManufacture,
      'condition': condition,
    };
  }

  factory Equipment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Equipment(
      id: doc.id,
      equipmentName: data['equipmentName'] ?? '',
      category: data['category'] ?? '',
      pricePerDay: (data['pricePerDay'] ?? 0).toDouble(),
      pricePerHour: data['pricePerHour'] != null 
          ? (data['pricePerHour'] as num).toDouble() 
          : null,
      description: data['description'] ?? '',
      specifications: data['specifications'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      ownerName: data['ownerName'] ?? '',
      ownerPhone: data['ownerPhone'] ?? '',
      location: data['location'] ?? '',
      postedDate: (data['postedDate'] as Timestamp).toDate(),
      isAvailable: data['isAvailable'] ?? true,
      whatsappNumber: data['whatsappNumber'],
      yearOfManufacture: data['yearOfManufacture'] ?? DateTime.now().year,
      condition: data['condition'] ?? 'Good',
    );
  }
}