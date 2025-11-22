import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/colors.dart';
import '../widgets/menumate_app_bar.dart';

/// User profile screen with settings and account management
/// Features elegant design with animated preferences and order history
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late List<Animation<Offset>> _slideAnimations;
  late Animation<double> _fadeAnimation;

  // User data
  final String _userName = 'Sarah Johnson';
  final String _userEmail = 'sarah.johnson@email.com';
  final String _userPhone = '+1 (555) 123-4567';
  final String _profileImage = 'profile.jpg';
  
  // Settings
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = false;
  
  final List<OrderHistoryItem> _orderHistory = [
    OrderHistoryItem(
      orderId: '#ORD-001',
      restaurant: 'Italiano Bistro',
      items: ['Truffle Pizza', 'Caesar Salad'],
      total: 45.99,
      date: DateTime.now().subtract(const Duration(days: 2)),
      status: OrderStatus.delivered,
    ),
    OrderHistoryItem(
      orderId: '#ORD-002',
      restaurant: 'Sushi Master',
      items: ['Dragon Roll', 'Miso Soup', 'Green Tea'],
      total: 38.50,
      date: DateTime.now().subtract(const Duration(days: 5)),
      status: OrderStatus.delivered,
    ),
    OrderHistoryItem(
      orderId: '#ORD-003',
      restaurant: 'Gourmet House',
      items: ['Wagyu Burger', 'Sweet Potato Fries'],
      total: 32.75,
      date: DateTime.now().subtract(const Duration(days: 8)),
      status: OrderStatus.delivered,
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Create staggered slide animations
    _slideAnimations = List.generate(6, (index) {
      return Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Interval(
          index * 0.1,
          0.6 + (index * 0.1),
          curve: Curves.easeOutBack,
        ),
      ));
    });

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Start animations
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MenuMateColors.cloudWhite,
      appBar: const MenuMateProfileAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 30),
              _buildQuickStats(),
              const SizedBox(height: 30),
              _buildSettingsSection(),
              const SizedBox(height: 30),
              _buildOrderHistory(),
              const SizedBox(height: 30),
              _buildAccountActions(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return SlideTransition(
      position: _slideAnimations[0],
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              MenuMateColors.deepLagoon,
              MenuMateColors.mintFog,
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: MenuMateColors.deepLagoon.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Profile image
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    MenuMateColors.citrusSpark,
                    MenuMateColors.citrusSpark.withOpacity(0.7),
                  ],
                ),
                border: Border.all(
                  color: MenuMateColors.pureWhite,
                  width: 4,
                ),
              ),
              child: const Icon(
                Icons.person,
                size: 50,
                color: MenuMateColors.pureWhite,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Name
            Text(
              _userName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: MenuMateColors.pureWhite,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Email
            Text(
              _userEmail,
              style: TextStyle(
                fontSize: 16,
                color: MenuMateColors.pureWhite.withOpacity(0.8),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Edit profile button
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                _showEditProfileDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MenuMateColors.pureWhite,
                foregroundColor: MenuMateColors.deepLagoon,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return SlideTransition(
      position: _slideAnimations[1],
      child: Row(
        children: [
          _buildStatCard('Orders', '${_orderHistory.length}', Icons.shopping_bag),
          const SizedBox(width: 16),
          _buildStatCard('Favorites', '12', Icons.favorite),
          const SizedBox(width: 16),
          _buildStatCard('Points', '1,250', Icons.star),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
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
            Icon(
              icon,
              size: 32,
              color: MenuMateColors.citrusSpark,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: MenuMateColors.deepLagoon,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: MenuMateColors.deepLagoon.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return SlideTransition(
      position: _slideAnimations[2],
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: MenuMateColors.deepLagoon,
                ),
              ),
            ),
            _buildSettingItem(
              'Notifications',
              'Receive order updates and offers',
              Icons.notifications_outlined,
              Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  HapticFeedback.lightImpact();
                },
                activeColor: MenuMateColors.citrusSpark,
              ),
            ),
            _buildSettingItem(
              'Location Services',
              'Find restaurants near you',
              Icons.location_on_outlined,
              Switch(
                value: _locationEnabled,
                onChanged: (value) {
                  setState(() {
                    _locationEnabled = value;
                  });
                  HapticFeedback.lightImpact();
                },
                activeColor: MenuMateColors.citrusSpark,
              ),
            ),
            _buildSettingItem(
              'Dark Mode',
              'Use dark theme',
              Icons.dark_mode_outlined,
              Switch(
                value: _darkModeEnabled,
                onChanged: (value) {
                  setState(() {
                    _darkModeEnabled = value;
                  });
                  HapticFeedback.lightImpact();
                },
                activeColor: MenuMateColors.citrusSpark,
              ),
            ),
            _buildSettingItem(
              'Biometric Authentication',
              'Use fingerprint or face ID',
              Icons.fingerprint,
              Switch(
                value: _biometricEnabled,
                onChanged: (value) {
                  setState(() {
                    _biometricEnabled = value;
                  });
                  HapticFeedback.lightImpact();
                },
                activeColor: MenuMateColors.citrusSpark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(String title, String subtitle, IconData icon, Widget trailing) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: MenuMateColors.deepLagoon.withOpacity(0.7),
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
                        fontWeight: FontWeight.w500,
                        color: MenuMateColors.deepLagoon,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: MenuMateColors.deepLagoon.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHistory() {
    return SlideTransition(
      position: _slideAnimations[3],
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Orders',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: MenuMateColors.deepLagoon,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // Show all orders
                    },
                    child: Text(
                      'View All',
                      style: TextStyle(
                        color: MenuMateColors.citrusSpark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _orderHistory.length,
              itemBuilder: (context, index) {
                return _buildOrderItem(_orderHistory[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(OrderHistoryItem order) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          // Show order details
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: MenuMateColors.mintFog.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.restaurant,
                  color: MenuMateColors.deepLagoon,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.restaurant,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: MenuMateColors.deepLagoon,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.items.join(', '),
                      style: TextStyle(
                        fontSize: 12,
                        color: MenuMateColors.deepLagoon.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.orderId,
                      style: TextStyle(
                        fontSize: 11,
                        color: MenuMateColors.deepLagoon.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: MenuMateColors.citrusSpark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: MenuMateColors.mintFog.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Delivered',
                      style: TextStyle(
                        fontSize: 10,
                        color: MenuMateColors.deepLagoon,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountActions() {
    return SlideTransition(
      position: _slideAnimations[4],
      child: Container(
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
            _buildActionItem('Payment Methods', Icons.payment, () {
              HapticFeedback.lightImpact();
            }),
            _buildActionItem('Addresses', Icons.location_on, () {
              HapticFeedback.lightImpact();
            }),
            _buildActionItem('Help & Support', Icons.help_outline, () {
              HapticFeedback.lightImpact();
            }),
            _buildActionItem('Privacy Policy', Icons.privacy_tip_outlined, () {
              HapticFeedback.lightImpact();
            }),
            _buildActionItem(
              'Sign Out', 
              Icons.logout, 
              () {
                HapticFeedback.mediumImpact();
                _showSignOutDialog();
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive 
                    ? Colors.red.withOpacity(0.7)
                    : MenuMateColors.deepLagoon.withOpacity(0.7),
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDestructive 
                        ? Colors.red
                        : MenuMateColors.deepLagoon,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: MenuMateColors.deepLagoon.withOpacity(0.3),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Profile'),
        content: Text('Profile editing functionality would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Out'),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement sign out
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

/// Order history item data model
class OrderHistoryItem {
  final String orderId;
  final String restaurant;
  final List<String> items;
  final double total;
  final DateTime date;
  final OrderStatus status;

  const OrderHistoryItem({
    required this.orderId,
    required this.restaurant,
    required this.items,
    required this.total,
    required this.date,
    required this.status,
  });
}

enum OrderStatus { pending, preparing, delivered, cancelled }