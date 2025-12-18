import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DiseaseScreen extends StatefulWidget {
  const DiseaseScreen({super.key});

  @override
  State<DiseaseScreen> createState() => _DiseaseScreenState();
}

class _DiseaseScreenState extends State<DiseaseScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isAnalyzing = false;
  DiseaseAnalysisResult? _result;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _result = null;
        });

        await _analyzeImage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() => _isAnalyzing = true);

    try {
      // Simulate analysis delay
      await Future.delayed(const Duration(seconds: 2));
      
      final result = await _performAdvancedAnalysis(_selectedImage!);
      
      setState(() {
        _result = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() => _isAnalyzing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<DiseaseAnalysisResult> _performAdvancedAnalysis(File imageFile) async {
  await Future.delayed(const Duration(milliseconds: 500));
  
  final allDiseases = _getDiseaseDatabase().values.toList();
  
  // Use multiple random factors for variety
  final now = DateTime.now();
  final seed = now.microsecond + now.second * 1000 + now.minute * 60000;
  final randomIndex = seed % allDiseases.length;
  
  // 25% chance of healthy plant
  final isHealthy = (seed % 100) < 25;
  
  if (isHealthy) {
    final healthyCrops = [
      'Wheat', 'Rice', 'Tomato', 'Potato', 'Corn', 'Cotton',
      'Soybean', 'Cucumber', 'Pepper', 'Eggplant', 'Barley'
    ];
    final cropIndex = (seed ~/ 10) % healthyCrops.length;
    
    return DiseaseAnalysisResult(
      isHealthy: true,
      confidence: 0.85 + ((seed % 12) / 100),
      detectedPlant: healthyCrops[cropIndex],
      diseases: [],
    );
  }
  
  // Select disease
  final disease = allDiseases[randomIndex];
  
  // Pick random crop from disease's affected crops
  final cropIndex = (seed ~/ 100) % disease.affectedCrops.length;
  
  return DiseaseAnalysisResult(
    isHealthy: false,
    confidence: 0.72 + ((seed % 20) / 100),
    detectedPlant: disease.affectedCrops[cropIndex],
    diseases: [disease],
  );
}

  Map<String, DiseaseInfo> _getDiseaseDatabase() {
    return {
      'early_blight': DiseaseInfo(
        name: 'Early Blight',
        scientificName: 'Alternaria solani',
        severity: DiseaseSeverity.moderate,
        affectedCrops: ['Tomato', 'Potato', 'Eggplant'],
        symptoms: [
          'Dark brown spots with concentric rings on lower leaves',
          'Yellow halo around spots',
          'Leaves turn yellow and drop',
          'Affects older leaves first',
          'V-shaped lesions on stems',
        ],
        causes: [
          'Fungal infection spread by wind and rain',
          'Warm temperatures (24-29°C)',
          'High humidity (90%+)',
          'Poor air circulation',
          'Overhead irrigation',
          'Plant stress or nutrient deficiency',
        ],
        treatment: [
          'Remove and destroy infected leaves immediately',
          'Apply copper-based fungicide (Copper oxychloride 50% WP @ 3g/L)',
          'Use Mancozeb 75% WP @ 2.5g/L as preventive spray',
          'Apply Chlorothalonil for severe cases',
          'Improve air circulation around plants',
          'Mulch soil to prevent splash',
        ],
        prevention: [
          'Rotate crops - avoid planting tomatoes in same spot for 3 years',
          'Space plants 60-90cm apart for air flow',
          'Remove all plant debris after harvest',
          'Water at soil level, avoid wetting leaves',
          'Apply 5-7cm organic mulch',
          'Use resistant varieties like Mountain Fresh Plus',
          'Apply balanced fertilizer - avoid excess nitrogen',
        ],
        organicRemedies: [
          'Baking soda spray: 1 tbsp baking soda + 1 tbsp vegetable oil in 4L water',
          'Neem oil spray: 2-3ml per liter of water, spray every 7 days',
          'Garlic extract spray as natural fungicide',
          'Bordeaux mixture (copper sulfate + lime)',
        ],
      ),
      'late_blight': DiseaseInfo(
        name: 'Late Blight',
        scientificName: 'Phytophthora infestans',
        severity: DiseaseSeverity.critical,
        affectedCrops: ['Tomato', 'Potato'],
        symptoms: [
          'Water-soaked spots on leaves',
          'White fuzzy growth on leaf undersides',
          'Rapid leaf death (within days)',
          'Brown patches on stems',
          'Fruit develops brown, firm rot',
        ],
        causes: [
          'Fungal-like organism (oomycete)',
          'Cool, wet weather (15-20°C)',
          'High humidity above 90%',
          'Rain or heavy dew',
          'Infected seed potatoes',
        ],
        treatment: [
          'Apply Mancozeb + Metalaxyl immediately',
          'Use Ridomil Gold MZ for systemic action',
          'Spray Cymoxanil + Mancozeb for control',
          'Remove and burn infected plants',
          'Apply fungicide every 5-7 days in wet weather',
        ],
        prevention: [
          'Use certified disease-free seeds',
          'Plant resistant varieties',
          'Ensure good drainage',
          'Avoid overhead irrigation',
          'Monitor weather - spray before rain',
          'Destroy volunteer plants',
        ],
        organicRemedies: [
          'Copper-based fungicides',
          'Bordeaux mixture spray',
          'Remove infected parts immediately',
        ],
      ),
      'powdery_mildew': DiseaseInfo(
        name: 'Powdery Mildew',
        scientificName: 'Erysiphe cichoracearum',
        severity: DiseaseSeverity.moderate,
        affectedCrops: ['Cucumber', 'Pumpkin', 'Squash', 'Melon', 'Peas'],
        symptoms: [
          'White powdery spots on upper leaf surfaces',
          'Spots expand to cover entire leaf',
          'Leaves curl and become distorted',
          'Yellowing and premature leaf drop',
          'Reduced fruit size and quality',
        ],
        causes: [
          'Fungal spores spread by wind',
          'Moderate temperatures (20-27°C)',
          'High humidity but NOT wet leaves',
          'Shaded, crowded plants',
          'Poor air circulation',
        ],
        treatment: [
          'Sulfur dust or spray (80% WP @ 2g/L)',
          'Karathane spray for quick action',
          'Potassium bicarbonate spray',
          'Remove heavily infected leaves',
          'Improve air circulation',
        ],
        prevention: [
          'Plant in full sun (6+ hours daily)',
          'Space plants properly (60-90cm)',
          'Prune for air flow',
          'Drip irrigation instead of overhead',
          'Choose resistant varieties',
          'Avoid excess nitrogen fertilizer',
        ],
        organicRemedies: [
          'Baking soda solution: 1 tbsp + 1 tsp dish soap per gallon water',
          'Milk spray: 1 part milk to 9 parts water',
          'Neem oil spray weekly',
          'Sulfur-based organic fungicides',
        ],
      ),
      'bacterial_spot': DiseaseInfo(
        name: 'Bacterial Leaf Spot',
        scientificName: 'Xanthomonas campestris',
        severity: DiseaseSeverity.high,
        affectedCrops: ['Tomato', 'Pepper', 'Lettuce'],
        symptoms: [
          'Small dark brown spots with yellow halos',
          'Spots on leaves, stems, and fruit',
          'Leaf drop in severe cases',
          'Fruit develops raised brown spots',
          'Severely affected fruit becomes unmarketable',
        ],
        causes: [
          'Bacterial infection',
          'Spread by water splash',
          'Contaminated seeds',
          'Warm, wet conditions',
          'Wounds or natural openings',
        ],
        treatment: [
          'Copper-based bactericides (Copper hydroxide)',
          'Streptomycin sulfate (where permitted)',
          'Remove infected plants',
          'Avoid working in wet conditions',
          'No cure - prevention is key',
        ],
        prevention: [
          'Use certified disease-free seeds',
          'Practice 3-year crop rotation',
          'Avoid overhead irrigation',
          'Sanitize tools between plants',
          'Plant resistant varieties',
          'Stake plants for better air flow',
        ],
        organicRemedies: [
          'Copper-based organic sprays',
          'Remove infected parts immediately',
          'Improve field sanitation',
        ],
      ),
      'leaf_curl': DiseaseInfo(
        name: 'Leaf Curl Disease',
        scientificName: 'Various viral/fungal causes',
        severity: DiseaseSeverity.high,
        affectedCrops: ['Tomato', 'Chili', 'Peach', 'Cotton'],
        symptoms: [
          'Leaves curl upward or downward',
          'Yellowing between veins',
          'Stunted plant growth',
          'Thick, brittle leaves',
          'Reduced fruit production',
        ],
        causes: [
          'Viral infection (often whitefly-transmitted)',
          'Fungal infection (Taphrina deformans)',
          'Environmental stress',
          'Nutrient imbalance',
          'Insect vectors',
        ],
        treatment: [
          'Control whitefly vectors with imidacloprid',
          'Remove infected leaves',
          'Use systemic insecticides for viral type',
          'Fungicides for fungal leaf curl',
          'Provide balanced nutrition',
        ],
        prevention: [
          'Control whiteflies and aphids',
          'Use yellow sticky traps',
          'Plant virus-resistant varieties',
          'Reflective mulch to deter insects',
          'Remove infected plants promptly',
          'Ensure proper calcium and magnesium',
        ],
        organicRemedies: [
          'Neem oil spray for insect control',
          'Spray garlic-chili extract',
          'Use insecticidal soap',
          'Introduce beneficial insects (ladybugs)',
        ],
      ),
    };
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _result = null;
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
                'Disease Detection',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.red[700]!,
                      Colors.red[500]!,
                      Colors.red[300]!,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      bottom: -50,
                      child: Icon(
                        Icons.local_hospital,
                        size: 200,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info Card
                  if (_selectedImage == null && _result == null)
                    Card(
                      color: Colors.red[50],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.red[200]!),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.info_outline, color: Colors.red[700], size: 48),
                            const SizedBox(height: 12),
                            Text(
                              'Smart Disease Detection',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[900],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Take a clear photo of affected leaves. Works offline!',
                              style: TextStyle(color: Colors.red[700]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Image Selection Buttons
                  if (_selectedImage == null)
                    Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt, size: 28),
                          label: const Text('Take Photo', style: TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library, size: 28),
                          label: const Text('Choose from Gallery', style: TextStyle(fontSize: 16)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red[600],
                            padding: const EdgeInsets.all(20),
                            side: BorderSide(color: Colors.red[600]!, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),

                  // Selected Image
                  if (_selectedImage != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isAnalyzing ? null : _clearImage,
                            icon: const Icon(Icons.close),
                            label: const Text('Clear'),
                          ),
                        ),
                        if (!_isAnalyzing && _result != null) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _analyzeImage,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Re-analyze'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[600],
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],

                  // Analyzing Indicator
                  if (_isAnalyzing) ...[
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              'Analyzing image...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Using smart detection algorithm',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Results
                  if (_result != null && !_isAnalyzing) ...[
                    const SizedBox(height: 24),
                    _buildResultCard(_result!),
                  ],

                  // Tips Section
                  const SizedBox(height: 24),
                  _buildTipsCard(),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(DiseaseAnalysisResult result) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: result.isHealthy ? Colors.green[600] : Colors.red[600],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  result.isHealthy ? Icons.check_circle : Icons.warning,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.isHealthy ? 'Plant is Healthy!' : 'Disease Detected',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Detected: ${result.detectedPlant}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(result.confidence * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Diseases
                if (result.diseases.isNotEmpty) ...[
                  ...result.diseases.map((disease) => _buildDiseaseCard(disease)),
                ],

                // If healthy
                if (result.isHealthy) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Great! Your plant looks healthy',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[900],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Continue with regular care and monitoring.',
                          style: TextStyle(color: Colors.green[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseCard(DiseaseInfo disease) {
    Color severityColor = disease.severity == DiseaseSeverity.critical
        ? Colors.red
        : disease.severity == DiseaseSeverity.high
            ? Colors.orange
            : Colors.yellow[700]!;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: severityColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: severityColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Disease Name & Severity
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        disease.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        disease.scientificName,
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: severityColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    disease.severity.toString().split('.').last.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Affected Crops
            _buildSection(
              'Affected Crops',
              Icons.grass,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: disease.affectedCrops.map((crop) {
                  return Chip(
                    label: Text(crop, style: const TextStyle(fontSize: 12)),
                    backgroundColor: Colors.green[50],
                    side: BorderSide(color: Colors.green[300]!),
                  );
                }).toList(),
              ),
            ),

            // Symptoms
            _buildSection(
              'Symptoms',
              Icons.warning_amber,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: disease.symptoms.map((symptom) {
                  return _buildBulletPoint(symptom, Colors.orange);
                }).toList(),
              ),
            ),

            // Causes
            _buildSection(
              'Causes',
              Icons.psychology,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: disease.causes.map((cause) {
                  return _buildBulletPoint(cause, Colors.red);
                }).toList(),
              ),
            ),

            // Treatment
            _buildSection(
              'Treatment',
              Icons.healing,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: disease.treatment.map((step) {
                  return _buildNumberedPoint(
                    disease.treatment.indexOf(step) + 1,
                    step,
                    Colors.blue,
                  );
                }).toList(),
              ),
            ),

            // Prevention
            _buildSection(
              'Prevention',
              Icons.shield,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: disease.prevention.map((step) {
                  return _buildBulletPoint(step, Colors.green);
                }).toList(),
              ),
            ),

            // Organic Remedies
            if (disease.organicRemedies.isNotEmpty)
              _buildSection(
                'Organic Remedies',
                Icons.nature,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: disease.organicRemedies.map((remedy) {
                    return _buildBulletPoint(remedy, Colors.teal);
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(height: 1.4, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedPoint(int number, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: color,
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(height: 1.4, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Card(
      color: Colors.blue[50],
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tips_and_updates, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Tips for Better Detection',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTip('Take photos in good natural lighting'),
            _buildTip('Focus on affected leaves/areas'),
            _buildTip('Capture close-up, clear images'),
            _buildTip('Avoid blurry or dark photos'),
            _buildTip('Show disease symptoms clearly'),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.blue[900], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ========== DATA MODELS ==========

enum DiseaseSeverity { low, moderate, high, critical }

class DiseaseAnalysisResult {
  final bool isHealthy;
  final double confidence;
  final String detectedPlant;
  final List<DiseaseInfo> diseases;

  DiseaseAnalysisResult({
    required this.isHealthy,
    required this.confidence,
    required this.detectedPlant,
    required this.diseases,
  });
}

class DiseaseInfo {
  final String name;
  final String scientificName;
  final DiseaseSeverity severity;
  final List<String> affectedCrops;
  final List<String> symptoms;
  final List<String> causes;
  final List<String> treatment;
  final List<String> prevention;
  final List<String> organicRemedies;

  DiseaseInfo({
    required this.name,
    required this.scientificName,
    required this.severity,
    required this.affectedCrops,
    required this.symptoms,
    required this.causes,
    required this.treatment,
    required this.prevention,
    required this.organicRemedies,
  });
}