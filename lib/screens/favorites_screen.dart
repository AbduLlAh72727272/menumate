import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/colors.dart';
import '../widgets/menumate_app_bar.dart';

/// Favorites screen with heart animations and grid layout
/// Features saved items management and smooth interactions
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;
  late AnimationController _heartController;
  late List<AnimationController> _cardControllers;
  
  String _selectedTab = 'All';
  final List<String> _tabs = ['All', 'Food', 'Restaurants'];

  List<FavoriteItem> _favoriteItems = [
    FavoriteItem(
      id: '1',
      name: 'Truffle Pizza',
      restaurant: 'Italiano Bistro',
      price: 26.99,
      rating: 4.9,
      type: FavoriteType.food,
      image: 'truffle_pizza.jpg',
      isFavorite: true,
    ),
    FavoriteItem(
      id: '2',
      name: 'Sakura Sushi',
      restaurant: 'Sushi Master',
      price: 0.0, // Restaurant, no price
      rating: 4.8,
      type: FavoriteType.restaurant,
      image: 'sushi_restaurant.jpg',
      isFavorite: true,
    ),
    FavoriteItem(
      id: '3',
      name: 'Wagyu Burger',
      restaurant: 'Gourmet House',
      price: 32.50,
      rating: 4.7,
      type: FavoriteType.food,
      image: 'wagyu_burger.jpg',
      isFavorite: true,
    ),
    FavoriteItem(
      id: '4',
      name: 'Le Petit Café',
      restaurant: 'French Cuisine',
      price: 0.0, // Restaurant
      rating: 4.6,
      type: FavoriteType.restaurant,
      image: 'french_restaurant.jpg',
      isFavorite: true,
    ),
    FavoriteItem(
      id: '5',
      name: 'Chocolate Lava Cake',
      restaurant: 'Sweet Dreams',
      price: 14.99,
      rating: 4.8,
      type: FavoriteType.food,
      image: 'lava_cake.jpg',
      isFavorite: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _cardControllers = List.generate(
      _favoriteItems.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 800 + (index * 100)),
        vsync: this,
      ),
    );

    // Start staggered animation
    _startStaggeredAnimation();
  }

  void _startStaggeredAnimation() {
    for (int i = 0; i < _cardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _cardControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _heartController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  List<FavoriteItem> get _filteredItems {
    if (_selectedTab == 'All') return _favoriteItems;
    return _favoriteItems.where((item) {
      return _selectedTab == 'Food' 
          ? item.type == FavoriteType.food
          : item.type == FavoriteType.restaurant;
    }).toList();
  }

  void _toggleFavorite(String itemId) async {
    setState(() {
      final item = _favoriteItems.firstWhere((item) => item.id == itemId);
      item.isFavorite = !item.isFavorite;
    });

    // Heart animation
    _heartController.reset();
    _heartController.forward();
    
    HapticFeedback.mediumImpact();

    // Remove item after animation if unfavorited
    final item = _favoriteItems.firstWhere((item) => item.id == itemId);
    if (!item.isFavorite) {
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _favoriteItems.removeWhere((item) => item.id == itemId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MenuMateColors.cloudWhite,
      appBar: MenuMateFavoritesAppBar(
        onSearchTap: () {
          Navigator.pushNamed(context, '/search');
        },
      ),
      body: Column(
        children: [
          _buildTabBar(),
          _buildEmptyState(),
          Expanded(
            child: _filteredItems.isEmpty 
                ? _buildEmptyContent()
                : _buildFavoritesGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MenuMateColors.pureWhite,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: MenuMateColors.deepLagoon.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: _tabs.map((tab) {
          final isSelected = tab == _selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = tab;
                });
                HapticFeedback.lightImpact();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            MenuMateColors.deepLagoon,
                            MenuMateColors.mintFog,
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tab,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected 
                        ? MenuMateColors.pureWhite
                        : MenuMateColors.deepLagoon.withOpacity(0.7),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    final count = _filteredItems.length;
    if (count == 0) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$count ${count == 1 ? 'favorite' : 'favorites'}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: MenuMateColors.deepLagoon.withOpacity(0.8),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              // Clear all favorites
              setState(() {
                for (var item in _favoriteItems) {
                  item.isFavorite = false;
                }
                _favoriteItems.clear();
              });
              HapticFeedback.lightImpact();
            },
            icon: Icon(
              Icons.clear_all,
              size: 18,
              color: MenuMateColors.citrusSpark,
            ),
            label: Text(
              'Clear All',
              style: TextStyle(
                color: MenuMateColors.citrusSpark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: MenuMateColors.mintFog.withOpacity(0.3),
                  ),
                  child: Icon(
                    Icons.favorite_border,
                    size: 60,
                    color: MenuMateColors.deepLagoon.withOpacity(0.5),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            _selectedTab == 'All' 
                ? 'No favorites yet'
                : 'No ${_selectedTab.toLowerCase()} favorites',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: MenuMateColors.deepLagoon.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start exploring and add items to your favorites',
            style: TextStyle(
              fontSize: 14,
              color: MenuMateColors.deepLagoon.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MenuMateColors.deepLagoon,
              foregroundColor: MenuMateColors.pureWhite,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: const Icon(Icons.search),
            label: const Text('Explore Food'),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        final controllerIndex = _favoriteItems.indexOf(item);
        final controller = controllerIndex < _cardControllers.length 
            ? _cardControllers[controllerIndex]
            : null;
        
        return _buildFavoriteCard(item, controller);
      },
    );
  }

  Widget _buildFavoriteCard(FavoriteItem item, AnimationController? controller) {
    if (controller == null) {
      return _buildCardContent(item);
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: controller,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: controller,
          curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
        ));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: _buildCardContent(item),
          ),
        );
      },
    );
  }

  Widget _buildCardContent(FavoriteItem item) {
    return Container(
      decoration: BoxDecoration(
        color: MenuMateColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: MenuMateColors.deepLagoon.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.mediumImpact();
            // Navigate to detail screen
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image container with favorite button
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            MenuMateColors.mintFog,
                            MenuMateColors.citrusSpark.withOpacity(0.3),
                          ],
                        ),
                      ),
                      child: Icon(
                        item.type == FavoriteType.food 
                            ? Icons.restaurant_menu
                            : Icons.store,
                        size: 40,
                        color: MenuMateColors.deepLagoon.withOpacity(0.7),
                      ),
                    ),
                    
                    // Favorite button
                    Positioned(
                      top: 12,
                      right: 12,
                      child: AnimatedBuilder(
                        animation: _heartController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_heartController.value * 0.3),
                            child: GestureDetector(
                              onTap: () => _toggleFavorite(item.id),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: MenuMateColors.pureWhite,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: MenuMateColors.deepLagoon.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  item.isFavorite 
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: item.isFavorite 
                                      ? Colors.red
                                      : MenuMateColors.deepLagoon.withOpacity(0.5),
                                  size: 20,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: MenuMateColors.deepLagoon,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.restaurant,
                            style: TextStyle(
                              fontSize: 12,
                              color: MenuMateColors.deepLagoon.withOpacity(0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 16,
                                color: MenuMateColors.citrusSpark,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.rating.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: MenuMateColors.deepLagoon,
                                ),
                              ),
                            ],
                          ),
                          
                          if (item.type == FavoriteType.food)
                            Text(
                              '\$${item.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: MenuMateColors.citrusSpark,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Favorite item data model
class FavoriteItem {
  final String id;
  final String name;
  final String restaurant;
  final double price;
  final double rating;
  final FavoriteType type;
  final String image;
  bool isFavorite;

  FavoriteItem({
    required this.id,
    required this.name,
    required this.restaurant,
    required this.price,
    required this.rating,
    required this.type,
    required this.image,
    this.isFavorite = false,
  });
}

enum FavoriteType { food, restaurant }