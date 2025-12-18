import 'package:flutter/material.dart';

class FarmCalculatorScreen extends StatefulWidget {
  const FarmCalculatorScreen({super.key});

  @override
  State<FarmCalculatorScreen> createState() => _FarmCalculatorScreenState();
}

class _FarmCalculatorScreenState extends State<FarmCalculatorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Calculator'),
        backgroundColor: Colors.amber[700],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.calculate), text: 'Yield'),
            Tab(icon: Icon(Icons.currency_rupee), text: 'Profit'),
            Tab(icon: Icon(Icons.straighten), text: 'Land Area'),
            Tab(icon: Icon(Icons.water_drop), text: 'Irrigation'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          YieldCalculator(),
          ProfitCalculator(),
          LandAreaCalculator(),
          IrrigationCalculator(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// ✅ YIELD CALCULATOR
// ✅ YIELD CALCULATOR - FIXED
class YieldCalculator extends StatefulWidget {
  const YieldCalculator({super.key});

  @override
  State<YieldCalculator> createState() => _YieldCalculatorState();
}

class _YieldCalculatorState extends State<YieldCalculator> {
  final _formKey = GlobalKey<FormState>();
  final _areaController = TextEditingController();
  final _plantDensityController = TextEditingController();
  final _avgWeightController = TextEditingController();
  
  String _selectedCrop = 'Wheat';
  String _areaUnit = 'Acre';
  double? _estimatedYield;
  double? _yieldPerAcre;

  final Map<String, double> _standardYields = {
    'Wheat': 2500, // kg per acre
    'Rice': 2000,
    'Maize': 3000,
    'Cotton': 500,
    'Sugarcane': 40000,
    'Potato': 8000,
    'Tomato': 15000,
  };

  void _calculateYield() {
    if (!_formKey.currentState!.validate()) return;

    double area = double.parse(_areaController.text);
    if (_areaUnit == 'Hectare') {
      area = area * 2.47; // Convert to acres
    }

    // Method 1: Using standard yield
    double standardYield = _standardYields[_selectedCrop]! * area;

    // Method 2: Using plant density (if provided)
    double? customYield;
    if (_plantDensityController.text.isNotEmpty && _avgWeightController.text.isNotEmpty) {
      double plantDensity = double.parse(_plantDensityController.text);
      double avgWeight = double.parse(_avgWeightController.text);
      customYield = (plantDensity * area * avgWeight) / 1000; // Convert grams to kg
    }

    setState(() {
      _estimatedYield = customYield ?? standardYield;
      _yieldPerAcre = _estimatedYield! / area;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Calculate expected crop yield based on area and crop type',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Crop selection
            DropdownButtonFormField<String>(
              value: _selectedCrop,
              decoration: InputDecoration(
                labelText: 'Select Crop',
                prefixIcon: const Icon(Icons.agriculture),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _standardYields.keys.map((crop) {
                return DropdownMenuItem(value: crop, child: Text(crop));
              }).toList(),
              onChanged: (value) => setState(() => _selectedCrop = value!),
            ),

            const SizedBox(height: 16),

            // ✅ FIXED: Area input
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _areaController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Land Area',
                      prefixIcon: const Icon(Icons.landscape),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      if (double.tryParse(value!) == null) return 'Invalid';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _areaUnit,
                    decoration: InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    ),
                    isExpanded: true,
                    items: ['Acre', 'Hectare'].map((unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(
                          unit,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _areaUnit = value!),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Divider(),
            const Text(
              'Advanced Calculation (Optional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Plant density
            TextFormField(
              controller: _plantDensityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Plant Density (plants per acre)',
                prefixIcon: const Icon(Icons.grass),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                helperText: 'Optional: For custom calculation',
              ),
            ),

            const SizedBox(height: 16),

            // Average weight per plant
            TextFormField(
              controller: _avgWeightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Avg. Yield per Plant (grams)',
                prefixIcon: const Icon(Icons.scale),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                helperText: 'Optional: Average production per plant',
              ),
            ),

            const SizedBox(height: 32),

            // Calculate button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _calculateYield,
                icon: const Icon(Icons.calculate),
                label: const Text('Calculate Yield', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            if (_estimatedYield != null) ...[
              const SizedBox(height: 32),
              
              // Results
              Card(
                elevation: 4,
                color: Colors.green[50],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[700], size: 32),
                          const SizedBox(width: 12),
                          const Text(
                            'Estimated Yield',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildResultRow('Total Yield', '${_estimatedYield!.toStringAsFixed(0)} kg'),
                      const Divider(),
                      _buildResultRow('Per Acre', '${_yieldPerAcre!.toStringAsFixed(0)} kg/acre'),
                      const Divider(),
                      _buildResultRow('In Quintals', '${(_estimatedYield! / 100).toStringAsFixed(2)} quintals'),
                      const Divider(),
                      _buildResultRow('In Tons', '${(_estimatedYield! / 1000).toStringAsFixed(2)} tons'),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _areaController.dispose();
    _plantDensityController.dispose();
    _avgWeightController.dispose();
    super.dispose();
  }
}
// ✅ PROFIT CALCULATOR
class ProfitCalculator extends StatefulWidget {
  const ProfitCalculator({super.key});

  @override
  State<ProfitCalculator> createState() => _ProfitCalculatorState();
}

class _ProfitCalculatorState extends State<ProfitCalculator> {
  final _formKey = GlobalKey<FormState>();
  final _yieldController = TextEditingController();
  final _priceController = TextEditingController();
  final _seedCostController = TextEditingController();
  final _fertilizerCostController = TextEditingController();
  final _pesticideCostController = TextEditingController();
  final _laborCostController = TextEditingController();
  final _irrigationCostController = TextEditingController();
  final _otherCostController = TextEditingController();

  double? _totalRevenue;
  double? _totalCost;
  double? _netProfit;
  double? _profitPercentage;

  void _calculateProfit() {
    if (!_formKey.currentState!.validate()) return;

    double yieldKg = double.parse(_yieldController.text);
    double pricePerKg = double.parse(_priceController.text);
    
    double revenue = yieldKg * pricePerKg;
    
    double cost = 
      double.parse(_seedCostController.text.isEmpty ? '0' : _seedCostController.text) +
      double.parse(_fertilizerCostController.text.isEmpty ? '0' : _fertilizerCostController.text) +
      double.parse(_pesticideCostController.text.isEmpty ? '0' : _pesticideCostController.text) +
      double.parse(_laborCostController.text.isEmpty ? '0' : _laborCostController.text) +
      double.parse(_irrigationCostController.text.isEmpty ? '0' : _irrigationCostController.text) +
      double.parse(_otherCostController.text.isEmpty ? '0' : _otherCostController.text);

    double profit = revenue - cost;
    double profitPct = (profit / cost) * 100;

    setState(() {
      _totalRevenue = revenue;
      _totalCost = cost;
      _netProfit = profit;
      _profitPercentage = profitPct;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Revenue section
            const Text(
              'Revenue',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _yieldController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Total Yield (kg)',
                prefixIcon: const Icon(Icons.inventory),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                if (double.tryParse(value!) == null) return 'Invalid';
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Selling Price (₹/kg)',
                prefixIcon: const Icon(Icons.currency_rupee),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                if (double.tryParse(value!) == null) return 'Invalid';
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Cost section
            const Text(
              'Production Costs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildCostField(_seedCostController, 'Seed Cost', Icons.eco),
            const SizedBox(height: 12),
            _buildCostField(_fertilizerCostController, 'Fertilizer Cost', Icons.science),
            const SizedBox(height: 12),
            _buildCostField(_pesticideCostController, 'Pesticide Cost', Icons.bug_report),
            const SizedBox(height: 12),
            _buildCostField(_laborCostController, 'Labor Cost', Icons.people),
            const SizedBox(height: 12),
            _buildCostField(_irrigationCostController, 'Irrigation Cost', Icons.water_drop),
            const SizedBox(height: 12),
            _buildCostField(_otherCostController, 'Other Costs', Icons.more_horiz),

            const SizedBox(height: 32),

            // Calculate button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _calculateProfit,
                icon: const Icon(Icons.calculate),
                label: const Text('Calculate Profit', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            if (_netProfit != null) ...[
              const SizedBox(height: 32),
              
              // Results
              Card(
                elevation: 4,
                color: _netProfit! >= 0 ? Colors.green[50] : Colors.red[50],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            _netProfit! >= 0 ? Icons.trending_up : Icons.trending_down,
                            color: _netProfit! >= 0 ? Colors.green[700] : Colors.red[700],
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _netProfit! >= 0 ? 'Profit Summary' : 'Loss Summary',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildResultRow('Total Revenue', '₹${_totalRevenue!.toStringAsFixed(2)}'),
                      const Divider(),
                      _buildResultRow('Total Cost', '₹${_totalCost!.toStringAsFixed(2)}'),
                      const Divider(),
                      _buildResultRow(
                        _netProfit! >= 0 ? 'Net Profit' : 'Net Loss',
                        '₹${_netProfit!.abs().toStringAsFixed(2)}',
                        isBold: true,
                        color: _netProfit! >= 0 ? Colors.green : Colors.red,
                      ),
                      const Divider(),
                      _buildResultRow('Profit Margin', '${_profitPercentage!.toStringAsFixed(1)}%'),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCostField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        prefixText: '₹ ',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        helperText: 'Optional',
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 18 : 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 22 : 18,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _yieldController.dispose();
    _priceController.dispose();
    _seedCostController.dispose();
    _fertilizerCostController.dispose();
    _pesticideCostController.dispose();
    _laborCostController.dispose();
    _irrigationCostController.dispose();
    _otherCostController.dispose();
    super.dispose();
  }
}

// ✅ LAND AREA CALCULATOR
class LandAreaCalculator extends StatefulWidget {
  const LandAreaCalculator({super.key});

  @override
  State<LandAreaCalculator> createState() => _LandAreaCalculatorState();
}

class _LandAreaCalculatorState extends State<LandAreaCalculator> {
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  
  String _fromUnit = 'Feet';
  String _toUnit = 'Acre';
  double? _result;

  final List<String> _units = ['Feet', 'Meter', 'Acre', 'Hectare', 'Bigha', 'Gunta'];

  void _convert() {
    if (_lengthController.text.isEmpty || _widthController.text.isEmpty) return;

    double length = double.parse(_lengthController.text);
    double width = double.parse(_widthController.text);
    
    // Calculate area in square meters first
    double areaInSqMeters;
    
    if (_fromUnit == 'Feet') {
      areaInSqMeters = (length * width) * 0.092903; // sq ft to sq m
    } else if (_fromUnit == 'Meter') {
      areaInSqMeters = length * width;
    } else {
      areaInSqMeters = length * width; // For predefined units, use as is
    }

    // Convert to target unit
    double result;
    switch (_toUnit) {
      case 'Acre':
        result = areaInSqMeters / 4046.86;
        break;
      case 'Hectare':
        result = areaInSqMeters / 10000;
        break;
      case 'Bigha':
        result = areaInSqMeters / 2529.29; // 1 Bigha = 2529.29 sq m (varies by region)
        break;
      case 'Gunta':
        result = areaInSqMeters / 101.17; // 1 Gunta = 101.17 sq m
        break;
      case 'Feet':
        result = areaInSqMeters / 0.092903;
        break;
      case 'Meter':
        result = areaInSqMeters;
        break;
      default:
        result = areaInSqMeters;
    }

    setState(() {
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Convert land area between different units',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _lengthController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Length',
                    prefixIcon: const Icon(Icons.straighten),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (_) => _convert(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _widthController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Width',
                    prefixIcon: const Icon(Icons.straighten),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (_) => _convert(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _fromUnit,
            decoration: InputDecoration(
              labelText: 'From Unit',
              prefixIcon: const Icon(Icons.input),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: _units.map((unit) => DropdownMenuItem(value: unit, child: Text(unit))).toList(),
            onChanged: (value) {
              setState(() => _fromUnit = value!);
              _convert();
            },
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _toUnit,
            decoration: InputDecoration(
              labelText: 'To Unit',
              prefixIcon: const Icon(Icons.output),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: _units.map((unit) => DropdownMenuItem(value: unit, child: Text(unit))).toList(),
            onChanged: (value) {
              setState(() => _toUnit = value!);
              _convert();
            },
          ),

          if (_result != null) ...[
            const SizedBox(height: 32),
            
            Card(
              elevation: 4,
              color: Colors.amber[50],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.landscape, size: 48, color: Colors.amber),
                    const SizedBox(height: 16),
                    const Text(
                      'Area',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_result!.toStringAsFixed(4)} $_toUnit',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Quick reference
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Reference',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildReferenceRow('1 Acre', '= 43,560 sq ft = 4,047 sq m'),
                  _buildReferenceRow('1 Hectare', '= 2.47 Acres = 10,000 sq m'),
                  _buildReferenceRow('1 Bigha', '= 0.62 Acres (varies by region)'),
                  _buildReferenceRow('1 Gunta', '= 0.025 Acres = 1,089 sq ft'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceRow(String unit, String conversion) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            unit,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              conversion,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _lengthController.dispose();
    _widthController.dispose();
    super.dispose();
  }
}

// ✅ IRRIGATION CALCULATOR
class IrrigationCalculator extends StatefulWidget {
  const IrrigationCalculator({super.key});

  @override
  State<IrrigationCalculator> createState() => _IrrigationCalculatorState();
}

class _IrrigationCalculatorState extends State<IrrigationCalculator> {
  final _areaController = TextEditingController();
  final _depthController = TextEditingController();
  
  String _cropType = 'Wheat';
  String _soilType = 'Loamy';
  double? _waterRequired;

  final Map<String, double> _cropWaterNeeds = {
    'Wheat': 450, // mm per season
    'Rice': 1200,
    'Cotton': 700,
    'Sugarcane': 2000,
    'Maize': 500,
    'Vegetables': 350,
  };

  void _calculate() {
    if (_areaController.text.isEmpty) return;

    double area = double.parse(_areaController.text); // in acres
    double waterNeed = _cropWaterNeeds[_cropType]!; // mm

    // Convert to liters: 1mm water on 1 acre = 4047 liters
    double waterInLiters = area * waterNeed * 4.047;

    setState(() {
      _waterRequired = waterInLiters;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.water_drop, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Calculate irrigation water requirement',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          TextFormField(
            controller: _areaController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Land Area (Acres)',
              prefixIcon: const Icon(Icons.landscape),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (_) => _calculate(),
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _cropType,
            decoration: InputDecoration(
              labelText: 'Crop Type',
              prefixIcon: const Icon(Icons.agriculture),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: _cropWaterNeeds.keys.map((crop) {
              return DropdownMenuItem(value: crop, child: Text(crop));
            }).toList(),
            onChanged: (value) {
              setState(() => _cropType = value!);
              _calculate();
            },
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _soilType,
            decoration: InputDecoration(
              labelText: 'Soil Type',
              prefixIcon: const Icon(Icons.grass),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: ['Sandy', 'Loamy', 'Clay'].map((soil) {
              return DropdownMenuItem(value: soil, child: Text(soil));
            }).toList(),
            onChanged: (value) => setState(() => _soilType = value!),
          ),

          if (_waterRequired != null) ...[
            const SizedBox(height: 32),
            
            Card(
              elevation: 4,
              color: Colors.blue[50],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.water, size: 48, color: Colors.blue[700]),
                    const SizedBox(height: 16),
                    const Text(
                      'Water Requirement',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    _buildWaterRow('Per Season', '${_waterRequired!.toStringAsFixed(0)} liters'),
                    const Divider(),
                    _buildWaterRow('In Cubic Meters', '${(_waterRequired! / 1000).toStringAsFixed(2)} m³'),
                    const Divider(),
                    _buildWaterRow('In Gallons', '${(_waterRequired! * 0.264).toStringAsFixed(0)} gal'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Irrigation tips
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Irrigation Tips',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTip('Water early morning (5-8 AM) for best results'),
                    _buildTip('Drip irrigation saves 40-70% water'),
                    _buildTip('Check soil moisture before irrigating'),
                    _buildTip(_soilType == 'Sandy' 
                        ? 'Sandy soil: Irrigate frequently with less water'
                        : _soilType == 'Clay'
                        ? 'Clay soil: Irrigate less frequently with more water'
                        : 'Loamy soil: Balanced irrigation schedule'),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWaterRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(child: Text(tip, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _areaController.dispose();
    _depthController.dispose();
    super.dispose();
  }
}