import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/colors.dart';
import 'onboarding_screen.dart';

/// Sophisticated animated splash screen with MenuMate branding
/// Features particle animations, gradient backgrounds, and smooth transitions
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _particleController;
  late AnimationController _textController;
  late AnimationController _backgroundController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotateAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _particleAnimation;
  late Animation<Color?> _backgroundGradientAnimation;

  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _setupAnimations();
    _startSplashSequence();
  }

  void _setupAnimations() {
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoRotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _textSlideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    ));

    _backgroundGradientAnimation = ColorTween(
      begin: MenuMateColors.deepLagoon,
      end: MenuMateColors.citrusSpark,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));
  }

  void _startSplashSequence() async {
    // Start background animation
    _backgroundController.forward();
    
    // Start logo animation
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    
    // Start particle animation
    await Future.delayed(const Duration(milliseconds: 500));
    _particleController.repeat();
    
    // Start text animation
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();
    
    // Navigate to onboarding after splash sequence
    await Future.delayed(const Duration(milliseconds: 3000));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const OnboardingScreen(),
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                ),
                child: child,
              ),
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _particleController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _logoController,
          _particleController,
          _textController,
          _backgroundController,
        ]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  _backgroundGradientAnimation.value ?? MenuMateColors.deepLagoon,
                  MenuMateColors.deepLagoonDark,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Animated particles background
                ...List.generate(20, (index) => _buildParticle(index)),
                
                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated logo
                      Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: Transform.rotate(
                          angle: _logoRotateAnimation.value * 0.1,
                          child: Opacity(
                            opacity: _logoOpacityAnimation.value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    MenuMateColors.citrusSpark,
                                    MenuMateColors.citrusSparkLight,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: MenuMateColors.citrusSpark.withOpacity(0.5),
                                    offset: const Offset(0, 8),
                                    blurRadius: 24,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.restaurant_menu,
                                size: 60,
                                color: MenuMateColors.charcoalBlack,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Animated app name
                      Transform.translate(
                        offset: Offset(0, _textSlideAnimation.value),
                        child: Opacity(
                          opacity: _textOpacityAnimation.value,
                          child: const Column(
                            children: [
                              Text(
                                'MenuMate',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: MenuMateColors.pureWhite,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 4),
                                      blurRadius: 8,
                                      color: Colors.black26,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Next-Level Food Experience',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                  color: MenuMateColors.mintFog,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // Loading indicator
                      Opacity(
                        opacity: _textOpacityAnimation.value,
                        child: SizedBox(
                          width: 200,
                          child: LinearProgressIndicator(
                            backgroundColor: MenuMateColors.pureWhite.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              MenuMateColors.citrusSpark,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildParticle(int index) {
    final random = (index * 0.1);
    final delay = (index * 0.05) % 1.0;
    final animationValue = (_particleAnimation.value + delay) % 1.0;
    
    return Positioned(
      left: (50 + (index * 17)) % MediaQuery.of(context).size.width,
      top: MediaQuery.of(context).size.height * animationValue,
      child: Opacity(
        opacity: (1.0 - animationValue) * 0.6,
        child: Container(
          width: 4 + (random * 6),
          height: 4 + (random * 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index % 2 == 0 
                ? MenuMateColors.citrusSpark 
                : MenuMateColors.mintFog,
            boxShadow: [
              BoxShadow(
                color: (index % 2 == 0 
                    ? MenuMateColors.citrusSpark 
                    : MenuMateColors.mintFog).withOpacity(0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}