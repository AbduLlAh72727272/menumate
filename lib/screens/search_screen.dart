import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/colors.dart';
import '../widgets/menumate_app_bar.dart';

/// Advanced search screen with filters, voice search, and animated results
/// Features sophisticated UI with real-time search and smooth animations
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _voiceController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _voiceAnimation;

  bool _isSearching = false;
  bool _isVoiceListening = false;
  String _selectedCategory = 'All';
  RangeValues _priceRange = const RangeValues(5.0, 50.0);
  double _minRating = 4.0;
  
  final List<String> _categories = [
    'All',
    'Pizza',
    'Burger',
    'Sushi',
    'Dessert',
    'Drinks',
    'Salad',
    'Pasta'
  ];

  final List<SearchResult> _searchResults = [
    SearchResult(
      name: 'Margherita Pizza',
      restaurant: 'Italiano Bistro',
      price: 18.99,
      rating: 4.8,
      image: 'pizza.jpg',
      category: 'Pizza',
      deliveryTime: '25-35 min',
    ),
    SearchResult(
      name: 'Truffle Burger',
      restaurant: 'Gourmet House',
      price: 24.50,
      rating: 4.9,
      image: 'burger.jpg',
      category: 'Burger',
      deliveryTime: '20-30 min',
    ),
    SearchResult(
      name: 'Dragon Roll',
      restaurant: 'Sushi Master',
      price: 32.00,
      rating: 4.7,
      image: 'sushi.jpg',
      category: 'Sushi',
      deliveryTime: '30-40 min',
    ),
    SearchResult(
      name: 'Chocolate Soufflé',
      restaurant: 'Sweet Dreams',
      price: 12.99,
      rating: 4.6,
      image: 'dessert.jpg',
      category: 'Dessert',
      deliveryTime: '15-25 min',
    ),
  ];

  List<SearchResult> _filteredResults = [];

  @override
  void initState() {
    super.initState();
    
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );
    
    _voiceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _voiceAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _voiceController, curve: Curves.easeInOut),
    );

    _filteredResults = _searchResults;
    _fadeController.forward();
    _scaleController.forward();

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _voiceController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _isSearching = _searchController.text.isNotEmpty;
      _filterResults();
    });
  }

  void _filterResults() {
    String query = _searchController.text.toLowerCase();
    
    _filteredResults = _searchResults.where((result) {
      bool matchesSearch = query.isEmpty ||
          result.name.toLowerCase().contains(query) ||
          result.restaurant.toLowerCase().contains(query) ||
          result.category.toLowerCase().contains(query);
      
      bool matchesCategory = _selectedCategory == 'All' || 
          result.category == _selectedCategory;
      
      bool matchesPrice = result.price >= _priceRange.start && 
          result.price <= _priceRange.end;
      
      bool matchesRating = result.rating >= _minRating;
      
      return matchesSearch && matchesCategory && matchesPrice && matchesRating;
    }).toList();
  }

  void _toggleVoiceSearch() {
    setState(() {
      _isVoiceListening = !_isVoiceListening;
    });
    
    if (_isVoiceListening) {
      _voiceController.repeat(reverse: true);
      HapticFeedback.mediumImpact();
      
      // Simulate voice input after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isVoiceListening) {
          _searchController.text = 'pizza margherita';
          _toggleVoiceSearch();
        }
      });
    } else {
      _voiceController.stop();
      _voiceController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MenuMateColors.cloudWhite,
      appBar: const MenuMateSearchAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Search header with filters
            _buildSearchHeader(),
            
            // Category filters
            _buildCategoryFilters(),
            
            // Advanced filters
            _buildAdvancedFilters(),
            
            // Search results
            Expanded(
              child: _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: MenuMateColors.pureWhite,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: MenuMateColors.deepLagoon.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search icon
          Icon(
            Icons.search,
            color: MenuMateColors.deepLagoon.withOpacity(0.7),
            size: 24,
          ),
          
          const SizedBox(width: 16),
          
          // Search input
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search for food, restaurants...',
                hintStyle: TextStyle(
                  color: MenuMateColors.deepLagoon.withOpacity(0.5),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                color: MenuMateColors.deepLagoon,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          // Clear button
          if (_isSearching)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                _searchFocusNode.unfocus();
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: MenuMateColors.deepLagoon.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: MenuMateColors.deepLagoon.withOpacity(0.7),
                  size: 18,
                ),
              ),
            ),
          
          const SizedBox(width: 12),
          
          // Voice search button
          AnimatedBuilder(
            animation: _voiceAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isVoiceListening ? _voiceAnimation.value : 1.0,
                child: GestureDetector(
                  onTap: _toggleVoiceSearch,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isVoiceListening 
                          ? MenuMateColors.citrusSpark
                          : MenuMateColors.mintFog,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isVoiceListening ? Icons.mic : Icons.mic_none_outlined,
                      color: _isVoiceListening 
                          ? MenuMateColors.pureWhite
                          : MenuMateColors.deepLagoon,
                      size: 20,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                  _filterResults();
                });
                HapticFeedback.lightImpact();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            MenuMateColors.deepLagoon,
                            MenuMateColors.mintFog,
                          ],
                        )
                      : null,
                  color: isSelected ? null : MenuMateColors.pureWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? Colors.transparent
                        : MenuMateColors.deepLagoon.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected 
                        ? MenuMateColors.pureWhite
                        : MenuMateColors.deepLagoon,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    return ExpansionTile(
      title: Text(
        'Advanced Filters',
        style: TextStyle(
          color: MenuMateColors.deepLagoon,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Price range slider
              Text(
                'Price Range: \$${_priceRange.start.toStringAsFixed(0)} - \$${_priceRange.end.toStringAsFixed(0)}',
                style: TextStyle(
                  color: MenuMateColors.deepLagoon,
                  fontWeight: FontWeight.w500,
                ),
              ),
              RangeSlider(
                values: _priceRange,
                min: 0.0,
                max: 100.0,
                divisions: 20,
                activeColor: MenuMateColors.citrusSpark,
                inactiveColor: MenuMateColors.mintFog,
                onChanged: (values) {
                  setState(() {
                    _priceRange = values;
                    _filterResults();
                  });
                },
              ),
              
              const SizedBox(height: 20),
              
              // Minimum rating
              Text(
                'Minimum Rating: ${_minRating.toStringAsFixed(1)}',
                style: TextStyle(
                  color: MenuMateColors.deepLagoon,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Slider(
                value: _minRating,
                min: 1.0,
                max: 5.0,
                divisions: 8,
                activeColor: MenuMateColors.citrusSpark,
                inactiveColor: MenuMateColors.mintFog,
                onChanged: (value) {
                  setState(() {
                    _minRating = value;
                    _filterResults();
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_filteredResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: MenuMateColors.deepLagoon.withOpacity(0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                color: MenuMateColors.deepLagoon.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(
                fontSize: 14,
                color: MenuMateColors.deepLagoon.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _filteredResults.length,
      itemBuilder: (context, index) {
        return _buildResultCard(_filteredResults[index], index);
      },
    );
  }

  Widget _buildResultCard(SearchResult result, int index) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              HapticFeedback.mediumImpact();
              // Navigate to food detail
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Food image placeholder
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [
                          MenuMateColors.mintFog,
                          MenuMateColors.citrusSpark.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.restaurant,
                      color: MenuMateColors.deepLagoon,
                      size: 40,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Food details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: MenuMateColors.deepLagoon,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          result.restaurant,
                          style: TextStyle(
                            fontSize: 14,
                            color: MenuMateColors.deepLagoon.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: MenuMateColors.citrusSpark,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              result.rating.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: MenuMateColors.deepLagoon,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: MenuMateColors.mintFog,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              result.deliveryTime,
                              style: TextStyle(
                                fontSize: 12,
                                color: MenuMateColors.deepLagoon.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Price and add button
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${result.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: MenuMateColors.citrusSpark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: MenuMateColors.deepLagoon,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: MenuMateColors.pureWhite,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Search result data model
class SearchResult {
  final String name;
  final String restaurant;
  final double price;
  final double rating;
  final String image;
  final String category;
  final String deliveryTime;

  const SearchResult({
    required this.name,
    required this.restaurant,
    required this.price,
    required this.rating,
    required this.image,
    required this.category,
    required this.deliveryTime,
  });
}