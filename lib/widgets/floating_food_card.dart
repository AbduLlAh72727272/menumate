import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/colors.dart';

/// Asymmetrical food card with custom shapes and interactive elements
/// Features ClipPath for unique shapes and interactive ingredient labels
class FloatingFoodCard extends StatefulWidget {
  final FoodItem foodItem;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final bool isStaggered;
  final int index;
  final String? uniqueHeroId;

  const FloatingFoodCard({
    super.key,
    required this.foodItem,
    required this.onTap,
    required this.onAddToCart,
    this.isStaggered = false,
    this.index = 0,
    this.uniqueHeroId,
  });

  @override
  State<FloatingFoodCard> createState() => _FloatingFoodCardState();
}

class _FloatingFoodCardState extends State<FloatingFoodCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _badgeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;
  late Animation<double> _badgeOpacityAnimation;
  late Animation<Offset> _badgeSlideAnimation;
  
  bool _isPressed = false;
  bool _showIngredients = false;

  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _badgeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
    
    _shadowAnimation = Tween<double>(
      begin: 8.0,
      end: 16.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
    
    _badgeOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _badgeController,
      curve: Curves.easeOutBack,
    ));
    
    _badgeSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _badgeController,
      curve: Curves.easeOutBack,
    ));

    // Stagger the initial animation
    Future.delayed(Duration(milliseconds: widget.index * 150), () {
      if (mounted) {
        _hoverController.forward();
      }
    });
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  void _onPressStart() {
    setState(() {
      _isPressed = true;
      _showIngredients = true;
    });
    _badgeController.forward();
    HapticFeedback.lightImpact();
  }

  void _onPressEnd() {
    setState(() {
      _isPressed = false;
      _showIngredients = false;
    });
    _badgeController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final cardHeight = widget.isStaggered 
        ? (widget.index % 2 == 0 ? 280.0 : 320.0)
        : 300.0;
    
    return AnimatedBuilder(
      animation: Listenable.merge([_hoverController, _badgeController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _isPressed ? 0.98 : _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _onPressStart(),
            onTapUp: (_) => _onPressEnd(),
            onTapCancel: _onPressEnd,
            onTap: widget.onTap,
            child: Container(
              height: cardHeight,
              margin: const EdgeInsets.all(8),
              child: Stack(
                children: [
                  // Main card with custom shape
                  ClipPath(
                    clipper: AsymmetricCardClipper(
                      cornerRadius: 24,
                      cutoutSize: 20,
                      index: widget.index,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: MenuMateColors.pureWhite,
                        boxShadow: [
                          BoxShadow(
                            color: MenuMateColors.charcoalBlack.withOpacity(0.1),
                            offset: Offset(0, _shadowAnimation.value),
                            blurRadius: _shadowAnimation.value * 1.5,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: MenuMateColors.citrusSpark.withOpacity(0.1),
                            offset: const Offset(0, 0),
                            blurRadius: 20,
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: _buildCardContent(),
                    ),
                  ),
                  
                  // Interactive ingredient badges
                  if (_showIngredients) ..._buildIngredientBadges(),
                  
                  // Add to cart button with animation
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Hero(
                      tag: widget.uniqueHeroId != null 
                        ? 'add-to-cart-${widget.uniqueHeroId}' 
                        : 'add-to-cart-${widget.foodItem.id}',
                      child: GestureDetector(
                        onTap: widget.onAddToCart,
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 400),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: MenuMateColors.citrusSpark,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: MenuMateColors.citrusSpark.withOpacity(0.4),
                                      offset: const Offset(0, 4),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: MenuMateColors.charcoalBlack,
                                  size: 24,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  // Price tag with custom shape
                  Positioned(
                    top: 16,
                    right: 16,
                    child: ClipPath(
                      clipper: PriceTagClipper(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: MenuMateColors.citrusGradient,
                          ),
                        ),
                        child: Text(
                          '\$${widget.foodItem.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: MenuMateColors.charcoalBlack,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Food image with gradient overlay
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              // Placeholder food image
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      MenuMateColors.mintFog.withOpacity(0.3),
                      MenuMateColors.mintFogLight.withOpacity(0.5),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.restaurant,
                  size: 80,
                  color: MenuMateColors.deepLagoon.withOpacity(0.3),
                ),
              ),
              
              // Gradient overlay for better text readability
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 60,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Food details
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),  // Reduced from 16
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,  // Use minimum space
              children: [
                // Food name
                Flexible(
                  child: Text(
                    widget.foodItem.name,
                    style: const TextStyle(
                      fontSize: 16,  // Reduced from 18
                      fontWeight: FontWeight.bold,
                      color: MenuMateColors.charcoalBlack,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                const SizedBox(height: 2),  // Reduced from 4
                
                // Description
                Flexible(
                  child: Text(
                    widget.foodItem.description,
                    style: TextStyle(
                      fontSize: 11,  // Reduced from 12
                      color: MenuMateColors.mediumGray,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                const SizedBox(height: 6),  // Reduced from 8
                
                // Rating and time row
                Flexible(
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: MenuMateColors.citrusSpark,
                        size: 14,  // Reduced from 16
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.foodItem.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 11,  // Reduced from 12
                          fontWeight: FontWeight.w600,
                          color: MenuMateColors.charcoalBlack,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.access_time,
                        color: MenuMateColors.mediumGray,
                        size: 14,  // Reduced from 16
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.foodItem.preparationTime} min',
                        style: TextStyle(
                          fontSize: 11,  // Reduced from 12
                          color: MenuMateColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildIngredientBadges() {
    final badges = <Widget>[];
    final ingredientPositions = [
      const Offset(20, 120),
      const Offset(120, 100),
      const Offset(80, 160),
    ];
    
    for (int i = 0; i < widget.foodItem.keyIngredients.length && i < 3; i++) {
      badges.add(
        Positioned(
          left: ingredientPositions[i].dx,
          top: ingredientPositions[i].dy,
          child: SlideTransition(
            position: _badgeSlideAnimation,
            child: FadeTransition(
              opacity: _badgeOpacityAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: MenuMateColors.mintFog,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: MenuMateColors.mintFog.withOpacity(0.4),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Text(
                  widget.foodItem.keyIngredients[i],
                  style: const TextStyle(
                    color: MenuMateColors.charcoalBlack,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    return badges;
  }
}

/// Custom clipper for asymmetric card shapes
class AsymmetricCardClipper extends CustomClipper<Path> {
  final double cornerRadius;
  final double cutoutSize;
  final int index;

  AsymmetricCardClipper({
    required this.cornerRadius,
    required this.cutoutSize,
    required this.index,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final isEven = index % 2 == 0;
    
    if (isEven) {
      // Even cards: top-right cutout
      path.moveTo(cornerRadius, 0);
      path.lineTo(size.width - cornerRadius - cutoutSize, 0);
      path.lineTo(size.width - cornerRadius, cutoutSize);
      path.quadraticBezierTo(
        size.width,
        cutoutSize + cornerRadius,
        size.width,
        cutoutSize + cornerRadius * 2,
      );
      path.lineTo(size.width, size.height - cornerRadius);
      path.quadraticBezierTo(
        size.width,
        size.height,
        size.width - cornerRadius,
        size.height,
      );
      path.lineTo(cornerRadius, size.height);
      path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);
      path.lineTo(0, cornerRadius);
      path.quadraticBezierTo(0, 0, cornerRadius, 0);
    } else {
      // Odd cards: bottom-left cutout
      path.moveTo(cornerRadius, 0);
      path.lineTo(size.width - cornerRadius, 0);
      path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);
      path.lineTo(size.width, size.height - cornerRadius);
      path.quadraticBezierTo(
        size.width,
        size.height,
        size.width - cornerRadius,
        size.height,
      );
      path.lineTo(cornerRadius + cutoutSize, size.height);
      path.lineTo(cornerRadius, size.height - cutoutSize);
      path.quadraticBezierTo(
        0,
        size.height - cutoutSize - cornerRadius,
        0,
        size.height - cutoutSize - cornerRadius * 2,
      );
      path.lineTo(0, cornerRadius);
      path.quadraticBezierTo(0, 0, cornerRadius, 0);
    }
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Custom clipper for price tags
class PriceTagClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const notchSize = 6.0;
    
    path.moveTo(0, 0);
    path.lineTo(size.width - notchSize, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - notchSize, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Food item model
class FoodItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final double rating;
  final int preparationTime;
  final String imageUrl;
  final List<String> keyIngredients;
  final bool isVegetarian;
  final bool isSpicy;

  const FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.rating,
    required this.preparationTime,
    this.imageUrl = '',
    this.keyIngredients = const [],
    this.isVegetarian = false,
    this.isSpicy = false,
  });
}

/// Sample food items for demonstration
class FoodItemSamples {
  static const List<FoodItem> pizzas = [
    FoodItem(
      id: 'margherita',
      name: 'Margherita Classic',
      description: 'Fresh tomatoes, mozzarella, basil',
      price: 14.99,
      rating: 4.8,
      preparationTime: 15,
      keyIngredients: ['Tomato', 'Mozzarella', 'Basil'],
      isVegetarian: true,
    ),
    FoodItem(
      id: 'pepperoni',
      name: 'Pepperoni Deluxe',
      description: 'Spicy pepperoni, cheese, tomato sauce',
      price: 18.99,
      rating: 4.7,
      preparationTime: 18,
      keyIngredients: ['Pepperoni', 'Cheese', 'Spice'],
      isSpicy: true,
    ),
  ];
}