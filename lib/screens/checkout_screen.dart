import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/colors.dart';

/// Sophisticated checkout screen with payment flow and animations
/// Features order summary, payment methods, and confirmation animations
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _paymentController;
  late AnimationController _successController;
  late PageController _pageController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _paymentAnimation;
  late Animation<double> _successAnimation;

  int _currentStep = 0;
  String _selectedPaymentMethod = 'credit_card';
  String _selectedAddress = 'home';
  bool _isProcessingPayment = false;
  bool _paymentSuccess = false;

  final List<CheckoutItem> _cartItems = [
    CheckoutItem(
      name: 'Truffle Pizza',
      restaurant: 'Italiano Bistro',
      price: 26.99,
      quantity: 1,
      image: 'truffle_pizza.jpg',
    ),
    CheckoutItem(
      name: 'Caesar Salad',
      restaurant: 'Italiano Bistro',
      price: 12.99,
      quantity: 2,
      image: 'caesar_salad.jpg',
    ),
    CheckoutItem(
      name: 'Chocolate Soufflé',
      restaurant: 'Sweet Dreams',
      price: 14.99,
      quantity: 1,
      image: 'chocolate_souffle.jpg',
    ),
  ];

  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: 'credit_card',
      name: 'Credit Card',
      icon: Icons.credit_card,
      details: '**** **** **** 4242',
    ),
    PaymentMethod(
      id: 'paypal',
      name: 'PayPal',
      icon: Icons.account_balance_wallet,
      details: 'sarah.johnson@email.com',
    ),
    PaymentMethod(
      id: 'apple_pay',
      name: 'Apple Pay',
      icon: Icons.phone_iphone,
      details: 'Touch ID',
    ),
  ];

  double get _subtotal => _cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  double get _deliveryFee => 3.99;
  double get _tax => _subtotal * 0.08;
  double get _total => _subtotal + _deliveryFee + _tax;

  @override
  void initState() {
    super.initState();
    
    _pageController = PageController();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _paymentController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _successController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _paymentAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _paymentController,
      curve: Curves.easeInOut,
    ));

    _successAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.easeOutBack,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _paymentController.dispose();
    _successController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      HapticFeedback.lightImpact();
    } else {
      _processPayment();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      HapticFeedback.lightImpact();
    }
  }

  void _processPayment() async {
    setState(() {
      _isProcessingPayment = true;
    });

    _paymentController.forward();
    HapticFeedback.mediumImpact();

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isProcessingPayment = false;
      _paymentSuccess = true;
    });

    _successController.forward();
    HapticFeedback.heavyImpact();

    // Navigate back after success
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_paymentSuccess) {
      return _buildSuccessScreen();
    }

    return Scaffold(
      backgroundColor: MenuMateColors.cloudWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: MenuMateColors.deepLagoon,
          ),
        ),
        title: Text(
          'Checkout',
          style: TextStyle(
            color: MenuMateColors.deepLagoon,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildOrderSummary(),
                _buildDeliveryAddress(),
                _buildPaymentMethod(),
              ],
            ),
          ),
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: MenuMateColors.deepLagoon,
      body: AnimatedBuilder(
        animation: _successAnimation,
        builder: (context, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: _successAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: MenuMateColors.citrusSpark,
                      boxShadow: [
                        BoxShadow(
                          color: MenuMateColors.citrusSpark.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 60,
                      color: MenuMateColors.pureWhite,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                Opacity(
                  opacity: _successAnimation.value,
                  child: const Text(
                    'Order Confirmed!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: MenuMateColors.pureWhite,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Opacity(
                  opacity: _successAnimation.value,
                  child: Text(
                    'Your order is being prepared\nEstimated delivery: 25-35 min',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: MenuMateColors.pureWhite.withOpacity(0.8),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: isActive 
                          ? MenuMateColors.citrusSpark
                          : MenuMateColors.deepLagoon.withOpacity(0.2),
                    ),
                  ),
                ),
                if (index < 2) const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return SlideTransition(
      position: _slideAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: MenuMateColors.deepLagoon,
              ),
            ),
            
            const SizedBox(height: 20),
            
            Container(
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
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _cartItems.length,
                itemBuilder: (context, index) {
                  return _buildOrderItem(_cartItems[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(CheckoutItem item) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  MenuMateColors.mintFog,
                  MenuMateColors.citrusSpark.withOpacity(0.3),
                ],
              ),
            ),
            child: Icon(
              Icons.restaurant_menu,
              color: MenuMateColors.deepLagoon,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: MenuMateColors.deepLagoon,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.restaurant,
                  style: TextStyle(
                    fontSize: 12,
                    color: MenuMateColors.deepLagoon.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: MenuMateColors.citrusSpark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Qty: ${item.quantity}',
                style: TextStyle(
                  fontSize: 12,
                  color: MenuMateColors.deepLagoon.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Address',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: MenuMateColors.deepLagoon,
            ),
          ),
          
          const SizedBox(height: 20),
          
          _buildAddressOption(
            'home',
            'Home',
            '123 Main Street, Apt 4B\nNew York, NY 10001',
            Icons.home,
          ),
          
          const SizedBox(height: 16),
          
          _buildAddressOption(
            'work',
            'Work',
            '456 Business Ave, Suite 200\nNew York, NY 10002',
            Icons.business,
          ),
          
          const SizedBox(height: 16),
          
          _buildAddNewAddress(),
        ],
      ),
    );
  }

  Widget _buildAddressOption(String id, String title, String address, IconData icon) {
    final isSelected = _selectedAddress == id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAddress = id;
        });
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: MenuMateColors.pureWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? MenuMateColors.citrusSpark
                : MenuMateColors.deepLagoon.withOpacity(0.1),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: MenuMateColors.citrusSpark.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [
                  BoxShadow(
                    color: MenuMateColors.deepLagoon.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? MenuMateColors.citrusSpark
                  : MenuMateColors.deepLagoon.withOpacity(0.6),
              size: 24,
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? MenuMateColors.citrusSpark
                          : MenuMateColors.deepLagoon,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address,
                    style: TextStyle(
                      fontSize: 12,
                      color: MenuMateColors.deepLagoon.withOpacity(0.6),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: MenuMateColors.citrusSpark,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNewAddress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MenuMateColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MenuMateColors.deepLagoon.withOpacity(0.1),
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.add_location_outlined,
            color: MenuMateColors.citrusSpark,
            size: 24,
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Text(
              'Add New Address',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: MenuMateColors.citrusSpark,
              ),
            ),
          ),
          
          Icon(
            Icons.arrow_forward_ios,
            color: MenuMateColors.citrusSpark,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: MenuMateColors.deepLagoon,
            ),
          ),
          
          const SizedBox(height: 20),
          
          ..._paymentMethods.map((method) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildPaymentOption(method),
          )),
          
          _buildOrderSummaryCard(),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(PaymentMethod method) {
    final isSelected = _selectedPaymentMethod == method.id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method.id;
        });
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: MenuMateColors.pureWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? MenuMateColors.citrusSpark
                : MenuMateColors.deepLagoon.withOpacity(0.1),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: MenuMateColors.citrusSpark.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              method.icon,
              color: isSelected 
                  ? MenuMateColors.citrusSpark
                  : MenuMateColors.deepLagoon.withOpacity(0.6),
              size: 24,
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? MenuMateColors.citrusSpark
                          : MenuMateColors.deepLagoon,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    method.details,
                    style: TextStyle(
                      fontSize: 12,
                      color: MenuMateColors.deepLagoon.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: MenuMateColors.citrusSpark,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', _subtotal),
          _buildSummaryRow('Delivery Fee', _deliveryFee),
          _buildSummaryRow('Tax', _tax),
          const Divider(height: 24),
          _buildSummaryRow('Total', _total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: MenuMateColors.deepLagoon,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? MenuMateColors.citrusSpark : MenuMateColors.deepLagoon,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MenuMateColors.pureWhite,
        boxShadow: [
          BoxShadow(
            color: MenuMateColors.deepLagoon.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide(color: MenuMateColors.deepLagoon),
                  ),
                  child: Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: MenuMateColors.deepLagoon,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
            
            Expanded(
              flex: _currentStep > 0 ? 2 : 1,
              child: AnimatedBuilder(
                animation: _paymentAnimation,
                builder: (context, child) {
                  if (_isProcessingPayment) {
                    return Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            MenuMateColors.deepLagoon,
                            MenuMateColors.mintFog,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(MenuMateColors.pureWhite),
                                strokeWidth: 2,
                                value: _paymentAnimation.value,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Processing...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: MenuMateColors.pureWhite,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MenuMateColors.deepLagoon,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _currentStep == 2 
                          ? 'Place Order • \$${_total.toStringAsFixed(2)}'
                          : 'Continue',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: MenuMateColors.pureWhite,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Checkout item data model
class CheckoutItem {
  final String name;
  final String restaurant;
  final double price;
  final int quantity;
  final String image;

  const CheckoutItem({
    required this.name,
    required this.restaurant,
    required this.price,
    required this.quantity,
    required this.image,
  });
}

/// Payment method data model
class PaymentMethod {
  final String id;
  final String name;
  final IconData icon;
  final String details;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.details,
  });
}