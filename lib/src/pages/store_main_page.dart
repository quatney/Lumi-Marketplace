import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/data.dart';
import '../model/product.dart';
import 'store_cart_page.dart';
import 'store_checkout_page.dart';
import 'store_home_page.dart';
import 'store_product_detail_page.dart';

const _ink = Color(0xFF17211D);
const _muted = Color(0xFF818A84);
const _green = Color(0xFF246B50);
const _canvas = Color(0xFFF7F8F5);

class StoreMainPage extends StatefulWidget {
  const StoreMainPage({super.key});

  @override
  State<StoreMainPage> createState() => _StoreMainPageState();
}

class _StoreMainPageState extends State<StoreMainPage> {
  int _selectedIndex = 0;
  final Set<int> _favoriteIds = {};
  final Map<int, int> _quantities = {};

  @override
  void initState() {
    super.initState();
    _restoreDemoState();
  }

  Future<void> _restoreDemoState() async {
    final preferences = await SharedPreferences.getInstance();
    final favorites =
        preferences.getStringList('goodthings_favorites') ?? const <String>[];
    final rawCart = preferences.getString('goodthings_cart');
    final cart = rawCart == null
        ? <String, dynamic>{}
        : jsonDecode(rawCart) as Map<String, dynamic>;
    if (!mounted) return;
    setState(() {
      _favoriteIds.addAll(favorites.map(int.parse));
      for (final entry in cart.entries) {
        final quantity = entry.value as int;
        if (quantity > 0) _quantities[int.parse(entry.key)] = quantity;
      }
    });
  }

  Future<void> _persistDemoState() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      'goodthings_favorites',
      _favoriteIds.map((id) => id.toString()).toList(),
    );
    await preferences.setString(
      'goodthings_cart',
      jsonEncode(
        _quantities.map((id, quantity) => MapEntry(id.toString(), quantity)),
      ),
    );
  }

  String get _pageTitle => switch (_selectedIndex) {
    2 => 'Your wishlist',
    3 => 'Your bag',
    _ => 'Our Products',
  };

  int get _cartCount =>
      _quantities.values.fold(0, (sum, quantity) => sum + quantity);

  void _toggleFavorite(Product product) {
    final id = product.id;
    if (id == null) return;
    setState(() {
      if (!_favoriteIds.add(id)) _favoriteIds.remove(id);
      product.isliked = _favoriteIds.contains(id);
    });
    _persistDemoState();
  }

  void _addToCart(Product product) {
    final id = product.id;
    if (id == null) return;
    setState(() {
      product.isSelected = true;
      _quantities.update(id, (quantity) => quantity + 1, ifAbsent: () => 1);
    });
    _persistDemoState();
  }

  void _toggleCart(Product product) {
    final id = product.id;
    if (id == null) return;
    setState(() {
      if (_quantities.containsKey(id)) {
        _quantities.remove(id);
        product.isSelected = false;
      } else {
        _quantities[id] = 1;
        product.isSelected = true;
      }
    });
    _persistDemoState();
  }

  void _changeQuantity(Product product, int quantity) {
    final id = product.id;
    if (id == null) return;
    setState(() {
      if (quantity <= 0) {
        _quantities.remove(id);
        product.isSelected = false;
      } else {
        _quantities[id] = quantity;
        product.isSelected = true;
      }
    });
    _persistDemoState();
  }

  void _openProduct(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StoreProductDetailPage(
          product: product,
          isFavorite: _favoriteIds.contains(product.id),
          onToggleFavorite: () => _toggleFavorite(product),
          onAddToCart: () => _addToCart(product),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      appBar: AppBar(
        backgroundColor: _canvas,
        surfaceTintColor: _canvas,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 78,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GOOD THINGS, WELL MADE',
              style: TextStyle(
                color: _muted,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              _pageTitle,
              style: const TextStyle(
                color: _ink,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Your profile',
            onPressed: () => _showProfile(context),
            icon: CircleAvatar(
              radius: 17,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: Image.asset(
                  'assets/user.png',
                  width: 34,
                  height: 34,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _storePage(isFavorites: false, searchMode: false),
          _storePage(isFavorites: false, searchMode: true),
          _storePage(isFavorites: true, searchMode: false),
          StoreCartPage(
            products: AppData.productList
                .where((product) => _quantities.containsKey(product.id))
                .toList(),
            quantities: _quantities,
            onQuantityChanged: _changeQuantity,
            onRemove: (product) => _changeQuantity(product, 0),
            onCheckout: () => _showCheckout(context),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: 69,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        indicatorColor: const Color(0xFFE8F1EB),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          NavigationDestination(
            icon: _favoriteIcon(Icons.favorite_border_rounded),
            selectedIcon: _favoriteIcon(Icons.favorite_rounded),
            label: _favoriteIds.isEmpty
                ? 'Saved'
                : 'Saved (${_favoriteIds.length})',
          ),
          NavigationDestination(
            icon: _cartIcon(Icons.shopping_bag_outlined),
            selectedIcon: _cartIcon(Icons.shopping_bag_rounded),
            label: _cartCount > 0 ? 'Bag ($_cartCount)' : 'Bag',
          ),
        ],
      ),
    );
  }

  Widget _cartIcon(IconData icon) => Badge(
    isLabelVisible: _cartCount > 0,
    label: Text('$_cartCount'),
    backgroundColor: _green,
    child: Icon(icon),
  );

  Widget _favoriteIcon(IconData icon) => Badge(
    isLabelVisible: _favoriteIds.isNotEmpty,
    label: Text('${_favoriteIds.length}'),
    backgroundColor: const Color(0xFFE45B58),
    child: Icon(icon),
  );

  Widget _storePage({required bool isFavorites, required bool searchMode}) =>
      StoreHomePage(
        key: ValueKey('$isFavorites-$searchMode'),
        products: AppData.productList,
        favoriteIds: _favoriteIds,
        isFavoritesPage: isFavorites,
        searchMode: searchMode,
        cartIds: _quantities.keys.toSet(),
        onToggleFavorite: _toggleFavorite,
        onAddToCart: _addToCart,
        onToggleCart: (product) {
          final wasInCart = _quantities.containsKey(product.id);
          _toggleCart(product);
          if (wasInCart) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('${product.name} added to your bag'),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
                action: SnackBarAction(
                  label: 'VIEW BAG',
                  onPressed: () => setState(() => _selectedIndex = 3),
                ),
              ),
            );
        },
        onOpenProduct: _openProduct,
      );

  void _showProfile(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 34,
                backgroundColor: Color(0xFFE8F1EB),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: _green,
                  size: 34,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Welcome to the good things club',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your favorite finds and everyday essentials, all in one place.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, height: 1.4),
              ),
              const SizedBox(height: 19),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Continue browsing'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCheckout(BuildContext context) {
    if (_quantities.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StoreCheckoutPage(
          products: AppData.productList
              .where((product) => _quantities.containsKey(product.id))
              .toList(),
          quantities: Map<int, int>.from(_quantities),
          onPlaced: () {
            setState(() {
              for (final product in AppData.productList) {
                if (_quantities.containsKey(product.id)) {
                  product.isSelected = false;
                }
              }
              _quantities.clear();
            });
            _persistDemoState();
          },
        ),
      ),
    );
  }
}
