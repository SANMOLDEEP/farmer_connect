import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import '../../models/weather_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  WeatherData? _currentWeather;
  List<ForecastDay> _forecast = [];
  bool _loading = false;
  String _error = '';
  Position? _currentPosition;
  
  // Map overlay controls
  bool _showClouds = false; // Start with overlays OFF for faster loading
  bool _showPrecipitation = false;

  // Replace with your API key
  final String _apiKey = '2169ac126b392b6aba52302cdec95be3';

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permission denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied';
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      print('Location: ${position.latitude}, ${position.longitude}');

      setState(() {
        _currentPosition = position;
      });

      // Add units=metric for Celsius
      final weatherUrl = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey&units=metric',
      );
      final weatherResponse = await http.get(weatherUrl);

      print('Weather API Response: ${weatherResponse.statusCode}');
      
      if (weatherResponse.statusCode == 200) {
        final weatherData = json.decode(weatherResponse.body);
        print('Weather Icon Code: ${weatherData['weather'][0]['icon']}');
        
        setState(() {
          _currentWeather = WeatherData.fromJson(weatherData);
        });
      } else {
        throw 'Failed to load weather: ${weatherResponse.statusCode}';
      }

      final forecastUrl = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey&units=metric',
      );
      final forecastResponse = await http.get(forecastUrl);

      if (forecastResponse.statusCode == 200) {
        final data = json.decode(forecastResponse.body);
        final List<dynamic> list = data['list'];
        
        setState(() {
          _forecast = [];
          for (int i = 0; i < list.length && _forecast.length < 5; i += 8) {
            _forecast.add(ForecastDay.fromJson(list[i]));
          }
          _loading = false;
        });
      } else {
        throw 'Failed to load forecast';
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
      print('Weather error: $e');
    }
  }

  // Get weather icon based on code
  IconData _getWeatherIcon(String iconCode) {
    switch (iconCode) {
      case '01d':
      case '01n':
        return Icons.wb_sunny;
      case '02d':
      case '02n':
        return Icons.wb_cloudy;
      case '03d':
      case '03n':
      case '04d':
      case '04n':
        return Icons.cloud;
      case '09d':
      case '09n':
        return Icons.grain;
      case '10d':
      case '10n':
        return Icons.beach_access;
      case '11d':
      case '11n':
        return Icons.thunderstorm;
      case '13d':
      case '13n':
        return Icons.ac_unit;
      case '50d':
      case '50n':
        return Icons.foggy;
      default:
        return Icons.wb_sunny;
    }
  }

  // Get weather color based on code
  Color _getWeatherColor(String iconCode) {
    if (iconCode.startsWith('01')) return Colors.orange;
    if (iconCode.startsWith('02')) return Colors.amber;
    if (iconCode.startsWith('03') || iconCode.startsWith('04')) return Colors.grey;
    if (iconCode.startsWith('09') || iconCode.startsWith('10')) return Colors.blue;
    if (iconCode.startsWith('11')) return Colors.deepPurple;
    if (iconCode.startsWith('13')) return Colors.cyan;
    if (iconCode.startsWith('50')) return Colors.blueGrey;
    return Colors.blue;
  }

  // ✅ CONSOLIDATED farming advice as one string
  String _getFarmingAdvice(WeatherData weather) {
    List<String> advicePoints = [];

    // Temperature advice
    if (weather.temperature > 35) {
      advicePoints.add('🌡️ HIGH TEMPERATURE (${weather.temperature.toStringAsFixed(1)}°C): Ensure adequate watering during early morning and evening. Increase irrigation frequency by 30-50%. Provide shade nets for sensitive crops. Monitor for heat stress symptoms.');
    } else if (weather.temperature < 10) {
      advicePoints.add('❄️ COLD WEATHER (${weather.temperature.toStringAsFixed(1)}°C): Protect sensitive crops from frost using row covers or plastic tunnels. Delay planting warm-season crops. Cover young seedlings overnight.');
    } else if (weather.temperature >= 20 && weather.temperature <= 30) {
      advicePoints.add('✅ IDEAL TEMPERATURE (${weather.temperature.toStringAsFixed(1)}°C): Perfect for most farming activities. Excellent time for planting vegetables, transplanting seedlings, and field operations.');
    }

    // Rain advice
    if (weather.rain != null && weather.rain! > 0) {
      advicePoints.add('🌧️ RAIN DETECTED (${weather.rain}mm): Postpone pesticide/herbicide applications for 24-48 hours. Delay fertilizer to avoid nutrient runoff. Avoid field operations to prevent soil compaction.');
    } else if (weather.clouds > 70) {
      advicePoints.add('☁️ HEAVY CLOUDS (${weather.clouds}%): Rain likely within 6-12 hours. Postpone harvesting operations. Prepare drainage channels. Cover dried crops.');
    } else if (weather.clouds < 30) {
      advicePoints.add('☀️ CLEAR SKY (${weather.clouds}% clouds): Excellent for drying harvested crops and hay. Good visibility for field inspections. Ideal for spraying operations. Ensure adequate irrigation.');
    }

    // Humidity advice
    if (weather.humidity > 80) {
      advicePoints.add('💧 HIGH HUMIDITY (${weather.humidity}%): Increased risk of fungal diseases (blight, mildew). Inspect crops daily. Ensure good air circulation. Apply preventive fungicides if needed.');
    } else if (weather.humidity < 40) {
      advicePoints.add('🏜️ LOW HUMIDITY (${weather.humidity}%): Increase irrigation frequency by 20-40%. Apply 2-3 inch mulch layer. Water deeply and less frequently. Monitor for drought stress.');
    } else {
      advicePoints.add('💦 OPTIMAL HUMIDITY (${weather.humidity}%): Perfect moisture conditions. Good for transplanting. Low disease pressure. Excellent for pollination activities.');
    }

    // Wind advice
    if (weather.windSpeed > 20) {
      advicePoints.add('💨 STRONG WINDS (${weather.windSpeed.toStringAsFixed(1)} m/s): Avoid all spraying operations - high drift risk. Postpone drone operations. Secure loose equipment and materials. Check for crop lodging.');
    } else if (weather.windSpeed < 5) {
      advicePoints.add('🍃 CALM WINDS (${weather.windSpeed.toStringAsFixed(1)} m/s): Perfect for precision pesticide application. Ideal for drone spraying. Excellent for foliar feeding. Best for spreading granular fertilizers.');
    }

    // General advice
    if (weather.temperature >= 15 && weather.temperature <= 25 && 
        weather.humidity >= 40 && weather.humidity <= 70 && 
        weather.rain == null) {
      advicePoints.add('🌾 PERFECT FARMING CONDITIONS: All parameters ideal! Best day for harvesting. Excellent for transplanting. Perfect for soil preparation and planting. Ideal for applying organic fertilizers.');
    }

    // Pest monitoring
    if (weather.temperature > 20 && weather.temperature < 30 && weather.humidity > 60) {
      advicePoints.add('🐛 PEST MONITORING: Temperature and humidity favor insect activity. Scout fields for aphids, whiteflies, caterpillars. Check underside of leaves for eggs. Set up pheromone traps.');
    }

    // Irrigation advice
    if (weather.rain == null && weather.clouds < 40 && weather.temperature > 25) {
      advicePoints.add('💧 IRRIGATION RECOMMENDED: Dry conditions forecast. Check soil moisture at 6-8 inch depth. Water deep and early in morning (5-8 AM) to minimize evaporation.');
    }

    return advicePoints.join('\n\n');
  }

  // ✅ SIMPLIFIED MAP - Faster loading, no HTTP client issues
  Widget _buildMap() {
    if (_currentPosition == null) {
      return const SizedBox();
    }

    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                ),
                initialZoom: 8.0, // ✅ Lower zoom for faster loading
                maxZoom: 15.0,
                minZoom: 5.0,
              ),
              children: [
                // Base map layer
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.farmingapp.weather',
                  maxNativeZoom: 19,
                  keepBuffer: 2, // ✅ Reduce buffer for better performance
                ),
                
                // ✅ FIXED: Clouds overlay with proper opacity handling
                if (_showClouds)
                  TileLayer(
                    urlTemplate: 'https://tile.openweathermap.org/map/clouds_new/{z}/{x}/{y}.png?appid=$_apiKey',
                    userAgentPackageName: 'com.farmingapp.weather',
                    backgroundColor: Colors.transparent,
                    tileDisplay: TileDisplay.fadeIn(),
                  ),
                
                // ✅ FIXED: Precipitation overlay
                if (_showPrecipitation)
                  TileLayer(
                    urlTemplate: 'https://tile.openweathermap.org/map/precipitation_new/{z}/{x}/{y}.png?appid=$_apiKey',
                    userAgentPackageName: 'com.farmingapp.weather',
                    backgroundColor: Colors.transparent,
                    tileDisplay: TileDisplay.fadeIn(),
                  ),
                
                // Location marker
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      width: 100,
                      height: 100,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Text(
                              _currentWeather?.cityName ?? 'You',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            // ✅ Simplified layer control buttons
            Positioned(
              top: 10,
              right: 10,
              child: Column(
                children: [
                  _buildLayerButton(
                    'Clouds',
                    Icons.cloud,
                    _showClouds,
                    () => setState(() => _showClouds = !_showClouds),
                  ),
                  const SizedBox(height: 6),
                  _buildLayerButton(
                    'Rain',
                    Icons.water_drop,
                    _showPrecipitation,
                    () => setState(() => _showPrecipitation = !_showPrecipitation),
                  ),
                ],
              ),
            ),
            
            // OSM Attribution
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                color: Colors.white.withOpacity(0.7),
                child: const Text(
                  '© OpenStreetMap',
                  style: TextStyle(fontSize: 9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayerButton(String label, IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Weather Forecast'),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchWeather,
            tooltip: 'Refresh Weather',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: $_error',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _fetchWeather,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _currentWeather == null
                  ? const Center(child: Text('No weather data'))
                  : RefreshIndicator(
                      onRefresh: _fetchWeather,
                      child: ListView(
                        padding: const EdgeInsets.all(0),
                        children: [
                          // Current weather card
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getWeatherColor(_currentWeather!.icon),
                                  _getWeatherColor(_currentWeather!.icon).withOpacity(0.7),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  Text(
                                    _currentWeather!.cityName,
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    DateFormat('EEEE, MMMM d').format(DateTime.now()),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Weather icon with fallback
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 160,
                                        height: 160,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Icon(
                                        _getWeatherIcon(_currentWeather!.icon),
                                        size: 100,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  Text(
                                    '${_currentWeather!.temperature.toStringAsFixed(0)}°C',
                                    style: const TextStyle(
                                      fontSize: 72,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    _currentWeather!.description.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      letterSpacing: 2,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _weatherDetail(
                                        Icons.thermostat,
                                        'Feels Like',
                                        '${_currentWeather!.feelsLike.toStringAsFixed(0)}°C',
                                      ),
                                      _weatherDetail(
                                        Icons.water_drop,
                                        'Humidity',
                                        '${_currentWeather!.humidity}%',
                                      ),
                                      _weatherDetail(
                                        Icons.air,
                                        'Wind',
                                        '${_currentWeather!.windSpeed.toStringAsFixed(1)} m/s',
                                      ),
                                    ],
                                  ),
                                  if (_currentWeather!.rain != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.water_drop,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Rainfall: ${_currentWeather!.rain} mm',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // MAP
                          _buildMap(),

                          const SizedBox(height: 16),

                          // ✅ CONSOLIDATED Farming advice in ONE card
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.green[50]!,
                                      Colors.green[100]!,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.green[600],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.agriculture,
                                              color: Colors.white,
                                              size: 28,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Farming Recommendations',
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green[900],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _getFarmingAdvice(_currentWeather!),
                                          style: TextStyle(
                                            fontSize: 15,
                                            height: 1.8,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ✅ FIXED: 5-day forecast with proper layout
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.calendar_month, color: Colors.blue[700], size: 24),
                                    const SizedBox(width: 8),
                                    const Text(
                                      '5-Day Forecast',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ..._forecast.map((day) => Card(
                                      elevation: 2,
                                      margin: const EdgeInsets.only(bottom: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          children: [
                                            // Weather icon
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: _getWeatherColor(day.icon).withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                _getWeatherIcon(day.icon),
                                                size: 36,
                                                color: _getWeatherColor(day.icon),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            // Date and description
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    DateFormat('EEE, MMM d').format(day.date),
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    day.description,
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 13,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Temperature
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '${day.tempMax.toStringAsFixed(0)}°',
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                Text(
                                                  '${day.tempMin.toStringAsFixed(0)}°',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.blue[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
    );
  }

  Widget _weatherDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}