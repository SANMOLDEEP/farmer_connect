import '../models/crop_model.dart';

class CropDatabase {
  static final List<CropInfo> crops = [
    CropInfo(
      name: 'Wheat',
      scientificName: 'Triticum aestivum',
      imageUrl: 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400',
      season: 'Rabi (October - November)',
      soilType: 'Loamy soil with good drainage',
      waterRequirement: 'Moderate (4-5 irrigations)',
      duration: '120-150 days',
      yieldPerAcre: '20-25 quintals',
      temperature: '10-25°C',
      rainfall: '75-100 cm annually',
      diseases: [
        'Rust (apply fungicides)',
        'Powdery mildew',
        'Leaf blight',
      ],
      fertilizers: [
        'Urea: 130 kg/acre',
        'DAP: 100 kg/acre',
        'Potash: 30 kg/acre',
      ],
      cultivationSteps: [
        'Prepare field with 2-3 ploughings',
        'Sow seeds at 5-6 cm depth',
        'Apply first irrigation 20-25 days after sowing',
        'Control weeds at 30-35 days',
        'Harvest when grains turn golden yellow',
      ],
    ),
    CropInfo(
      name: 'Rice',
      scientificName: 'Oryza sativa',
      imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400',
      season: 'Kharif (June - July)',
      soilType: 'Clay or clay loam with water retention',
      waterRequirement: 'High (standing water 5-10 cm)',
      duration: '120-140 days',
      yieldPerAcre: '25-30 quintals',
      temperature: '20-35°C',
      rainfall: '100-200 cm',
      diseases: [
        'Blast disease',
        'Brown spot',
        'Bacterial leaf blight',
      ],
      fertilizers: [
        'Urea: 100 kg/acre',
        'DAP: 80 kg/acre',
        'Potash: 40 kg/acre',
      ],
      cultivationSteps: [
        'Prepare nursery bed and sow seeds',
        'Transplant 25-30 day old seedlings',
        'Maintain 5-10 cm standing water',
        'Apply fertilizers in 3 splits',
        'Harvest when 80% grains turn golden',
      ],
    ),
    CropInfo(
      name: 'Tomato',
      scientificName: 'Solanum lycopersicum',
      imageUrl: 'https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=400',
      season: 'Year-round (best in winter)',
      soilType: 'Well-drained loamy soil, pH 6-7',
      waterRequirement: 'Moderate (drip irrigation ideal)',
      duration: '60-90 days',
      yieldPerAcre: '200-250 quintals',
      temperature: '20-30°C',
      rainfall: '60-150 cm',
      diseases: [
        'Early blight',
        'Late blight',
        'Leaf curl virus',
        'Bacterial wilt',
      ],
      fertilizers: [
        'FYM: 10 tons/acre',
        'NPK: 80:60:60 kg/acre',
        'Micronutrients spray',
      ],
      cultivationSteps: [
        'Prepare raised beds with organic manure',
        'Transplant 3-4 week old seedlings',
        'Provide support stakes for plants',
        'Apply mulch to conserve moisture',
        'Harvest when fruits turn red',
      ],
    ),
    CropInfo(
      name: 'Potato',
      scientificName: 'Solanum tuberosum',
      imageUrl: 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=400',
      season: 'Rabi (October - November)',
      soilType: 'Sandy loam with good drainage',
      waterRequirement: 'Moderate (6-8 irrigations)',
      duration: '90-120 days',
      yieldPerAcre: '80-100 quintals',
      temperature: '15-25°C',
      rainfall: '50-70 cm',
      diseases: [
        'Late blight',
        'Early blight',
        'Potato virus',
      ],
      fertilizers: [
        'FYM: 8-10 tons/acre',
        'Urea: 100 kg/acre',
        'DAP: 150 kg/acre',
      ],
      cultivationSteps: [
        'Use disease-free seed tubers',
        'Plant at 15-20 cm depth',
        'Earthing up at 30 days',
        'Irrigate regularly but avoid waterlogging',
        'Harvest when leaves turn yellow',
      ],
    ),
    CropInfo(
      name: 'Corn (Maize)',
      scientificName: 'Zea mays',
      imageUrl: 'https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=400',
      season: 'Kharif (June-July) & Rabi (Oct-Nov)',
      soilType: 'Well-drained loamy soil',
      waterRequirement: 'Moderate to high',
      duration: '80-110 days',
      yieldPerAcre: '25-30 quintals',
      temperature: '21-27°C',
      rainfall: '50-75 cm',
      diseases: [
        'Maydis leaf blight',
        'Common rust',
        'Stalk rot',
      ],
      fertilizers: [
        'Urea: 120 kg/acre',
        'DAP: 100 kg/acre',
        'Potash: 40 kg/acre',
      ],
      cultivationSteps: [
        'Sow seeds at 5-7 cm depth',
        'Maintain 60x20 cm spacing',
        'Apply first irrigation at knee-high stage',
        'Control weeds at 20-25 days',
        'Harvest when kernels are hard',
      ],
    ),
    CropInfo(
      name: 'Cotton',
      scientificName: 'Gossypium',
      imageUrl: 'assets/images/cotton.jpg',
      season: 'Kharif (May - June)',
      soilType: 'Deep black cotton soil',
      waterRequirement: 'Moderate (5-7 irrigations)',
      duration: '150-180 days',
      yieldPerAcre: '10-15 quintals',
      temperature: '21-30°C',
      rainfall: '50-100 cm',
      diseases: [
        'Bollworm attack',
        'Leaf curl disease',
        'Root rot',
      ],
      fertilizers: [
        'Urea: 100 kg/acre',
        'DAP: 80 kg/acre',
        'Potash: 40 kg/acre',
      ],
      cultivationSteps: [
        'Treat seeds with fungicides',
        'Sow seeds at 5 cm depth',
        'Thin plants after 15-20 days',
        'Monitor for pest attacks regularly',
        'Harvest when bolls burst open',
      ],
    ),
    CropInfo(
      name: 'Sugarcane',
      scientificName: 'Saccharum officinarum',
      imageUrl: 'assets/images/sugarcane.jpg',
      season: 'Feb-March (Spring) & Oct-Nov (Autumn)',
      soilType: 'Deep, well-drained loamy soil',
      waterRequirement: 'High (15-20 irrigations)',
      duration: '10-12 months',
      yieldPerAcre: '300-400 quintals',
      temperature: '20-35°C',
      rainfall: '75-150 cm',
      diseases: [
        'Red rot',
        'Smut disease',
        'Wilt',
      ],
      fertilizers: [
        'Urea: 250 kg/acre',
        'DAP: 150 kg/acre',
        'Potash: 60 kg/acre',
      ],
      cultivationSteps: [
        'Plant 2-3 budded setts horizontally',
        'Cover with 5-8 cm soil',
        'First irrigation immediately after planting',
        'Earthing up at 90-120 days',
        'Harvest when canes mature (10-12 months)',
      ],
    ),
    CropInfo(
      name: 'Onion',
      scientificName: 'Allium cepa',
      imageUrl: 'assets/images/onion.jpg',
      season: 'Rabi (Nov-Dec) & Kharif (Jun-Jul)',
      soilType: 'Sandy loam to clay loam',
      waterRequirement: 'Light and frequent irrigation',
      duration: '120-150 days',
      yieldPerAcre: '100-120 quintals',
      temperature: '13-24°C',
      rainfall: '65-100 cm',
      diseases: [
        'Purple blotch',
        'Stemphylium blight',
        'Thrips attack',
      ],
      fertilizers: [
        'FYM: 10 tons/acre',
        'Urea: 80 kg/acre',
        'DAP: 100 kg/acre',
      ],
      cultivationSteps: [
        'Transplant 6-8 week old seedlings',
        'Maintain 15x10 cm spacing',
        'Light irrigation every 5-7 days',
        'Stop irrigation 15 days before harvest',
        'Harvest when tops fall over and dry',
      ],
    ),
  ];

  static List<CropInfo> searchCrops(String query) {
    if (query.isEmpty) return crops;
    return crops
        .where((crop) =>
            crop.name.toLowerCase().contains(query.toLowerCase()) ||
            crop.scientificName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  static CropInfo? getCropByName(String name) {
    try {
      return crops.firstWhere((crop) => crop.name == name);
    } catch (e) {
      return null;
    }
  }
}