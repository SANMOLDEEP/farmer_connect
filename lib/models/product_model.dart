import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String cropName;
  final String category;
  final double pricePerKg;
  final double quantityAvailable;
  final String unit;
  final String description;
  final String imageUrl;
  final String sellerName;
  final String sellerPhone;
  final String location;
  final DateTime postedDate;
  final bool isAvailable;
  final String? whatsappNumber;

  Product({
    required this.id,
    required this.cropName,
    required this.category,
    required this.pricePerKg,
    required this.quantityAvailable,
    required this.unit,
    required this.description,
    required this.imageUrl,
    required this.sellerName,
    required this.sellerPhone,
    required this.location,
    required this.postedDate,
    this.isAvailable = true,
    this.whatsappNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'cropName': cropName,
      'category': category,
      'pricePerKg': pricePerKg,
      'quantityAvailable': quantityAvailable,
      'unit': unit,
      'description': description,
      'imageUrl': imageUrl,
      'sellerName': sellerName,
      'sellerPhone': sellerPhone,
      'location': location,
      'postedDate': Timestamp.fromDate(postedDate),
      'isAvailable': isAvailable,
      'whatsappNumber': whatsappNumber,
    };
  }

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      cropName: data['cropName'] ?? '',
      category: data['category'] ?? '',
      pricePerKg: (data['pricePerKg'] ?? 0).toDouble(),
      quantityAvailable: (data['quantityAvailable'] ?? 0).toDouble(),
      unit: data['unit'] ?? 'kg',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      sellerName: data['sellerName'] ?? '',
      sellerPhone: data['sellerPhone'] ?? '',
      location: data['location'] ?? '',
      postedDate: (data['postedDate'] as Timestamp).toDate(),
      isAvailable: data['isAvailable'] ?? true,
      whatsappNumber: data['whatsappNumber'],
    );
  }
}