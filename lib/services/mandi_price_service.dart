import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mandi_price_model.dart';

class MandiPriceService {
  // Government of India API for Mandi Prices
  static const String baseUrl = 'https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070';
  
  // Get your API key from: https://data.gov.in/
  // For demo purposes, using a sample key (you should get your own)
  static const String apiKey = '579b464db66ec23bdd000001cdd3946e44ce4aad7209ff7b23ac571b';

  // Fetch mandi prices
  Future<List<MandiPrice>> getMandiPrices({
    String? state,
    String? district,
    String? commodity,
    int limit = 100,
  }) async {
    try {
      // Build URL with filters
      Map<String, String> params = {
        'api-key': apiKey,
        'format': 'json',
        'limit': limit.toString(),
      };

      if (state != null && state.isNotEmpty) {
        params['filters[state]'] = state;
      }
      if (district != null && district.isNotEmpty) {
        params['filters[district]'] = district;
      }
      if (commodity != null && commodity.isNotEmpty) {
        params['filters[commodity]'] = commodity;
      }

      final uri = Uri.parse(baseUrl).replace(queryParameters: params);
      
      print('Fetching from: $uri');

      final response = await http.get(uri).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['records'] != null) {
          List<MandiPrice> prices = (data['records'] as List)
              .map((item) => MandiPrice.fromJson(item))
              .toList();
          
          print('Fetched ${prices.length} mandi prices');
          return prices;
        }
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }

      return _getDummyData(); // Fallback to dummy data if API fails
    } catch (e) {
      print('Error fetching mandi prices: $e');
      return _getDummyData(); // Return dummy data on error
    }
  }

  // Get list of available commodities
  Future<List<String>> getCommodities() async {
    try {
      final prices = await getMandiPrices(limit: 1000);
      final commodities = prices.map((p) => p.commodity).toSet().toList();
      commodities.sort();
      return commodities;
    } catch (e) {
      print('Error fetching commodities: $e');
      return _getDefaultCommodities();
    }
  }

  // Get list of states
  List<String> getStates() {
    return [
      'All States',
      'Andhra Pradesh',
      'Bihar',
      'Chhattisgarh',
      'Gujarat',
      'Haryana',
      'Himachal Pradesh',
      'Jharkhand',
      'Karnataka',
      'Kerala',
      'Madhya Pradesh',
      'Maharashtra',
      'Odisha',
      'Punjab',
      'Rajasthan',
      'Tamil Nadu',
      'Telangana',
      'Uttar Pradesh',
      'Uttarakhand',
      'West Bengal',
    ];
  }

  // Group prices by commodity
  List<CommodityGroup> groupByCommodity(List<MandiPrice> prices) {
    Map<String, List<MandiPrice>> grouped = {};
    
    for (var price in prices) {
      if (!grouped.containsKey(price.commodity)) {
        grouped[price.commodity] = [];
      }
      grouped[price.commodity]!.add(price);
    }

    return grouped.entries
        .map((entry) => CommodityGroup(
              name: entry.key,
              prices: entry.value,
            ))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  // Dummy data for demo/offline use
  List<MandiPrice> _getDummyData() {
    return [
      MandiPrice(
        state: 'Punjab',
        district: 'Amritsar',
        market: 'Amritsar',
        commodity: 'Wheat',
        variety: 'Desi',
        grade: 'FAQ',
        arrivalDate: DateTime.now().toString().split(' ')[0],
        minPrice: 2000,
        maxPrice: 2200,
        modalPrice: 2100,
      ),
      MandiPrice(
        state: 'Maharashtra',
        district: 'Pune',
        market: 'Pune',
        commodity: 'Rice',
        variety: 'Basmati',
        grade: 'A',
        arrivalDate: DateTime.now().toString().split(' ')[0],
        minPrice: 3500,
        maxPrice: 3800,
        modalPrice: 3650,
      ),
      MandiPrice(
        state: 'Gujarat',
        district: 'Ahmedabad',
        market: 'Ahmedabad',
        commodity: 'Cotton',
        variety: 'Medium',
        grade: 'FAQ',
        arrivalDate: DateTime.now().toString().split(' ')[0],
        minPrice: 5500,
        maxPrice: 6000,
        modalPrice: 5750,
      ),
      MandiPrice(
        state: 'Haryana',
        district: 'Karnal',
        market: 'Karnal',
        commodity: 'Paddy',
        variety: 'Common',
        grade: 'FAQ',
        arrivalDate: DateTime.now().toString().split(' ')[0],
        minPrice: 1900,
        maxPrice: 2100,
        modalPrice: 2000,
      ),
      MandiPrice(
        state: 'Uttar Pradesh',
        district: 'Meerut',
        market: 'Meerut',
        commodity: 'Sugarcane',
        variety: 'Local',
        grade: 'FAQ',
        arrivalDate: DateTime.now().toString().split(' ')[0],
        minPrice: 300,
        maxPrice: 350,
        modalPrice: 325,
      ),
    ];
  }

  List<String> _getDefaultCommodities() {
    return [
      'Wheat',
      'Rice',
      'Paddy',
      'Cotton',
      'Sugarcane',
      'Maize',
      'Bajra',
      'Jowar',
      'Gram',
      'Tur',
      'Moong',
      'Urad',
      'Groundnut',
      'Soyabean',
      'Mustard',
      'Sunflower',
      'Onion',
      'Potato',
      'Tomato',
    ];
  }
}