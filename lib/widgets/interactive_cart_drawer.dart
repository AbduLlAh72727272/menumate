import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/colors.dart';
import 'floating_food_card.dart';

/// Interactive cart drawer with animated price updates and smooth transitions
/// Provides a premium shopping experience with real-time price animations
class InteractiveCartDrawer extends StatefulWidget {
  final List<CartItem> items;
  final Function(CartItem) onItemAdded;
  final Function(CartItem) onItemRemoved;
  final Function(CartItem) onQuantityChanged;
  final VoidCallback onCheckout;
  final VoidCallback onClose;

  const InteractiveCartDrawer({
    super.key,
    required this.items,
    required this.onItemAdded,
    required this.onItemRemoved,
    required this.onQuantityChanged,
    required this.onCheckout,
    required this.onClose,
  });

  @override
  State<InteractiveCartDrawer> createState() => _InteractiveCartDrawerState();
}

class _InteractiveCartDrawerState extends State<InteractiveCartDrawer>
    with TickerProviderStateMixin {
  late AnimationController _drawerController;
  late AnimationController _priceController;
  late AnimationController _pulseController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _priceScaleAnimation;
  late Animation<Color?> _priceColorAnimation;
  
  double _previousTotal = 0.0;
  double _currentTotal = 0.0;

  @override
  void initState() {
    super.initState();
    
    _drawerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _priceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _drawerController,
      curve: Curves.easeInOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _drawerController,
      curve: Curves.easeInOut,
    ));
    
    _priceScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _priceController,
      curve: Curves.elasticOut,
    ));
    
    _priceColorAnimation = ColorTween(
      begin: MenuMateColors.charcoalBlack,
      end: MenuMateColors.citrusSpark,
    ).animate(CurvedAnimation(
      parent: _priceController,
      curve: Curves.easeInOut,
    ));
    
    _currentTotal = _calculateTotal();
    _drawerController.forward();
  }

  @override
  void didUpdateWidget(InteractiveCartDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    final newTotal = _calculateTotal();
    if (newTotal != _currentTotal) {
      _previousTotal = _currentTotal;
      _currentTotal = newTotal;
      _animatePriceChange();
    }
  }

  void _animatePriceChange() {
    _priceController.forward().then((_) {
      _priceController.reverse();
    });
    
    // Pulse effect for significant changes
    if ((_currentTotal - _previousTotal).abs() > 10.0) {
      _pulseController.forward().then((_) {
        _pulseController.reverse();
      });
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  double _calculateTotal() {
    return widget.items.fold(
      0.0,
      (sum, item) => sum + (item.foodItem.price * item.quantity),
    );
  }

  @override
  void dispose() {
    _drawerController.dispose();
    _priceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      child: AnimatedBuilder(
        animation: _drawerController,
        builder: (context, child) {
          return Container(
            color: Colors.black.withOpacity(0.3 * _fadeAnimation.value),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Transform.translate(
                offset: Offset(
                  0,
                  MediaQuery.of(context).size.height * 0.4 * _slideAnimation.value,
                ),
                child: _buildDrawerContent(context),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawerContent(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // Prevent dismiss when tapping on drawer
      child: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
          color: MenuMateColors.cloudWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, -4),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
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
            
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text(
                    'Your Order',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: MenuMateColors.charcoalBlack,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: MenuMateColors.mintFog,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.items.length} items',
                      style: const TextStyle(
                        color: MenuMateColors.charcoalBlack,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Cart items
            Expanded(
              child: widget.items.isEmpty
                  ? _buildEmptyCart()
                  : _buildCartList(),
            ),
            
            // Total and checkout
            if (widget.items.isNotEmpty) _buildCheckoutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: MenuMateColors.mediumGray.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              color: MenuMateColors.mediumGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some delicious items to get started',
            style: TextStyle(
              fontSize: 14,
              color: MenuMateColors.lightGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        return _buildCartItem(item, index);
      },
    );
  }

  Widget _buildCartItem(CartItem item, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: MenuMateColors.pureWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Item image placeholder
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: MenuMateColors.mintFog.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.restaurant,
                      color: MenuMateColors.deepLagoon.withOpacity(0.5),
                      size: 30,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Item details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.foodItem.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: MenuMateColors.charcoalBlack,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${item.foodItem.price.toStringAsFixed(2)} each',
                          style: TextStyle(
                            fontSize: 14,
                            color: MenuMateColors.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Quantity controls
                  _buildQuantityControls(item),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuantityControls(CartItem item) {
    return Container(
      decoration: BoxDecoration(
        color: MenuMateColors.mintFog.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Decrease button
          GestureDetector(
            onTap: () {
              if (item.quantity > 1) {
                final updatedItem = CartItem(
                  foodItem: item.foodItem,
                  quantity: item.quantity - 1,
                );
                widget.onQuantityChanged(updatedItem);
              } else {
                widget.onItemRemoved(item);
              }
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: MenuMateColors.citrusSpark,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.remove,
                color: MenuMateColors.charcoalBlack,
                size: 18,
              ),
            ),
          ),
          
          // Quantity display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Text(
                '${item.quantity}',
                key: ValueKey(item.quantity),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: MenuMateColors.charcoalBlack,
                ),
              ),
            ),
          ),
          
          // Increase button
          GestureDetector(
            onTap: () {
              final updatedItem = CartItem(
                foodItem: item.foodItem,
                quantity: item.quantity + 1,
              );
              widget.onQuantityChanged(updatedItem);
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: MenuMateColors.citrusSpark,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: MenuMateColors.charcoalBlack,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: MenuMateColors.pureWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          // Total with animation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: MenuMateColors.charcoalBlack,
                ),
              ),
              AnimatedBuilder(
                animation: Listenable.merge([_priceController, _pulseController]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _priceScaleAnimation.value,
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween(begin: _previousTotal, end: _currentTotal),
                      builder: (context, value, child) {
                        return Text(
                          '\$${value.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _priceColorAnimation.value,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Checkout button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: widget.onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: MenuMateColors.citrusSpark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: MenuMateColors.citrusSpark.withOpacity(0.4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_bag,
                    color: MenuMateColors.charcoalBlack,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Checkout',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: MenuMateColors.charcoalBlack,
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

/// Cart item model
class CartItem {
  final FoodItem foodItem;
  final int quantity;

  const CartItem({
    required this.foodItem,
    required this.quantity,
  });

  CartItem copyWith({
    FoodItem? foodItem,
    int? quantity,
  }) {
    return CartItem(
      foodItem: foodItem ?? this.foodItem,
      quantity: quantity ?? this.quantity,
    );
  }
}