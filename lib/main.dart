import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kisanseva/screens/schemes/knowledge_base_screen.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/feed/feed_screen.dart';
import 'screens/disease/disease_screen.dart';
import 'screens/weather/weather_screen.dart';
import 'screens/crops/crops_screen.dart';
import 'screens/marketplace/marketplace_screen.dart';
import 'screens/equipment/equipment_rental_screen.dart';
import 'screens/schemes/schemes_screen.dart';
import 'screens/calculator/farm_calculator_screen.dart';
import 'screens/community/community_screen.dart';
import 'screens/mandi/mandi_prices_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'services/auth_service.dart';  // ✅ Make sure this is here

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmers_Connect',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ✅ NEW - Authentication Wrapper
// ✅ UPDATED - Authentication Wrapper
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            ),
          );
        }

        // Check if user is logged in
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          print('✅ User is logged in: ${user.email}');
          
          // ✅ Ensure user document exists in Firestore
          _authService.ensureUserDocumentExists(user);
          
          return const HomeScreen(); // User is logged in
        }
        
        print('❌ No user logged in');
        return const LoginScreen(); // User is NOT logged in
      },
    );
  }
}
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const FeedScreen(),
    const DiseaseScreen(),
    const WeatherScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article),
            label: 'News',
          ),
          NavigationDestination(
            icon: Icon(Icons.bug_report_outlined),
            selectedIcon: Icon(Icons.bug_report),
            label: 'Detect',
          ),
          NavigationDestination(
            icon: Icon(Icons.wb_sunny_outlined),
            selectedIcon: Icon(Icons.wb_sunny),
            label: 'Weather',
          ),
        ],
      ),
    );
  }
}

// ... rest of your AppFeature, AppFeatures, DashboardScreen code stays exactly the same

// ✅ FEATURE DATA MODEL
class AppFeature {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String category;
  final Widget? screen;
  final bool isActive;
  final bool adminOnly;

  AppFeature({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
    this.screen,
    this.isActive = true,
    this.adminOnly = false,
  });
}

// ✅ UPDATED FEATURE CONFIGURATION
class AppFeatures {
  static final List<AppFeature> all = [
    // ========== Core Features ==========
    AppFeature(
      id: 'crops',
      title: 'Crop Guide',
      description: 'Complete crop cultivation guide',
      icon: Icons.eco,
      color: Colors.green,
      category: 'Core Features',
      screen: const CropsScreen(),
      isActive: true,
    ),
    AppFeature(
      id: 'weather',
      title: 'Weather',
      description: 'Live weather & farming advice',
      icon: Icons.wb_sunny,
      color: Colors.orange,
      category: 'Core Features',
      screen: const WeatherScreen(),
      isActive: true,
    ),
    AppFeature(
      id: 'disease',
      title: 'Disease Detection',
      description: 'AI-powered disease identification',
      icon: Icons.local_hospital,
      color: Colors.red,
      category: 'Core Features',
      screen: const DiseaseScreen(),
      isActive: true,
    ),
    AppFeature(
      id: 'news',
      title: 'News Feed',
      description: 'Latest agricultural news',
      icon: Icons.article,
      color: Colors.blue,
      category: 'Core Features',
      screen: const FeedScreen(),
      isActive: true,
    ),
    
    // ========== Marketplace ==========
    AppFeature(
      id: 'marketplace',
      title: 'Marketplace',
      description: 'Buy & sell farm produce',
      icon: Icons.shopping_bag,
      color: Colors.purple,
      category: 'Marketplace',
      screen: const MarketplaceScreen(),
      isActive: true,
    ),
    AppFeature(
      id: 'equipment',
      title: 'Equipment Rental',
      description: 'Rent farming equipment',
      icon: Icons.agriculture,
      color: Colors.brown,
      category: 'Marketplace',
      screen: const EquipmentRentalScreen(),
      isActive: true,
    ),
    
    // ========== Resources ==========
    AppFeature(
      id: 'schemes',
      title: 'Govt. Schemes',
      description: 'Agricultural schemes & subsidies',
      icon: Icons.account_balance,
      color: Colors.indigo,
      category: 'Resources',
      screen: const SchemesScreen(),
      isActive: true,
    ),
    AppFeature(
      id: 'knowledge',
      title: 'Knowledge Base',
      description: 'Farming tips & best practices',
      icon: Icons.menu_book,
      color: Colors.teal,
      category: 'Resources',
      screen: const KnowledgeBaseScreen(),
      isActive: true,
    ),
    
    // ========== Tools ==========
    AppFeature(
      id: 'calculator',
      title: 'Farm Calculator',
      description: 'Calculate crop yield & profit',
      icon: Icons.calculate,
      color: Colors.amber,
      category: 'Tools',
      screen: const FarmCalculatorScreen(),
      isActive: true,
    ),
    AppFeature(
      id: 'community',
      title: 'Community',
      description: 'Connect with other farmers',
      icon: Icons.groups,
      color: Colors.cyan,
      category: 'Tools',
      screen: const CommunityScreen(),
      isActive: true,
    ),
    
    // ========== Market Information ==========
    AppFeature(
      id: 'mandi_prices',
      title: 'Mandi Prices',
      description: 'Live market prices for crops',
      icon: Icons.show_chart,
      color: Colors.lime,
      category: 'Market Information',
      screen: const MandiPricesScreen(),
      isActive: true,
    ),
  ];

  static Map<String, List<AppFeature>> getByCategory() {
    Map<String, List<AppFeature>> categorized = {};
    for (var feature in all) {
      categorized.putIfAbsent(feature.category, () => []);
      categorized[feature.category]!.add(feature);
    }
    return categorized;
  }

  static List<AppFeature> getActive() {
    return all.where((f) => f.isActive).toList();
  }

  static List<AppFeature> getComingSoon() {
    return all.where((f) => !f.isActive).toList();
  }
}

// ✅ DYNAMIC DASHBOARD
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categorizedFeatures = AppFeatures.getByCategory();
    final authService = AuthService();
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ✅ Beautiful App Bar with Profile
          SliverAppBar.large(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Farmers_Connect',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.green[700]!,
                      Colors.green[500]!,
                      Colors.lightGreen[400]!,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      bottom: -50,
                      child: Icon(
                        Icons.agriculture,
                        size: 200,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No new notifications')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          // ✅ Dynamic Content by Category
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  _buildWelcomeCard(context, authService),
                  const SizedBox(height: 24),

                  // Dynamic Feature Sections
                  ...categorizedFeatures.entries.map((entry) {
                    return _buildCategorySection(
                      context,
                      entry.key,
                      entry.value,
                    );
                  }).toList(),

                  // Tips Section
                  const SizedBox(height: 16),
                  _buildTipsCard(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CropsScreen()),
          );
        },
        icon: const Icon(Icons.eco),
        label: const Text('Crop Guide'),
        backgroundColor: Colors.green[700],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, AuthService authService) {
    return StreamBuilder(
      stream: authService.currentUserStream,
      builder: (context, snapshot) {
        final userName = snapshot.data?.name ?? 'Farmer';
        
        return Card(
          elevation: 0,
          color: Colors.green[50],
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[600],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.waving_hand,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, $userName!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your complete farming assistant',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    String category,
    List<AppFeature> features,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.green[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                category,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _buildFeatureGrid(context, features),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFeatureGrid(BuildContext context, List<AppFeature> features) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.15,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        return _buildFeatureCard(context, features[index]);
      },
    );
  }

  Widget _buildFeatureCard(BuildContext context, AppFeature feature) {
    return Card(
      elevation: feature.isActive ? 2 : 0,
      color: feature.isActive ? Colors.white : Colors.grey[100],
      child: InkWell(
        onTap: () {
          if (feature.isActive && feature.screen != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => feature.screen!),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${feature.title} - Coming Soon!'),
                duration: const Duration(seconds: 1),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: feature.color.withOpacity(feature.isActive ? 0.15 : 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      feature.icon,
                      size: 32,
                      color: feature.isActive ? feature.color : Colors.grey,
                    ),
                  ),
                  if (!feature.isActive)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Soon',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                feature.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: feature.isActive ? Colors.grey[800] : Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  feature.description,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    final tips = [
      {
        'icon': Icons.water_drop,
        'text': 'Early morning irrigation saves 30% water',
        'color': Colors.blue,
      },
      {
        'icon': Icons.wb_sunny,
        'text': 'Check weather daily for farming advice',
        'color': Colors.orange,
      },
      {
        'icon': Icons.local_hospital,
        'text': 'Regular crop inspection prevents diseases',
        'color': Colors.red,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Tips',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...tips.map((tip) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (tip['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (tip['color'] as Color).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                tip['icon'] as IconData,
                color: tip['color'] as Color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tip['text'] as String,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}