import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/colors.dart';
import 'home_screen.dart';

/// Elegant onboarding screens introducing app features
/// Features smooth page transitions and interactive elements
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  late List<AnimationController> _slideControllers;
  
  int _currentPage = 0;
  final int _totalPages = 3;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: "Discover Amazing\nFood",
      subtitle: "Explore restaurants and cuisines\nwith our sophisticated filters",
      icon: Icons.search,
      backgroundColor: MenuMateColors.deepLagoon,
      accentColor: MenuMateColors.citrusSpark,
    ),
    OnboardingData(
      title: "3D Menu\nExperience", 
      subtitle: "Navigate through food categories\nwith our parallax carousel",
      icon: Icons.view_carousel,
      backgroundColor: MenuMateColors.citrusSpark,
      accentColor: MenuMateColors.mintFog,
    ),
    OnboardingData(
      title: "Premium\nOrdering",
      subtitle: "Enjoy smooth animations and\nreal-time cart updates",
      icon: Icons.shopping_cart,
      backgroundColor: MenuMateColors.mintFog,
      accentColor: MenuMateColors.deepLagoon,
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _pageController = PageController();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideControllers = List.generate(
      _totalPages,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      ),
    );

    // Start first slide animation
    _slideControllers[0].forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    for (var controller in _slideControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    
    // Animate progress
    _progressController.animateTo((page + 1) / _totalPages);
    
    // Animate slide content
    for (int i = 0; i < _slideControllers.length; i++) {
      if (i == page) {
        _slideControllers[i].forward();
      } else {
        _slideControllers[i].reset();
      }
    }
    
    HapticFeedback.lightImpact();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _navigateToHome();
    }
  }

  void _skipToEnd() {
    _navigateToHome();
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MenuMateHomeScreen(),
        transitionDuration: const Duration(milliseconds: 1000),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            )),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page view with onboarding slides
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _totalPages,
            itemBuilder: (context, index) {
              return _buildOnboardingSlide(index);
            },
          ),
          
          // Custom navigation overlay
          _buildNavigationOverlay(),
        ],
      ),
    );
  }

  Widget _buildOnboardingSlide(int index) {
    final data = _onboardingData[index];
    final slideController = _slideControllers[index];
    
    return AnimatedBuilder(
      animation: slideController,
      builder: (context, child) {
        final slideAnimation = CurvedAnimation(
          parent: slideController,
          curve: Curves.easeOutBack,
        );
        
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: slideController,
          curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
        ));
        
        final scaleAnimation = Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(slideAnimation);
        
        final translateAnimation = Tween<double>(
          begin: 100.0,
          end: 0.0,
        ).animate(slideAnimation);

        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 1.5,
              colors: [
                data.backgroundColor,
                data.backgroundColor.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  
                  // Animated icon
                  Transform.scale(
                    scale: scaleAnimation.value,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: MenuMateColors.pureWhite.withOpacity(0.2),
                        border: Border.all(
                          color: MenuMateColors.pureWhite.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        data.icon,
                        size: 70,
                        color: MenuMateColors.pureWhite,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Animated title
                  Transform.translate(
                    offset: Offset(0, translateAnimation.value),
                    child: Opacity(
                      opacity: fadeAnimation.value,
                      child: Text(
                        data.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: MenuMateColors.pureWhite,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Animated subtitle
                  Transform.translate(
                    offset: Offset(0, translateAnimation.value * 0.5),
                    child: Opacity(
                      opacity: fadeAnimation.value,
                      child: Text(
                        data.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          color: MenuMateColors.pureWhite.withOpacity(0.9),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigationOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress indicator
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return Container(
                    height: 6,
                    margin: const EdgeInsets.only(bottom: 40),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: MenuMateColors.pureWhite.withOpacity(0.3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progressController.value,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: MenuMateColors.pureWhite,
                          boxShadow: [
                            BoxShadow(
                              color: MenuMateColors.pureWhite.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              // Navigation buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip button
                  TextButton(
                    onPressed: _skipToEnd,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: MenuMateColors.pureWhite.withOpacity(0.7),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  // Next/Get Started button
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MenuMateColors.pureWhite,
                      foregroundColor: _onboardingData[_currentPage].backgroundColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentPage == _totalPages - 1 ? 'Get Started' : 'Next',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _currentPage == _totalPages - 1 
                              ? Icons.arrow_forward 
                              : Icons.arrow_forward_ios,
                          size: 16,
                        ),
                      ],
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
}

/// Onboarding data model
class OnboardingData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Color accentColor;

  const OnboardingData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.accentColor,
  });
}