# 🎨 MenuMate – Next‑Level Flutter Food App

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web-009688)](#)
[![Deploy](https://img.shields.io/badge/Live_Demo-GitHub_Pages-FF9F1C)](#live-demo)
[![Stars](https://img.shields.io/github/stars/OWNER/REPO?style=social)](#)

MenuMate showcases sophisticated Flutter UI design with the **"Deep Lagoon & Citrus Spark"** color scheme, featuring advanced animations, custom painters, and premium interactions that set it apart from typical food delivery apps.

> Want to try it now? Jump to Live Demo and Place Order links below.

## 🌟 Key Features & Unique Design Elements

### 🎯 Color Scheme: "Deep Lagoon & Citrus Spark"
- **Primary (Trust & Depth)**: `#006D77` - Deep Lagoon for headers and premium feel
- **Accent (Energy & Action)**: `#FF9F1C` - Citrus Spark for CTAs and price tags
- **Secondary (Freshness & Health)**: `#83C5BE` - Mint Fog for health labels
- **Background**: `#F4F4F9` - Cloud White for clean, spacious layout
- **Text**: `#1C2525` - Charcoal Black for high contrast readability

### 🚀 Next-Level UI Components

#### 1. **Curved Navigator** (`CurvedBottomNavigationBar`)
- Custom `CustomPainter` creates unique curved cutout design
- Smooth animations with `AnimationController` for each navigation item
- Elastic scale effects on selection
- Premium shadow effects and gradient overlays

#### 2. **3D Parallax Menu Carousel** (`ParallaxMenuCarousel`)
- Horizontal scrolling with `Matrix4` transforms for depth
- **Parallax Effect**: Background elements shift opposite to scroll direction
- 3D rotation and perspective effects using `Matrix4.identity()`
- Staggered animations with elastic curves

#### 3. **Floating Food Cards** (`FloatingFoodCard`)
- **Asymmetrical Design**: Custom `ClipPath` for unique card shapes
- **Interactive Ingredient Labels**: Appear on press with slide animations
- **TweenAnimationBuilder**: Smooth price updates with color transitions
- **Hero Animations**: Seamless transitions between screens

#### 4. **Interactive Cart Drawer** (`InteractiveCartDrawer`)
- **Persistent Bottom Sheet**: No new screen navigation
- **Real-Time Price Animation**: Count-up effect with color pulse
- **Haptic Feedback**: Premium feel with vibration on interactions
- **Micro-animations**: Scale, fade, and slide effects

### 🎨 Advanced Flutter Techniques Used

| Feature | Widget/Technique | Purpose |
|---------|------------------|---------|
| **Custom Shapes** | `CustomPainter`, `ClipPath` | Curved navigation, asymmetric cards |
| **Micro-Animations** | `TweenAnimationBuilder`, `Hero` | Price updates, smooth transitions |
| **3D Effects** | `Matrix4` transforms | Parallax scrolling, depth perception |
| **State Management** | Provider pattern ready | Scalable architecture |
| **Premium Theming** | Custom `ThemeData` | Consistent, professional styling |

## 📱 Architecture & Implementation

### File Structure
```
lib/
├── core/
│   └── theme/
│       ├── colors.dart          # Color scheme constants
│       └── theme.dart           # Complete theme configuration
├── widgets/
│   ├── curved_bottom_navigation.dart   # Custom navigation bar
│   ├── parallax_menu_carousel.dart     # 3D category selector
│   ├── floating_food_card.dart         # Asymmetric food cards
│   └── interactive_cart_drawer.dart    # Animated cart experience
├── screens/
│   └── home_screen.dart         # Main app screen
└── main.dart                    # App entry point
```

## 🛠️ Getting Started

1. **Clone and Install**
   ```bash
   flutter pub get
   ```

2. **Run the Application**
   ```bash
   flutter run
   ```

3. **Experience the Features**
   - Scroll through the parallax category carousel
   - Press and hold food cards to see ingredient labels
   - Add items to cart and watch the price animations
   - Navigate using the custom curved bottom bar

---

This implementation showcases the level of sophistication and attention to detail that separates professional Flutter development from basic app creation, making it an ideal portfolio piece for attracting high-quality client work.



## 🧰 CI/CD: Auto‑Deploy Flutter Web to GitHub Pages

This repo includes a GitHub Actions workflow that:
- Installs Flutter
- Builds the web app (`flutter build web`)
- Publishes to the `gh-pages` branch for GitHub Pages hosting

After pushing to `main`, the website will update automatically.

## 🔖 Repository SEO & Discoverability

- Add topics: `flutter`, `dart`, `food-delivery`, `ui-ux`, `material-you`, `animations`
- Add a short description and social preview image in the GitHub repo settings
- Pin this repo on your profile
- Include a clear "Live Demo" and "Place Order" link at the top of the README (done)

## 📄 License

Choose a license (e.g., MIT/Apache-2.0) to encourage forks and contributions.
