import 'package:flutter/material.dart';
import '../core/theme/colors.dart';

/// 3D Parallax Menu Carousel
/// Provides a sophisticated horizontal scrolling experience with depth effects
class ParallaxMenuCarousel extends StatefulWidget {
  final List<MenuCategory> categories;
  final Function(MenuCategory) onCategorySelected;
  final int selectedIndex;

  const ParallaxMenuCarousel({
    super.key,
    required this.categories,
    required this.onCategorySelected,
    this.selectedIndex = 0,
  });

  @override
  State<ParallaxMenuCarousel> createState() => _ParallaxMenuCarouselState();
}

class _ParallaxMenuCarouselState extends State<ParallaxMenuCarousel>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  double _currentPage = 0.0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _pageController = PageController(
      viewportFraction: 0.8,
      initialPage: _selectedIndex,
    );
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
      });
    });

    // Start the initial animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: SizedBox(
              height: 220,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                  widget.onCategorySelected(widget.categories[index]);
                },
                itemCount: widget.categories.length,
                itemBuilder: (context, index) {
                  return _buildCategoryCard(index);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(int index) {
    // Calculate parallax offset and scale for 3D effect
    final double offset = (_currentPage - index).abs();
    final double scale = 1 - (offset * 0.2).clamp(0.0, 0.3);
    final double rotationY = ((_currentPage - index) * 0.1).clamp(-0.2, 0.2);
    final double translationZ = offset * -50;
    
    // Calculate the parallax effect for background elements
    final double parallaxOffset = (_currentPage - index) * 100;
    
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateY(rotationY)
              ..translate(0.0, 0.0, translationZ),
            child: Transform.scale(
              scale: scale,
              child: _buildCategoryContent(index, parallaxOffset),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryContent(int index, double parallaxOffset) {
    final category = widget.categories[index];
    final isSelected = index == _selectedIndex;
    
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    MenuMateColors.citrusSpark.withOpacity(0.9),
                    MenuMateColors.citrusSparkDark,
                  ]
                : [
                    MenuMateColors.mintFog.withOpacity(0.7),
                    MenuMateColors.mintFogDark,
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? MenuMateColors.citrusSpark.withOpacity(0.3)
                  : MenuMateColors.mintFog.withOpacity(0.2),
              offset: const Offset(0, 8),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Parallax background pattern
            Positioned(
              top: parallaxOffset * 0.1,
              right: parallaxOffset * 0.05,
              child: Opacity(
                opacity: 0.1,
                child: Transform.scale(
                  scale: 1.5,
                  child: Icon(
                    category.icon,
                    size: 120,
                    color: MenuMateColors.pureWhite,
                  ),
                ),
              ),
            ),
            
            // Main content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category icon with animation
                  Hero(
                    tag: 'category-icon-${category.id}',
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 500),
                      tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.7),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 0.8 + (value * 0.4),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: MenuMateColors.pureWhite.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  offset: const Offset(0, 4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Icon(
                              category.icon,
                              color: isSelected
                                  ? MenuMateColors.citrusSpark
                                  : MenuMateColors.deepLagoon,
                              size: 30,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Category name
                  Hero(
                    tag: 'category-name-${category.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        category.name,
                        style: TextStyle(
                          color: MenuMateColors.pureWhite,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Items count with animation
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      color: MenuMateColors.pureWhite.withOpacity(0.9),
                      fontSize: isSelected ? 14 : 12,
                      fontWeight: FontWeight.w500,
                    ),
                    child: Text('${category.itemCount} items'),
                  ),
                  
                  // Animated indicator bar
                  const SizedBox(height: 12),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    width: isSelected ? 60 : 30,
                    height: 4,
                    decoration: BoxDecoration(
                      color: MenuMateColors.pureWhite,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: MenuMateColors.pureWhite.withOpacity(0.5),
                          offset: const Offset(0, 0),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Animated border highlight
            if (isSelected)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: MenuMateColors.pureWhite.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Menu category model
class MenuCategory {
  final String id;
  final String name;
  final IconData icon;
  final int itemCount;
  final String imageUrl;
  final List<String> popularItems;

  const MenuCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.itemCount,
    this.imageUrl = '',
    this.popularItems = const [],
  });
}

/// Sample categories for demonstration
class MenuCategorySamples {
  static const List<MenuCategory> categories = [
    MenuCategory(
      id: 'pizza',
      name: 'Pizza',
      icon: Icons.local_pizza,
      itemCount: 12,
      popularItems: ['Margherita', 'Pepperoni', 'Quattro Stagioni'],
    ),
    MenuCategory(
      id: 'burgers',
      name: 'Burgers',
      icon: Icons.lunch_dining,
      itemCount: 8,
      popularItems: ['Classic Beef', 'Chicken Deluxe', 'Veggie Burger'],
    ),
    MenuCategory(
      id: 'sushi',
      name: 'Sushi',
      icon: Icons.set_meal,
      itemCount: 15,
      popularItems: ['Salmon Roll', 'Tuna Nigiri', 'California Roll'],
    ),
    MenuCategory(
      id: 'salads',
      name: 'Salads',
      icon: Icons.eco,
      itemCount: 6,
      popularItems: ['Caesar Salad', 'Greek Salad', 'Quinoa Bowl'],
    ),
    MenuCategory(
      id: 'desserts',
      name: 'Desserts',
      icon: Icons.cake,
      itemCount: 10,
      popularItems: ['Chocolate Cake', 'Ice Cream', 'Tiramisu'],
    ),
  ];
}