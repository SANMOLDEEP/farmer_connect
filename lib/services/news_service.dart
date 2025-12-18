import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_model.dart';

class NewsService {
  // ✅ ADD YOUR API KEY HERE
  static const String NEWS_API_KEY = '4bb49a7503474cd6ba98d5ca05f86bda';
  
  static const String NEWS_API_BASE = 'https://newsapi.org/v2';

  // Fetch ONLY agriculture news with strict filtering
  Future<List<NewsArticle>> fetchAgricultureNews({
    int pageSize = 100, // ✅ Increased from 30 to 100
  }) async {
    try {
      // ✅ Multiple searches to get more agriculture content
      final queries = [
        'agriculture farming India',
        'farmers crops harvest',
        'agricultural schemes government',
        'mandi prices MSP',
      ];
      
      List<NewsArticle> allArticles = [];
      
      // Fetch from multiple queries
      for (var query in queries) {
        final articles = await _fetchByQuery(query, pageSize ~/ queries.length);
        allArticles.addAll(articles);
        
        // Stop if we have enough
        if (allArticles.length >= 50) break;
      }
      
      // Remove duplicates
      final uniqueArticles = _removeDuplicates(allArticles);
      
      // ✅ STRICT FILTER to remove tech/phone/non-agriculture news
      final filteredArticles = _strictAgricultureFilter(uniqueArticles);
      
      print('✅ Fetched ${filteredArticles.length} agriculture articles');
      
      // If we got good articles from API, return them
      if (filteredArticles.length >= 10) {
        return filteredArticles;
      }
      
      // Otherwise return demo news
      return _getAgricultureDemoNews();
      
    } catch (e) {
      print('❌ Error: $e');
      return _getAgricultureDemoNews();
    }
  }

  // Fetch by specific query
  Future<List<NewsArticle>> _fetchByQuery(String query, int limit) async {
    try {
      final url = Uri.parse(
        '$NEWS_API_BASE/everything?'
        'q=$query&'
        'language=en&'
        'sortBy=publishedAt&'
        'pageSize=$limit&'
        'apiKey=$NEWS_API_KEY'
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'ok' && data['articles'] != null) {
          return (data['articles'] as List)
              .map((article) => NewsArticle.fromNewsAPI(article))
              .toList();
        }
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  // ✅ STRICT FILTERING - Remove tech, phones, crypto, etc.
  List<NewsArticle> _strictAgricultureFilter(List<NewsArticle> articles) {
    // ✅ BLACKLIST - Keywords that indicate NON-agriculture content
    final blacklistKeywords = [
      'smartphone', 'phone', 'mobile', 'iphone', 'android', 'samsung',
      'xiaomi', 'realme', 'oppo', 'vivo', 'oneplus', 'gsm', 'gsmarena',
      'laptop', 'computer', 'gaming', 'cryptocurrency', 'bitcoin',
      'blockchain', 'nft', 'metaverse', 'ai chatbot', 'openai',
      'tesla', 'electric car', 'ev battery', 'spacex', 'rocket',
      'football', 'cricket', 'sports', 'movie', 'bollywood',
      'election', 'politics', 'minister', 'parliament',
      'stock market', 'sensex', 'nifty', 'share price',
      'covid', 'vaccine', 'pandemic', 'virus',
    ];

    // ✅ WHITELIST - Keywords that confirm agriculture content
    final whitelistKeywords = [
      'agriculture', 'farming', 'farm', 'farmer', 'kisan', 'krishi',
      'crop', 'harvest', 'cultivation', 'sowing', 'reaping',
      'irrigation', 'pesticide', 'fertilizer', 'insecticide',
      'soil', 'seed', 'mandi', 'MSP', 'minimum support price',
      'agricultural', 'agri', 'rural', 'village',
      'wheat', 'rice', 'paddy', 'cotton', 'sugarcane', 'maize',
      'vegetables', 'fruits', 'horticulture',
      'livestock', 'dairy', 'cattle', 'poultry', 'fisheries',
      'tractor', 'combine harvester', 'farm equipment',
      'organic farming', 'sustainable agriculture',
      'crop insurance', 'kisan credit card', 'PM-KISAN',
      'agronomy', 'agrochemical', 'plantation',
      'rabi', 'kharif', 'yield', 'produce',
    ];

    return articles.where((article) {
      final titleLower = article.title.toLowerCase();
      final descLower = article.description.toLowerCase();
      final sourceLower = article.source.toLowerCase();
      final combined = '$titleLower $descLower $sourceLower';
      
      // ✅ REJECT if contains blacklisted keywords
      final hasBlacklistedContent = blacklistKeywords.any(
        (keyword) => combined.contains(keyword)
      );
      
      if (hasBlacklistedContent) {
        print('❌ Rejected: ${article.title}');
        return false;
      }
      
      // ✅ ACCEPT if contains whitelisted keywords
      final hasAgricultureContent = whitelistKeywords.any(
        (keyword) => combined.contains(keyword)
      );
      
      if (hasAgricultureContent) {
        print('✅ Accepted: ${article.title}');
        return true;
      }
      
      // If unsure, reject
      return false;
    }).toList();
  }

  // Remove duplicate articles
  List<NewsArticle> _removeDuplicates(List<NewsArticle> articles) {
    final seen = <String>{};
    return articles.where((article) {
      final key = article.title.toLowerCase();
      if (seen.contains(key)) {
        return false;
      }
      seen.add(key);
      return true;
    }).toList();
  }

  // ✅ 20+ DEMO AGRICULTURE NEWS ARTICLES (increased from 12)
  List<NewsArticle> _getAgricultureDemoNews() {
    return [
      NewsArticle(
        title: 'Government Announces ₹10,000 Crore Crop Insurance Scheme for Farmers',
        description: 'New Pradhan Mantri Fasal Bima Yojana expansion to cover more crops and provide better premium rates for small farmers.',
        content: 'The Ministry of Agriculture has announced a major expansion of the crop insurance scheme, benefiting over 5 crore farmers across India...',
        author: 'Agriculture Ministry',
        source: 'PIB India',
        url: 'https://pib.gov.in',
        imageUrl: 'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=800',
        publishedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      NewsArticle(
        title: 'Record Wheat Harvest: India Production Touches 112 Million Tonnes',
        description: 'Favorable monsoon and improved farming techniques lead to bumper wheat production in Punjab, Haryana, and Uttar Pradesh.',
        content: 'India achieves record wheat production this rabi season, with farmers reporting excellent crop health and higher yields...',
        author: 'Farm Reporter',
        source: 'Agriculture Today',
        url: 'https://agriculturetoday.in',
        imageUrl: 'https://images.unsplash.com/photo-1574943320219-553eb213f72d?w=800',
        publishedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      NewsArticle(
        title: 'MSP Hike: Paddy Minimum Support Price Increased by ₹200 per Quintal',
        description: 'Farmers welcome MSP hike for kharif crops, with paddy now at ₹2,183 per quintal for common variety.',
        content: 'Cabinet Committee approves increased Minimum Support Prices for all kharif crops for 2024-25 season...',
        author: 'Economic Affairs',
        source: 'Ministry of Agriculture',
        url: 'https://agricoop.gov.in',
        imageUrl: 'https://images.unsplash.com/photo-1536104968055-4d61aa56f46a?w=800',
        publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      NewsArticle(
        title: 'Drip Irrigation Revolution: Punjab Farmers Save 50% Water, Boost Yield',
        description: 'Modern irrigation techniques help farmers combat water scarcity while boosting crop productivity by 30%.',
        content: 'Farmers in Punjab adopt drip irrigation systems at scale, leading to significant water conservation...',
        author: 'Irrigation Desk',
        source: 'Farmer\'s Weekly',
        url: 'https://farmersweekly.co.in',
        imageUrl: 'https://images.unsplash.com/photo-1625246080702-c1e2bc25670b?w=800',
        publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      NewsArticle(
        title: 'Organic Farming Gets ₹5,000 Crore Boost from Central Government',
        description: 'New scheme aims to convert 1 crore hectares to organic farming in next 3 years with subsidies and training.',
        content: 'Government unveils comprehensive organic farming support package providing certification assistance...',
        author: 'Organic India',
        source: 'Sustainable Farming',
        url: 'https://sustainablefarming.in',
        imageUrl: 'https://images.unsplash.com/photo-1595855759920-86582396756a?w=800',
        publishedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      NewsArticle(
        title: 'Kisan Credit Card: 2% Interest Subsidy Extended for 7 Crore Farmers',
        description: 'RBI and Agriculture Ministry extend interest subvention scheme for short-term crop loans.',
        content: 'Farmers with KCC continue to get loans at subsidized interest rates with 2% interest subvention...',
        author: 'Banking Correspondent',
        source: 'Financial Express Agriculture',
        url: 'https://financialexpress.com',
        imageUrl: 'https://images.unsplash.com/photo-1579621970563-ebec7560ff3e?w=800',
        publishedAt: DateTime.now().subtract(const Duration(hours: 16)),
      ),
      NewsArticle(
        title: 'Agricultural Drones: Farmers Adopt Aerial Spraying Technology',
        description: 'Drone technology reduces pesticide use by 30% while covering large farm areas efficiently.',
        content: 'Progressive farmers embrace drone technology for precision spraying and crop monitoring...',
        author: 'AgriTech Reporter',
        source: 'Modern Farming',
        url: 'https://modernfarming.in',
        imageUrl: 'https://images.unsplash.com/photo-1473968512647-3e447244af8f?w=800',
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      NewsArticle(
        title: 'Monsoon Forecast: IMD Predicts 102% Normal Rainfall This Year',
        description: 'Good news for kharif sowing as meteorological department forecasts adequate rainfall.',
        content: 'Southwest monsoon expected to be normal, providing relief to farmers planning kharif cultivation...',
        author: 'Weather Bureau',
        source: 'IMD',
        url: 'https://mausam.imd.gov.in',
        imageUrl: 'https://images.unsplash.com/photo-1527482797697-8795b05a13fe?w=800',
        publishedAt: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
      ),
      NewsArticle(
        title: 'New BT Cotton Variant Resistant to Pink Bollworm Released by ICAR',
        description: 'Enhanced pest resistance and 25% higher yield potential in new cotton variety.',
        content: 'ICAR releases new BT cotton showing resistance to pink bollworm infestation...',
        author: 'Research Correspondent',
        source: 'ICAR News',
        url: 'https://icar.org.in',
        imageUrl: 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=800',
        publishedAt: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
      ),
      NewsArticle(
        title: 'FPO Funding: ₹6,865 Crore Allocated for Farmer Producer Organizations',
        description: 'Government strengthens 10,000 FPOs to help farmers get better prices and reduce middlemen.',
        content: 'Ministry of Agriculture increases funding for Farmer Producer Organizations to empower small farmers...',
        author: 'Rural Development',
        source: 'Ministry of Agriculture',
        url: 'https://agricoop.gov.in',
        imageUrl: 'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?w=800',
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      NewsArticle(
        title: 'E-NAM Platform Crosses ₹1 Lakh Crore in Digital Mandi Trading',
        description: 'Electronic National Agriculture Market connects 1.74 crore farmers across 1,361 mandis.',
        content: 'e-NAM platform revolutionizes agricultural marketing with transparent online trading...',
        author: 'Digital Agriculture',
        source: 'E-NAM',
        url: 'https://enam.gov.in',
        imageUrl: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800',
        publishedAt: DateTime.now().subtract(const Duration(days: 2, hours: 8)),
      ),
      NewsArticle(
        title: 'Heat-Tolerant Crop Varieties: Farmers Adopt Climate-Smart Agriculture',
        description: 'Rising temperatures push adoption of climate-resilient seeds developed by agricultural universities.',
        content: 'Research institutes develop heat and drought-tolerant varieties of wheat, rice, and millets...',
        author: 'Climate Desk',
        source: 'Agriculture Research',
        url: 'https://agricultureresearch.in',
        imageUrl: 'https://images.unsplash.com/photo-1628352081506-83c43123ed6b?w=800',
        publishedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      NewsArticle(
        title: 'PM-KISAN: Direct Benefit Transfer of ₹2,000 Credited to 11 Crore Farmers',
        description: 'Government releases 13th installment of PM-KISAN scheme ahead of kharif season.',
        content: 'Under Pradhan Mantri Kisan Samman Nidhi, eligible farmers receive ₹6,000 annual income support...',
        author: 'DBT Division',
        source: 'PM-KISAN Portal',
        url: 'https://pmkisan.gov.in',
        imageUrl: 'https://images.unsplash.com/photo-1593113598332-cd288d649433?w=800',
        publishedAt: DateTime.now().subtract(const Duration(days: 3, hours: 6)),
      ),
      NewsArticle(
        title: 'Vertical Farming Gains Traction: Urban Agriculture Revolution in India',
        description: 'Cities embrace vertical farming to grow pesticide-free vegetables using 95% less water.',
        content: 'Entrepreneurs and farmers adopt vertical farming technology for sustainable urban food production...',
        author: 'Urban Agriculture',
        source: 'Smart Farming',
        url: 'https://smartfarming.in',
        imageUrl: 'https://images.unsplash.com/photo-1530836369250-ef72a3f5cda8?w=800',
        publishedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      NewsArticle(
        title: 'Sugarcane FRP Increased: ₹315 per Quintal for 2024-25 Season',
        description: 'Fair and Remunerative Price hiked by ₹15, benefiting sugarcane farmers across UP, Maharashtra.',
        content: 'Cabinet approves higher FRP for sugarcane with premium for better sucrose recovery...',
        author: 'Sugar Industry',
        source: 'Sugar Federation',
        url: 'https://sugarindia.in',
        imageUrl: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800',
        publishedAt: DateTime.now().subtract(const Duration(days: 4, hours: 12)),
      ),
      NewsArticle(
        title: 'Soil Health Card Scheme: 25 Crore Cards Distributed to Farmers',
        description: 'Soil testing helps farmers optimize fertilizer use and increase crop productivity.',
        content: 'Government\'s Soil Health Card scheme provides nutrient status to help farmers make informed decisions...',
        author: 'Soil Science Division',
        source: 'Agriculture Department',
        url: 'https://soilhealth.dac.gov.in',
        imageUrl: 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800',
        publishedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      NewsArticle(
        title: 'Pulses Production Up 23%: India Moves Towards Self-Sufficiency',
        description: 'Increased cultivation of tur, moong, and urad reduces dependency on imports.',
        content: 'Farmers respond to government support with higher pulses cultivation area and productivity...',
        author: 'Pulses Board',
        source: 'IIPR',
        url: 'https://iipr.icar.gov.in',
        imageUrl: 'https://images.unsplash.com/photo-1589367920969-ab8e050bbb04?w=800',
        publishedAt: DateTime.now().subtract(const Duration(days: 5, hours: 8)),
      ),
      NewsArticle(
        title: 'Beekeeping Revolution: Honey Production Doubles in 5 Years',
        description: 'Sweet Revolution scheme transforms beekeeping into profitable agri-business for farmers.',
        content: 'National Beekeeping & Honey Mission helps farmers earn additional income through apiculture...',
        author: 'Horticulture Department',
        source: 'Bee Keeping Portal',
        url: 'https://beekeeping.nic.in',
        imageUrl: 'https://images.unsplash.com/photo-1558642452-9d2a7deb7f62?w=800',
        publishedAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
      NewsArticle(
        title: 'Zero Budget Natural Farming Adopted by 5 Lakh Farmers in Andhra Pradesh',
        description: 'Chemical-free farming method reduces input costs by 75% while maintaining yields.',
        content: 'State government promotes ZBNF as sustainable alternative to conventional farming practices...',
        author: 'Natural Farming',
        source: 'AP Agriculture',
        url: 'https://apzbnf.in',
        imageUrl: 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=800',
        publishedAt: DateTime.now().subtract(const Duration(days: 6, hours: 12)),
      ),
      NewsArticle(
        title: 'Greenhouse Farming: Maharashtra Farmers Earn ₹20 Lakh per Acre',
        description: 'Protected cultivation of capsicum, tomatoes yields 10 times higher returns than open fields.',
        content: 'Polyhouse farming emerges as lucrative option with government providing 50% subsidy...',
        author: 'Protected Cultivation',
        source: 'Horticulture Mission',
        url: 'https://horticulture.gov.in',
        imageUrl: 'https://images.unsplash.com/photo-1585518419759-7fe2e0fbf8a6?w=800',
        publishedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }
}