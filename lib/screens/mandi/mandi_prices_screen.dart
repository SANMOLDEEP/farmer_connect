import 'package:flutter/material.dart';
import '../../models/mandi_price_model.dart';
import '../../services/mandi_price_service.dart';

class MandiPricesScreen extends StatefulWidget {
  const MandiPricesScreen({super.key});

  @override
  State<MandiPricesScreen> createState() => _MandiPricesScreenState();
}

class _MandiPricesScreenState extends State<MandiPricesScreen> {
  final MandiPriceService _service = MandiPriceService();
  
  List<MandiPrice> _allPrices = [];
  List<MandiPrice> _filteredPrices = [];
  List<CommodityGroup> _commodityGroups = [];
  
  bool _isLoading = true;
  bool _showGrouped = false;
  
  String _selectedState = 'All States';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  Future<void> _loadPrices() async {
    setState(() => _isLoading = true);
    
    try {
      final prices = await _service.getMandiPrices(
        state: _selectedState == 'All States' ? null : _selectedState,
        limit: 200,
      );
      
      setState(() {
        _allPrices = prices;
        _filteredPrices = prices;
        _commodityGroups = _service.groupByCommodity(prices);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading prices: $e')),
      );
    }
  }

  void _filterPrices(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredPrices = _allPrices;
      } else {
        _filteredPrices = _allPrices.where((price) {
          return price.commodity.toLowerCase().contains(query.toLowerCase()) ||
                 price.market.toLowerCase().contains(query.toLowerCase()) ||
                 price.district.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
      _commodityGroups = _service.groupByCommodity(_filteredPrices);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar.large(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Mandi Prices',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.lime[700]!,
                      Colors.lime[500]!,
                      Colors.lime[300]!,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      bottom: -50,
                      child: Icon(
                        Icons.show_chart,
                        size: 200,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(_showGrouped ? Icons.list : Icons.grid_view),
                onPressed: () {
                  setState(() => _showGrouped = !_showGrouped);
                },
                tooltip: _showGrouped ? 'List View' : 'Group View',
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadPrices,
              ),
            ],
          ),

          // Search and Filter
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search commodity, market, district...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: _filterPrices,
                  ),
                  const SizedBox(height: 12),

                  // State Filter
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedState,
                      isExpanded: true,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down),
                      items: _service.getStates().map((state) {
                        return DropdownMenuItem(
                          value: state,
                          child: Text(state),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedState = value);
                          _loadPrices();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading mandi prices...'),
                  ],
                ),
              ),
            ),

          // Content
          if (!_isLoading && _filteredPrices.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'No prices found',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),

          // List View
          if (!_isLoading && _filteredPrices.isNotEmpty && !_showGrouped)
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildPriceCard(_filteredPrices[index]),
                  childCount: _filteredPrices.length,
                ),
              ),
            ),

          // Grouped View
          if (!_isLoading && _commodityGroups.isNotEmpty && _showGrouped)
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildCommodityGroup(_commodityGroups[index]),
                  childCount: _commodityGroups.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(MandiPrice price) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Commodity Name
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.lime[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.grass,
                    color: Colors.lime[700],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        price.commodity,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${price.variety} - ${price.grade}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildTrendIndicator(price.trend),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),

            // Location
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${price.market}, ${price.district}, ${price.state}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Date
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  price.arrivalDate,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Prices
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPriceInfo('Min', price.minPrice, Colors.red),
                _buildPriceInfo('Modal', price.modalPrice, Colors.green),
                _buildPriceInfo('Max', price.maxPrice, Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommodityGroup(CommodityGroup group) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.lime[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.grass, color: Colors.lime[700]),
        ),
        title: Text(
          group.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Avg: ${group.prices.first.formatPrice(group.averagePrice)} • ${group.prices.length} markets',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        children: group.prices.map((price) {
          return ListTile(
            dense: true,
            title: Text(
              '${price.market}, ${price.district}',
              style: const TextStyle(fontSize: 13),
            ),
            subtitle: Text(
              price.arrivalDate,
              style: const TextStyle(fontSize: 11),
            ),
            trailing: Text(
              price.formatPrice(price.modalPrice),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
                fontSize: 14,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceInfo(String label, double price, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '₹${price.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendIndicator(String trend) {
    IconData icon;
    Color color;

    switch (trend) {
      case 'up':
        icon = Icons.trending_up;
        color = Colors.green;
        break;
      case 'down':
        icon = Icons.trending_down;
        color = Colors.red;
        break;
      default:
        icon = Icons.trending_flat;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}