import 'package:flutter/material.dart';
import '../../models/crop_model.dart';

class CropDetailScreen extends StatelessWidget {
  final CropInfo crop;

  const CropDetailScreen({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                crop.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(offset: Offset(0, 1), blurRadius: 3, color: Colors.black45),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  crop.imageUrl.startsWith('http')
                    ? Image.network(
                        crop.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.green[200],
                            child: const Icon(Icons.eco, size: 80, color: Colors.white),
                          );
                        },
                      )
                    : Image.asset(
                        crop.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.green[200],
                            child: const Icon(Icons.eco, size: 80, color: Colors.white),
                          );
                        },
                      ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Scientific name
                  Text(
                    crop.scientificName,
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick facts
                  _buildSection(
                    'Quick Facts',
                    Icons.info,
                    Column(
                      children: [
                        _buildInfoRow(Icons.wb_sunny, 'Season', crop.season),
                        _buildInfoRow(Icons.access_time, 'Duration', crop.duration),
                        _buildInfoRow(Icons.thermostat, 'Temperature', crop.temperature),
                        _buildInfoRow(Icons.water_drop, 'Rainfall', crop.rainfall),
                        _buildInfoRow(Icons.agriculture, 'Yield/Acre', crop.yieldPerAcre),
                      ],
                    ),
                  ),

                  // Soil & Water
                  _buildSection(
                    'Soil & Water Requirements',
                    Icons.terrain,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBulletPoint('Soil Type', crop.soilType),
                        const SizedBox(height: 8),
                        _buildBulletPoint('Water', crop.waterRequirement),
                      ],
                    ),
                  ),

                  // Cultivation steps
                  _buildSection(
                    'Cultivation Steps',
                    Icons.list_alt,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: crop.cultivationSteps
                          .asMap()
                          .entries
                          .map((entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.green,
                                      child: Text(
                                        '${entry.key + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        entry.value,
                                        style: const TextStyle(height: 1.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),

                  // Fertilizers
                  _buildSection(
                    'Fertilizer Requirements',
                    Icons.science,
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: crop.fertilizers
                          .map((fert) => Chip(
                                label: Text(fert, style: const TextStyle(fontSize: 12)),
                                backgroundColor: Colors.orange[50],
                                side: BorderSide(color: Colors.orange[300]!),
                              ))
                          .toList(),
                    ),
                  ),

                  // Diseases - ✅ FIXED VERSION
                  _buildSection(
                    'Common Diseases & Management',
                    Icons.bug_report,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: crop.diseases
                          .map((disease) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 2),
                                      child: Icon(
                                        Icons.warning, 
                                        size: 18, 
                                        color: Colors.red
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(  // ✅ Fixed overflow
                                      child: Text(
                                        disease,
                                        style: const TextStyle(height: 1.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Flexible(  // ✅ Added Flexible to prevent title overflow
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              content,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.green[700]),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
              maxLines: 3,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black87, height: 1.4),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}