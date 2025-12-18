class CropInfo {
  final String name;
  final String scientificName;
  final String imageUrl;
  final String season;
  final String soilType;
  final String waterRequirement;
  final String duration;
  final String yieldPerAcre;
  final List<String> diseases;
  final List<String> fertilizers;
  final String temperature;
  final String rainfall;
  final List<String> cultivationSteps;

  CropInfo({
    required this.name,
    required this.scientificName,
    required this.imageUrl,
    required this.season,
    required this.soilType,
    required this.waterRequirement,
    required this.duration,
    required this.yieldPerAcre,
    required this.diseases,
    required this.fertilizers,
    required this.temperature,
    required this.rainfall,
    required this.cultivationSteps,
  });
}