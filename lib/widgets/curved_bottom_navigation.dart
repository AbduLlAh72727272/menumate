import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/colors.dart';

/// Custom painter for the sophisticated curved bottom navigation bar
/// Creates a unique navigation experience with a curved cutout design
class CurvedNavigationPainter extends CustomPainter {
  final double notchRadius;
  final double notchMargin;
  final Color color;
  final Color shadowColor;

  CurvedNavigationPainter({
    this.notchRadius = 30.0,
    this.notchMargin = 8.0,
    this.color = MenuMateColors.deepLagoon,
    this.shadowColor = Colors.black26,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Shadow paint for depth effect
    final shadowPaint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    final path = Path();
    final shadowPath = Path();
    
    // Calculate the center notch position
    final centerX = size.width / 2;
    final notchWidth = notchRadius * 2 + notchMargin * 2;
    final notchLeft = centerX - notchWidth / 2;
    final notchRight = centerX + notchWidth / 2;
    
    // Create the curved navigation path
    _createNavigationPath(path, size, notchLeft, notchRight);
    _createNavigationPath(shadowPath, size, notchLeft, notchRight);
    
    // Draw shadow (offset slightly)
    canvas.save();
    canvas.translate(0, 2);
    canvas.drawPath(shadowPath, shadowPaint);
    canvas.restore();
    
    // Draw the main navigation bar
    canvas.drawPath(path, paint);
    
    // Add a subtle gradient overlay for premium feel
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          MenuMateColors.deepLagoon.withOpacity(0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawPath(path, gradientPaint);
  }

  void _createNavigationPath(Path path, Size size, double notchLeft, double notchRight) {
    const radius = 20.0;
    
    // Start from bottom-left with curve
    path.moveTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    
    // Top edge to notch start
    path.lineTo(notchLeft - radius, 0);
    
    // Create the curved notch
    path.quadraticBezierTo(notchLeft, 0, notchLeft + radius, radius);
    path.quadraticBezierTo(
      notchLeft + notchRadius, 
      notchRadius + notchMargin, 
      notchLeft + notchRadius * 2, 
      notchRadius + notchMargin
    );
    path.quadraticBezierTo(
      notchRight - notchRadius, 
      notchRadius + notchMargin, 
      notchRight - radius, 
      radius
    );
    path.quadraticBezierTo(notchRight, 0, notchRight + radius, 0);
    
    // Continue to top-right with curve
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);
    
    // Right edge
    path.lineTo(size.width, size.height);
    
    // Bottom edge
    path.lineTo(0, size.height);
    
    // Close the path
    path.close();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom curved bottom navigation bar widget
class CurvedBottomNavigationBar extends StatefulWidget {
  final List<CurvedNavigationItem> items;
  final int currentIndex;
  final Function(int) onTap;
  final Widget? centerWidget;
  final double height;
  final double notchRadius;

  const CurvedBottomNavigationBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.centerWidget,
    this.height = 80.0,
    this.notchRadius = 30.0,
  });

  @override
  State<CurvedBottomNavigationBar> createState() => _CurvedBottomNavigationBarState();
}

class _CurvedBottomNavigationBarState extends State<CurvedBottomNavigationBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    _animations = _animationControllers
        .map((controller) => Tween<double>(begin: 0.0, end: 1.0)
            .animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut)))
        .toList();

    // Animate the initially selected item
    _animationControllers[widget.currentIndex].forward();
  }

  @override
  void didUpdateWidget(CurvedBottomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animationControllers[oldWidget.currentIndex].reverse();
      _animationControllers[widget.currentIndex].forward();
    }
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      child: Stack(
        children: [
          // Custom painted background
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, widget.height),
            painter: CurvedNavigationPainter(
              notchRadius: widget.notchRadius,
              color: MenuMateColors.deepLagoon,
            ),
          ),
          
          // Navigation items
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              height: widget.height,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _buildNavigationItems(),
              ),
            ),
          ),
          
          // Center widget (floating action button)
          if (widget.centerWidget != null)
            Positioned(
              top: 10,
              left: MediaQuery.of(context).size.width / 2 - widget.notchRadius,
              child: SizedBox(
                width: widget.notchRadius * 2,
                height: widget.notchRadius * 2,
                child: widget.centerWidget,
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildNavigationItems() {
    List<Widget> items = [];
    
    for (int i = 0; i < widget.items.length; i++) {
      if (i == widget.items.length ~/ 2) {
        // Add spacing for center widget
        items.add(SizedBox(width: widget.notchRadius * 2 + 20));
      }
      
      items.add(
        AnimatedBuilder(
          animation: _animations[i],
          builder: (context, child) {
            return GestureDetector(
              onTap: () {
                // Haptic feedback
                HapticFeedback.lightImpact();
                
                // Navigate to different screens
                switch (i) {
                  case 0:
                    // Home - already on home screen
                    break;
                  case 1:
                    Navigator.pushNamed(context, '/search');
                    break;
                  case 2:
                    Navigator.pushNamed(context, '/favorites');
                    break;
                  case 3:
                    Navigator.pushNamed(context, '/profile');
                    break;
                }
                
                // Call original onTap
                widget.onTap(i);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: 1.0 + (_animations[i].value * 0.2),
                      child: Icon(
                        widget.items[i].icon,
                        color: i == widget.currentIndex
                            ? MenuMateColors.citrusSpark
                            : MenuMateColors.mintFog,
                        size: 24 + (_animations[i].value * 4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: i == widget.currentIndex
                            ? MenuMateColors.citrusSpark
                            : MenuMateColors.mintFog,
                        fontSize: 10 + (_animations[i].value * 2),
                        fontWeight: i == widget.currentIndex
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      child: Text(widget.items[i].label),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
    
    return items;
  }
}

/// Navigation item model
class CurvedNavigationItem {
  final IconData icon;
  final String label;

  const CurvedNavigationItem({
    required this.icon,
    required this.label,
  });
}