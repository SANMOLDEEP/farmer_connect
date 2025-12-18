import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/farming_tip.dart';

class KnowledgeBaseScreen extends StatefulWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  State<KnowledgeBaseScreen> createState() => _KnowledgeBaseScreenState();
}

class _KnowledgeBaseScreenState extends State<KnowledgeBaseScreen> {
  String _selectedCategory = 'All';
  String _selectedSeason = 'All';

  final List<String> _categories = [
    'All',
    'Irrigation',
    'Pest Control',
    'Soil Health',
    'Crop Selection',
    'Harvesting',
    'Storage',
    'Fertilizers',
  ];

  final List<String> _seasons = [
    'All',
    'Kharif',
    'Rabi',
    'Zaid',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Category filter
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.teal[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Browse by Category',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedCategory = category);
                          },
                          selectedColor: Colors.teal[700],
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Season',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _seasons.map((season) {
                      final isSelected = _selectedSeason == season;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(season),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedSeason = season);
                          },
                          selectedColor: Colors.orange[400],
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Tips list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('farming_tips')
                  .orderBy('addedDate', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                // Filter tips
                var tips = snapshot.data!.docs
                    .map((doc) => FarmingTip.fromFirestore(doc))
                    .where((tip) {
                  if (_selectedCategory != 'All' && tip.category != _selectedCategory) {
                    return false;
                  }
                  if (_selectedSeason != 'All' && tip.season != 'All' && tip.season != _selectedSeason) {
                    return false;
                  }
                  return true;
                }).toList();

                if (tips.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tips in this category',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tips.length,
                  itemBuilder: (context, index) {
                    return _buildTipCard(tips[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(FarmingTip tip) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getCategoryColor(tip.category).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(tip.category),
              color: _getCategoryColor(tip.category),
              size: 24,
            ),
          ),
          title: Text(
            tip.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(tip.category).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tip.category,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _getCategoryColor(tip.category),
                    ),
                  ),
                ),
                if (tip.season != 'All') ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tip.season,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                tip.content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No farming tips yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Tips and guides will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addSampleTips,
            icon: const Icon(Icons.add),
            label: const Text('Add Sample Tips'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addSampleTips() async {
    final tips = [
      {
        'title': 'Best Time for Irrigation',
        'category': 'Irrigation',
        'content': 'Water your crops early in the morning (5-8 AM) or late evening (5-7 PM). This reduces water loss due to evaporation by 30-40%. Avoid midday watering as it can cause water stress and fungal diseases. Drip irrigation is most efficient, saving up to 70% water compared to flood irrigation.',
        'season': 'All',
        'addedDate': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Natural Pest Control Methods',
        'category': 'Pest Control',
        'content': 'Use neem oil spray (10ml neem oil + 1 liter water + 2ml liquid soap) to control aphids, whiteflies, and caterpillars. Plant marigold, basil, and mint around crops as natural pest repellents. Introduce beneficial insects like ladybugs and lacewings that eat harmful pests. Maintain crop diversity to prevent pest buildup.',
        'season': 'All',
        'addedDate': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Improve Soil Health Naturally',
        'category': 'Soil Health',
        'content': 'Add organic compost (5-10 tons per hectare) and well-rotted farmyard manure before planting season. Practice crop rotation (legumes → cereals → root crops) to prevent soil nutrient depletion. Use green manure crops like Sunn Hemp, Dhaincha to fix nitrogen naturally. Avoid burning crop residues - mulch them instead to add organic matter.',
        'season': 'All',
        'addedDate': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Kharif Crop Selection Guide',
        'category': 'Crop Selection',
        'content': 'Choose crops based on rainfall in your region:\n\n• High rainfall (>1000mm): Rice, Sugarcane, Jute\n• Medium rainfall (600-1000mm): Cotton, Maize, Soybean, Groundnut\n• Low rainfall (<600mm): Millets (Bajra, Jowar), Pulses (Moong, Urad)\n\nAlways select disease-resistant varieties and certified seeds from authorized dealers.',
        'season': 'Kharif',
        'addedDate': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Rabi Crop Management',
        'category': 'Crop Selection',
        'content': 'Rabi crops (Oct-Mar) need:\n\n• Cool germination temperatures (15-20°C)\n• Irrigation every 3-4 weeks\n• Protection from frost\n\nBest crops: Wheat, Barley, Gram, Mustard, Potato, Onion.\n\nApply first irrigation 20-25 days after sowing for wheat. Use anti-frost measures like light irrigation or smoke during cold nights.',
        'season': 'Rabi',
        'addedDate': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Proper Harvesting Techniques',
        'category': 'Harvesting',
        'content': 'Harvest crops during early morning (6-9 AM) when moisture content is optimal and temperature is low. Use sharp, clean tools to prevent crop damage and disease spread.\n\nFor grains: Harvest when 80-90% grains are mature and moisture is 20-25%.\nFor vegetables: Harvest at proper maturity - unripe or overripe reduces market value.\n\nAvoid harvesting during or immediately after rain to prevent fungal contamination.',
        'season': 'All',
        'addedDate': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Grain Storage Best Practices',
        'category': 'Storage',
        'content': 'Dry grains to 12-14% moisture before storage (use moisture meter). Clean grains thoroughly to remove damaged seeds and foreign matter.\n\nStorage tips:\n• Use airtight containers or improved bins\n• Mix dried neem leaves (250g per quintal) as natural pesticide\n• Store in cool, dry place away from direct sunlight\n• Raise storage containers 15-20cm above ground\n• Check every 15 days for moisture or pest infestation\n\nProper storage prevents 30-40% post-harvest losses.',
        'season': 'All',
        'addedDate': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Organic Fertilizer Preparation',
        'category': 'Fertilizers',
        'content': 'COMPOST MAKING:\n1. Mix green waste (40%) + dry leaves (30%) + soil (20%) + cow dung (10%)\n2. Add water to maintain 50-60% moisture\n3. Turn pile every 7 days\n4. Ready in 45-60 days (dark brown, earthy smell)\n\nVERMICOMPOST:\n• Use Eisenia fetida earthworms\n• Mix cow dung + crop residue\n• Ready in 60-90 days\n• Rich in NPK and micronutrients\n\nApply 5-10 kg compost per square meter before planting.',
        'season': 'All',
        'addedDate': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Water Conservation Techniques',
        'category': 'Irrigation',
        'content': '1. MULCHING: Apply 2-3 inch organic mulch layer to reduce evaporation by 50%\n\n2. DRIP IRRIGATION: Saves 40-70% water, increases yield by 30-50%\n\n3. RAINWATER HARVESTING: Build farm ponds to store monsoon water\n\n4. ZERO TILLAGE: Reduces water requirement by 30%\n\n5. CROP SELECTION: Grow drought-tolerant varieties in water-scarce areas\n\nOne hectare of farm can harvest 3-5 lakh liters rainwater annually.',
        'season': 'All',
        'addedDate': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Identifying and Preventing Common Diseases',
        'category': 'Pest Control',
        'content': 'FUNGAL DISEASES:\n• Symptoms: Spots on leaves, white powder, wilting\n• Prevention: Proper spacing, drip irrigation, crop rotation\n• Control: Neem-based fungicides, Trichoderma\n\nBACTERIAL DISEASES:\n• Symptoms: Water-soaked spots, yellowing\n• Prevention: Use disease-free seeds, avoid overhead irrigation\n\nVIRAL DISEASES:\n• Symptoms: Mosaic patterns, stunted growth\n• Prevention: Control insect vectors, remove infected plants immediately\n\nScout fields weekly for early detection.',
        'season': 'All',
        'addedDate': FieldValue.serverTimestamp(),
      },
    ];

    try {
      for (var tip in tips) {
        await FirebaseFirestore.instance.collection('farming_tips').add(tip);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Sample tips added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Irrigation':
        return Colors.blue;
      case 'Pest Control':
        return Colors.red;
      case 'Soil Health':
        return Colors.brown;
      case 'Crop Selection':
        return Colors.green;
      case 'Harvesting':
        return Colors.orange;
      case 'Storage':
        return Colors.purple;
      case 'Fertilizers':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Irrigation':
        return Icons.water_drop;
      case 'Pest Control':
        return Icons.bug_report;
      case 'Soil Health':
        return Icons.grass;
      case 'Crop Selection':
        return Icons.eco;
      case 'Harvesting':
        return Icons.agriculture;
      case 'Storage':
        return Icons.inventory_2;
      case 'Fertilizers':
        return Icons.science;
      default:
        return Icons.info;
    }
  }
}