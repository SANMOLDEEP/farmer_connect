import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../models/equipment_model.dart';

class EquipmentDetailScreen extends StatelessWidget {
  final Equipment equipment;

  const EquipmentDetailScreen({super.key, required this.equipment});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    final Uri launchUri = Uri.parse('https://wa.me/+91$phoneNumber');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildEquipmentImage(String imageUrl) {
    try {
      if (imageUrl.length > 100) {
        return Image.memory(
          base64Decode(imageUrl),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.agriculture, size: 50),
          ),
        );
      }
      return Container(
        color: Colors.grey[300],
        child: const Icon(Icons.agriculture, size: 50),
      );
    } catch (e) {
      return Container(
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, size: 50),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildEquipmentImage(equipment.imageUrl),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          equipment.equipmentName,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Chip(
                        label: Text(equipment.condition),
                        backgroundColor: _getConditionColor(equipment.condition),
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Text(
                    '${equipment.category} • ${equipment.yearOfManufacture}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),

                  const SizedBox(height: 16),

                  // Pricing card
                  Card(
                    elevation: 2,
                    color: Colors.brown[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text('Rental Price', style: TextStyle(color: Colors.grey[700])),
                              const SizedBox(height: 4),
                              Text(
                                '₹${equipment.pricePerDay.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown[800],
                                ),
                              ),
                              Text('per day', style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                          if (equipment.pricePerHour != null)
                            Column(
                              children: [
                                Text('Or', style: TextStyle(color: Colors.grey[700])),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${equipment.pricePerHour!.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                                Text('per hour', style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (equipment.description.isNotEmpty) ...[
                    const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      equipment.description,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (equipment.specifications.isNotEmpty) ...[
                    const Text('Specifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      equipment.specifications,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
                    ),
                    const SizedBox(height: 24),
                  ],

                  const Text('Owner Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow(Icons.person, 'Name', equipment.ownerName),
                          const Divider(),
                          _buildInfoRow(Icons.phone, 'Phone', equipment.ownerPhone),
                          const Divider(),
                          _buildInfoRow(Icons.location_on, 'Location', equipment.location),
                          const Divider(),
                          _buildInfoRow(
                            Icons.calendar_today,
                            'Posted',
                            DateFormat('MMM dd, yyyy').format(equipment.postedDate),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _makePhoneCall(equipment.ownerPhone),
                  icon: const Icon(Icons.phone),
                  label: const Text('Call Owner'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openWhatsApp(equipment.whatsappNumber ?? equipment.ownerPhone),
                  icon: const Icon(Icons.chat),
                  label: const Text('WhatsApp'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Text('$label:', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.blue;
      case 'Fair':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}