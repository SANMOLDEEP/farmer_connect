class FeedModel {
  final String headline;
  final String date;
  final String imageUrl;
  final String url;

  FeedModel({
    required this.headline,
    required this.date,
    required this.imageUrl,
    required this.url,
  });

  factory FeedModel.fromJson(Map<String, dynamic> json) {
    return FeedModel(
      headline: json['headline'] ?? '',
      date: json['date'] ?? '',
      imageUrl: json['img'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'headline': headline,
      'date': date,
      'img': imageUrl,
      'url': url,
    };
  }
}