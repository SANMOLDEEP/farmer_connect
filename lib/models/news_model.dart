class NewsArticle {
  final String title;
  final String description;
  final String content;
  final String author;
  final String source;
  final String url;
  final String imageUrl;
  final DateTime publishedAt;
  final String category;

  NewsArticle({
    required this.title,
    required this.description,
    required this.content,
    required this.author,
    required this.source,
    required this.url,
    required this.imageUrl,
    required this.publishedAt,
    this.category = 'general',
  });

  factory NewsArticle.fromNewsAPI(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      author: json['author'] ?? 'Unknown',
      source: json['source']?['name'] ?? 'Unknown Source',
      url: json['url'] ?? '',
      imageUrl: json['urlToImage'] ?? 'https://via.placeholder.com/400x200?text=No+Image',
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'])
          : DateTime.now(),
      category: 'agriculture',
    );
  }

  factory NewsArticle.fromGNews(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      author: json['source']?['name'] ?? 'Unknown',
      source: json['source']?['name'] ?? 'Unknown Source',
      url: json['url'] ?? '',
      imageUrl: json['image'] ?? 'https://via.placeholder.com/400x200?text=No+Image',
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'])
          : DateTime.now(),
      category: 'agriculture',
    );
  }

  // Time ago formatter
  String get timeAgo {
    final difference = DateTime.now().difference(publishedAt);
    
    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}