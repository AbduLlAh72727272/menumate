import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/colors.dart';

/// Sophisticated custom app bar with glassmorphism and floating design
/// Features animated elements, search integration, and unique visual effects
class MenuMateAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showSearch;
  final VoidCallback? onSearchTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final int notificationCount;
  final bool isFloating;

  const MenuMateAppBar({
    super.key,
    required this.title,
    this.showSearch = true,
    this.onSearchTap,
    this.onProfileTap,
    this.onNotificationTap,
    this.notificationCount = 0,
    this.isFloating = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  State<MenuMateAppBar> createState() => _MenuMateAppBarState();
}

class _MenuMateAppBarState extends State<MenuMateAppBar>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _floatController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation for notification badge
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.elasticOut),
    );
    
    // Glow animation for search button
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    // Float animation for entire app bar
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _floatAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Start animations
    if (widget.notificationCount > 0) {
      _pulseController.repeat(reverse: true);
    }
    _glowController.repeat(reverse: true);
    _floatController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MenuMateAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update pulse animation based on notification count
    if (widget.notificationCount > 0 && oldWidget.notificationCount == 0) {
      _pulseController.repeat(reverse: true);
    } else if (widget.notificationCount == 0 && oldWidget.notificationCount > 0) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Container(
          margin: widget.isFloating 
              ? EdgeInsets.only(
                  top: 50 + _floatAnimation.value,
                  left: 16,
                  right: 16,
                )
              : EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: widget.isFloating 
                ? BorderRadius.circular(25)
                : BorderRadius.zero,
            child: Container(
              height: widget.preferredSize.height,
              decoration: BoxDecoration(
                // Glassmorphism effect
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    MenuMateColors.deepLagoon.withOpacity(0.9),
                    MenuMateColors.deepLagoon.withOpacity(0.7),
                    MenuMateColors.mintFog.withOpacity(0.3),
                  ],
                ),
                borderRadius: widget.isFloating 
                    ? BorderRadius.circular(25)
                    : BorderRadius.zero,
                border: widget.isFloating
                    ? Border.all(
                        color: MenuMateColors.pureWhite.withOpacity(0.2),
                        width: 1,
                      )
                    : null,
                boxShadow: widget.isFloating
                    ? [
                        BoxShadow(
                          color: MenuMateColors.deepLagoon.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: MenuMateColors.citrusSpark.withOpacity(0.1),
                          blurRadius: 40,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : null,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // App title with animated gradient
                      Expanded(
                        child: _buildAnimatedTitle(),
                      ),
                      
                      // Search button with glow effect
                      if (widget.showSearch) ...[
                        _buildGlowSearchButton(),
                        const SizedBox(width: 16),
                      ],
                      
                      // Notification button with pulse effect
                      _buildNotificationButton(),
                      const SizedBox(width: 16),
                      
                      // Profile button with hover effect
                      _buildProfileButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTitle() {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [
            MenuMateColors.citrusSpark,
            MenuMateColors.pureWhite,
            MenuMateColors.mintFog,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(bounds);
      },
      child: Text(
        widget.title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildGlowSearchButton() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: MenuMateColors.citrusSpark.withOpacity(
                  0.3 * _glowAnimation.value,
                ),
                blurRadius: 20 * _glowAnimation.value,
                spreadRadius: 2 * _glowAnimation.value,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: () {
                HapticFeedback.mediumImpact();
                widget.onSearchTap?.call();
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: MenuMateColors.pureWhite.withOpacity(0.2),
                  border: Border.all(
                    color: MenuMateColors.citrusSpark.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.search,
                  color: MenuMateColors.citrusSpark,
                  size: 24,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.notificationCount > 0 ? _pulseAnimation.value : 1.0,
          child: Stack(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onNotificationTap?.call();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: MenuMateColors.pureWhite.withOpacity(0.15),
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: MenuMateColors.pureWhite.withOpacity(0.9),
                      size: 24,
                    ),
                  ),
                ),
              ),
              
              // Notification badge
              if (widget.notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: MenuMateColors.citrusSpark,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: MenuMateColors.pureWhite,
                        width: 2,
                      ),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      widget.notificationCount > 99 
                          ? '99+' 
                          : widget.notificationCount.toString(),
                      style: const TextStyle(
                        color: MenuMateColors.pureWhite,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onProfileTap?.call();
        },
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                MenuMateColors.citrusSpark,
                MenuMateColors.citrusSpark.withOpacity(0.7),
              ],
            ),
            border: Border.all(
              color: MenuMateColors.pureWhite.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: MenuMateColors.mintFog,
            child: Icon(
              Icons.person_outline,
              color: MenuMateColors.deepLagoon,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom app bar for specific screens with preset configurations
class MenuMateSearchAppBar extends MenuMateAppBar {
  const MenuMateSearchAppBar({
    super.key,
    super.onProfileTap,
    super.onNotificationTap,
    super.notificationCount = 0,
  }) : super(
          title: 'Search',
          showSearch: false,
          isFloating: true,
        );
}

class MenuMateFavoritesAppBar extends MenuMateAppBar {
  const MenuMateFavoritesAppBar({
    super.key,
    super.onSearchTap,
    super.onProfileTap,
    super.onNotificationTap,
    super.notificationCount = 0,
  }) : super(
          title: 'Favorites',
          isFloating: false,
        );
}

class MenuMateProfileAppBar extends MenuMateAppBar {
  const MenuMateProfileAppBar({
    super.key,
    super.onSearchTap,
    super.onNotificationTap,
    super.notificationCount = 0,
  }) : super(
          title: 'Profile',
          showSearch: false,
        );
}