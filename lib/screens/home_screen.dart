import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../core/theme/colors.dart';
import '../widgets/curved_bottom_navigation.dart';
import '../widgets/parallax_menu_carousel.dart';
import '../widgets/floating_food_card.dart';
import '../widgets/interactive_cart_drawer.dart';

/// MenuMate Home Screen
/// Showcases the next-level UI with sophisticated animations and interactions
class MenuMateHomeScreen extends StatefulWidget {
  const MenuMateHomeScreen({super.key});

  @override
  State<MenuMateHomeScreen> createState() => _MenuMateHomeScreenState();
}

class _MenuMateHomeScreenState extends State<MenuMateHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _searchController;
  late AnimationController _fabController;
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _searchFadeAnimation;
  late Animation<double> _fabScaleAnimation;
  
  int _currentNavIndex = 0;
  int _selectedCategoryIndex = 0;
  List<CartItem> _cartItems = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showCartDrawer = false;

  // Sample data
  final List<MenuCategory> _categories = MenuCategorySamples.categories;
  final List<FoodItem> _currentFoodItems = FoodItemSamples.pizzas;

  @override
  void initState() {
    super.initState();
    
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _searchController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _headerSlideAnimation = Tween<double>(
      begin: -100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutBack,
    ));
    
    _searchFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchController,
      curve: Curves.easeInOut,
    ));
    
    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    ));

    // Start animations with staggered timing
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _searchController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _fabController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _searchController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _addToCart(CartItem item) {
    setState(() {
      final existingIndex = _cartItems.indexWhere(
        (cartItem) => cartItem.foodItem.id == item.foodItem.id,
      );
      
      if (existingIndex >= 0) {
        _cartItems[existingIndex] = CartItem(
          foodItem: item.foodItem,
          quantity: _cartItems[existingIndex].quantity + 1,
        );
      } else {
        _cartItems.add(CartItem(
          foodItem: item.foodItem,
          quantity: 1,
        ));
      }
    });
    
    HapticFeedback.mediumImpact();
    _showAddToCartFeedback();
  }

  void _removeFromCart(CartItem item) {
    setState(() {
      _cartItems.removeWhere(
        (cartItem) => cartItem.foodItem.id == item.foodItem.id,
      );
    });
  }

  void _updateQuantity(CartItem updatedItem) {
    setState(() {
      final index = _cartItems.indexWhere(
        (item) => item.foodItem.id == updatedItem.foodItem.id,
      );
      if (index >= 0) {
        _cartItems[index] = updatedItem;
      }
    });
  }

  void _checkout() {
    // TODO: Implement checkout logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Checkout functionality coming soon!'),
        backgroundColor: MenuMateColors.citrusSpark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showAddToCartFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: MenuMateColors.pureWhite,
            ),
            const SizedBox(width: 8),
            const Text('Added to cart'),
            const Spacer(),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                setState(() {
                  _showCartDrawer = true;
                });
              },
              child: const Text(
                'VIEW CART',
                style: TextStyle(
                  color: MenuMateColors.pureWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: MenuMateColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: MenuMateColors.cloudWhite,
      body: Stack(
        children: [
          // Main content
          CustomScrollView(
            slivers: [
              // App Bar with animation
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: MenuMateColors.deepLagoon,
                flexibleSpace: AnimatedBuilder(
                  animation: _headerController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _headerSlideAnimation.value),
                      child: FlexibleSpaceBar(
                        title: const Text(
                          'MenuMate',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: MenuMateColors.pureWhite,
                          ),
                        ),
                        background: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: MenuMateColors.lagoonGradient,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                actions: [
                  AnimatedBuilder(
                    animation: _headerController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _headerController.value,
                        child: IconButton(
                          icon: Stack(
                            children: [
                              const Icon(
                                Icons.shopping_cart,
                                color: MenuMateColors.pureWhite,
                              ),
                              if (_cartItems.isNotEmpty)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: MenuMateColors.citrusSpark,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      '${_cartItems.length}',
                                      style: const TextStyle(
                                        color: MenuMateColors.charcoalBlack,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          onPressed: () {
                            setState(() {
                              _showCartDrawer = true;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              // Search bar
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _searchController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _searchFadeAnimation.value,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Hero(
                          tag: 'search-bar',
                          child: Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(16),
                            shadowColor: MenuMateColors.deepLagoon.withOpacity(0.2),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search for delicious food...',
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: MenuMateColors.mediumGray,
                                ),
                                suffixIcon: Icon(
                                  Icons.filter_list,
                                  color: MenuMateColors.deepLagoon,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: MenuMateColors.pureWhite,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Category carousel
              SliverToBoxAdapter(
                child: ParallaxMenuCarousel(
                  categories: _categories,
                  selectedIndex: _selectedCategoryIndex,
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategoryIndex = _categories.indexOf(category);
                    });
                  },
                ),
              ),
              
              // Food items grid
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  itemBuilder: (context, index) {
                    final foodItem = _currentFoodItems[index % _currentFoodItems.length];
                    return FloatingFoodCard(
                      foodItem: foodItem,
                      index: index,
                      isStaggered: true,
                      uniqueHeroId: 'grid-$index',  // Add unique identifier for Hero tags
                      onTap: () => _showFoodDetails(foodItem),
                      onAddToCart: () => _addToCart(CartItem(
                        foodItem: foodItem,
                        quantity: 1,
                      )),
                    );
                  },
                  childCount: _currentFoodItems.length * 2, // Show multiple items
                ),
              ),
              
              // Bottom padding for navigation
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
          
          // Cart drawer overlay
          if (_showCartDrawer)
            InteractiveCartDrawer(
              items: _cartItems,
              onItemAdded: _addToCart,
              onItemRemoved: _removeFromCart,
              onQuantityChanged: _updateQuantity,
              onCheckout: _checkout,
              onClose: () {
                setState(() {
                  _showCartDrawer = false;
                });
              },
            ),
        ],
      ),
      
      // Custom curved bottom navigation
      bottomNavigationBar: CurvedBottomNavigationBar(
        currentIndex: _currentNavIndex,
        items: const [
          CurvedNavigationItem(icon: Icons.home, label: 'Home'),
          CurvedNavigationItem(icon: Icons.search, label: 'Search'),
          CurvedNavigationItem(icon: Icons.favorite, label: 'Favorites'),
          CurvedNavigationItem(icon: Icons.person, label: 'Profile'),
        ],
        centerWidget: AnimatedBuilder(
          animation: _fabController,
          builder: (context, child) {
            return Transform.scale(
              scale: _fabScaleAnimation.value,
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _showCartDrawer = true;
                  });
                },
                backgroundColor: MenuMateColors.citrusSpark,
                elevation: 12,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.restaurant_menu,
                      color: MenuMateColors.charcoalBlack,
                      size: 28,
                    ),
                    if (_cartItems.isNotEmpty)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: MenuMateColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${_cartItems.length}',
                              style: const TextStyle(
                                color: MenuMateColors.pureWhite,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          HapticFeedback.selectionClick();
        },
      ),
    );
  }

  void _showFoodDetails(FoodItem foodItem) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FoodDetailSheet(
        foodItem: foodItem,
        onAddToCart: () {
          Navigator.pop(context);
          _addToCart(CartItem(foodItem: foodItem, quantity: 1));
        },
      ),
    );
  }
}

/// Food detail sheet with Hero animations
class FoodDetailSheet extends StatelessWidget {
  final FoodItem foodItem;
  final VoidCallback onAddToCart;

  const FoodDetailSheet({
    super.key,
    required this.foodItem,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: MenuMateColors.pureWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 60,
            height: 6,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: MenuMateColors.mediumGray.withOpacity(0.5),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          
          // Food image with Hero animation
          Expanded(
            flex: 2,
            child: Hero(
              tag: 'food-image-${foodItem.id}',
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: MenuMateColors.mintGradient,
                  ),
                ),
                child: Icon(
                  Icons.restaurant,
                  size: 120,
                  color: MenuMateColors.deepLagoon.withOpacity(0.3),
                ),
              ),
            ),
          ),
          
          // Food details
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'food-name-${foodItem.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        foodItem.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: MenuMateColors.charcoalBlack,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    foodItem.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: MenuMateColors.mediumGray,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Add to cart button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: onAddToCart,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_shopping_cart),
                          const SizedBox(width: 8),
                          Text('Add to Cart - \$${foodItem.price.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}