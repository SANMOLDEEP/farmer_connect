import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/scheme_model.dart';
import 'scheme_detail_screen.dart';

class SchemesScreen extends StatefulWidget {
  const SchemesScreen({super.key});

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Subsidy',
    'Insurance',
    'Credit',
    'Training',
    'Marketing',
    'Technology',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Government Schemes'),
        backgroundColor: Colors.indigo[700],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.indigo[50],
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search schemes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),

          // Category filter
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = category);
                    },
                    selectedColor: Colors.indigo[700],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Schemes list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // ✅ FIXED: Simple query without compound index
              stream: FirebaseFirestore.instance
                  .collection('schemes')
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

                // ✅ Filter in code instead of query
                var schemes = snapshot.data!.docs
                    .map((doc) => GovernmentScheme.fromFirestore(doc))
                    .where((scheme) {
                  // Filter active schemes
                  if (!scheme.isActive) return false;
                  
                  // Filter by category
                  if (_selectedCategory != 'All' && scheme.category != _selectedCategory) {
                    return false;
                  }
                  
                  // Filter by search
                  if (_searchQuery.isNotEmpty &&
                      !scheme.schemeName.toLowerCase().contains(_searchQuery) &&
                      !scheme.description.toLowerCase().contains(_searchQuery)) {
                    return false;
                  }
                  
                  return true;
                }).toList();

                // ✅ Sort in code
                schemes.sort((a, b) => b.addedDate.compareTo(a.addedDate));

                if (schemes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('No schemes found', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: schemes.length,
                  itemBuilder: (context, index) {
                    return _buildSchemeCard(schemes[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeCard(GovernmentScheme scheme) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SchemeDetailScreen(scheme: scheme),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(scheme.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(scheme.category),
                      color: _getCategoryColor(scheme.category),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scheme.schemeName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(scheme.category),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            scheme.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                scheme.description,
                style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      scheme.benefits.split('\n').first,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No schemes available',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Government schemes will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addSampleSchemes,
            icon: const Icon(Icons.add),
            label: const Text('Add Sample Schemes'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo[700],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addSampleSchemes() async {
    final schemes = [
      {
        'schemeName': 'PM-KISAN (Pradhan Mantri Kisan Samman Nidhi)',
        'category': 'Subsidy',
        'description': 'Direct income support to farmers. ₹6000 per year in three installments.',
        'benefits': '• ₹6000 per year\n• Direct bank transfer\n• No intermediaries\n• All landholding farmers eligible',
        'eligibility': 'All landholding farmers with valid Aadhaar and bank account',
        'howToApply': 'Visit pmkisan.gov.in or nearest CSC center',
        'documentsRequired': 'Aadhaar Card, Bank Passbook, Land Records',
        'officialWebsite': 'https://pmkisan.gov.in',
        'contactNumber': '155261',
        'isActive': true,
        'addedDate': FieldValue.serverTimestamp(),
      },
      {
        'schemeName': 'PMFBY (Pradhan Mantri Fasal Bima Yojana)',
        'category': 'Insurance',
        'description': 'Comprehensive crop insurance against natural calamities.',
        'benefits': '• Low premium (1.5-2%)\n• Quick claim settlement\n• All crops covered\n• Natural disaster protection',
        'eligibility': 'All farmers growing notified crops in notified areas',
        'howToApply': 'Apply through banks or Common Service Centers',
        'documentsRequired': 'Aadhaar, Land Records, Bank Details, Sowing Certificate',
        'officialWebsite': 'https://pmfby.gov.in',
        'contactNumber': '1800-180-1551',
        'isActive': true,
        'addedDate': FieldValue.serverTimestamp(),
      },
      {
        'schemeName': 'KCC (Kisan Credit Card)',
        'category': 'Credit',
        'description': 'Easy credit facility for farmers at low interest rates.',
        'benefits': '• Low interest (4%)\n• No collateral up to ₹1.6 lakh\n• Flexible repayment\n• Insurance included',
        'eligibility': 'Farmers owning cultivable land',
        'howToApply': 'Apply at nearest bank branch',
        'documentsRequired': 'Identity Proof, Land Records, Photos',
        'officialWebsite': 'https://www.nabard.org',
        'contactNumber': '1800-180-1111',
        'isActive': true,
        'addedDate': FieldValue.serverTimestamp(),
      },
      {
        'schemeName': 'Soil Health Card Scheme',
        'category': 'Technology',
        'description': 'Free soil testing and nutrient recommendations.',
        'benefits': '• Free soil testing\n• Fertilizer recommendations\n• Reduces input costs\n• Improves yield',
        'eligibility': 'All farmers (card issued every 3 years)',
        'howToApply': 'Register at local agriculture office',
        'documentsRequired': 'Aadhaar Card, Land Records',
        'officialWebsite': 'https://soilhealth.dac.gov.in',
        'contactNumber': '1800-180-1551',
        'isActive': true,
        'addedDate': FieldValue.serverTimestamp(),
      },
      {
        'schemeName': 'e-NAM (National Agriculture Market)',
        'category': 'Marketing',
        'description': 'Online trading platform for better crop prices.',
        'benefits': '• Online price discovery\n• Transparent auction\n• Direct payment\n• Pan-India market access',
        'eligibility': 'All farmers selling in registered mandis',
        'howToApply': 'Register at nearest e-NAM mandi',
        'documentsRequired': 'Aadhaar, Bank Details, Mobile Number',
        'officialWebsite': 'https://www.enam.gov.in',
        'contactNumber': '1800-270-0224',
        'isActive': true,
        'addedDate': FieldValue.serverTimestamp(),
      },
    ];

    try {
      for (var scheme in schemes) {
        await FirebaseFirestore.instance.collection('schemes').add(scheme);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Sample schemes added!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Subsidy':
        return Colors.green;
      case 'Insurance':
        return Colors.blue;
      case 'Credit':
        return Colors.orange;
      case 'Training':
        return Colors.purple;
      case 'Marketing':
        return Colors.teal;
      case 'Technology':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Subsidy':
        return Icons.payments;
      case 'Insurance':
        return Icons.shield;
      case 'Credit':
        return Icons.credit_card;
      case 'Training':
        return Icons.school;
      case 'Marketing':
        return Icons.storefront;
      case 'Technology':
        return Icons.computer;
      default:
        return Icons.info;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}