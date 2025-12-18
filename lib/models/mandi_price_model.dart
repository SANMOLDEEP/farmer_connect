class MandiPrice {
  final String state;
  final String district;
  final String market;
  final String commodity;
  final String variety;
  final String grade;
  final String arrivalDate;
  final double minPrice;
  final double maxPrice;
  final double modalPrice;
  
  MandiPrice({
    required this.state,
    required this.district,
    required this.market,
    required this.commodity,
    required this.variety,
    required this.grade,
    required this.arrivalDate,
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
  });

  factory MandiPrice.fromJson(Map<String, dynamic> json) {
    return MandiPrice(
      state: json['state'] ?? '',
      district: json['district'] ?? '',
      market: json['market'] ?? '',
      commodity: json['commodity'] ?? '',
      variety: json['variety'] ?? '',
      grade: json['grade'] ?? '',
      arrivalDate: json['arrival_date'] ?? '',
      minPrice: _parsePrice(json['min_price']),
      maxPrice: _parsePrice(json['max_price']),
      modalPrice: _parsePrice(json['modal_price']),
    );
  }

  static double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    if (price is num) return price.toDouble();
    if (price is String) return double.tryParse(price) ?? 0.0;
    return 0.0;
  }

  // Get price trend indicator
  String get trend {
    if (modalPrice > (minPrice + maxPrice) / 2) return 'up';
    if (modalPrice < (minPrice + maxPrice) / 2) return 'down';
    return 'stable';
  }

  // Format price in Indian rupee format
  String formatPrice(double price) {
    return '₹${price.toStringAsFixed(2)}';
  }
}

// For grouping prices by commodity
class CommodityGroup {
  final String name;
  final List<MandiPrice> prices;

  CommodityGroup({
    required this.name,
    required this.prices,
  });

  double get averagePrice {
    if (prices.isEmpty) return 0.0;
    double total = prices.fold(0.0, (sum, price) => sum + price.modalPrice);
    return total / prices.length;
  }

  double get minPrice {
    if (prices.isEmpty) return 0.0;
    return prices.map((p) => p.minPrice).reduce((a, b) => a < b ? a : b);
  }

  double get maxPrice {
    if (prices.isEmpty) return 0.0;
    return prices.map((p) => p.maxPrice).reduce((a, b) => a > b ? a : b);
  }
}