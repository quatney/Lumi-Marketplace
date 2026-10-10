import 'dart:async';

import 'package:flutter/material.dart';

import '../model/product.dart';

const _ink = Color(0xFF17211D);
const _muted = Color(0xFF818A84);
const _accent = Color(0xFF246B50);
const _canvas = Color(0xFFF7F8F5);

class StoreHomePage extends StatefulWidget {
  const StoreHomePage({
    super.key,
    required this.products,
    required this.favoriteIds,
    required this.isFavoritesPage,
    required this.searchMode,
    required this.cartIds,
    required this.onToggleFavorite,
    required this.onAddToCart,
    required this.onToggleCart,
    required this.onOpenProduct,
  });

  final List<Product> products;
  final Set<int> favoriteIds;
  final bool isFavoritesPage;
  final bool searchMode;
  final Set<int> cartIds;
  final ValueChanged<Product> onToggleFavorite;
  final ValueChanged<Product> onAddToCart;
  final ValueChanged<Product> onToggleCart;
  final ValueChanged<Product> onOpenProduct;

  @override
  State<StoreHomePage> createState() => _StoreHomePageState();
}

class _StoreHomePageState extends State<StoreHomePage> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _sortBy = 'Featured';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _categories => [
    'All',
    ...widget.products.map((product) => product.category ?? 'Other').toSet(),
  ];

  List<Product> get _visibleProducts {
    final query = _searchController.text.trim().toLowerCase();
    final products = widget.products.where((product) {
      final matchesCategory =
          _selectedCategory == 'All' || product.category == _selectedCategory;
      final matchesQuery =
          query.isEmpty ||
          (product.name ?? '').toLowerCase().contains(query) ||
          (product.category ?? '').toLowerCase().contains(query);
      final matchesFavorite =
          !widget.isFavoritesPage || widget.favoriteIds.contains(product.id);
      return matchesCategory && matchesQuery && matchesFavorite;
    }).toList();
    if (_sortBy == 'Price: low to high') {
      products.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
    } else if (_sortBy == 'Price: high to low') {
      products.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
    } else if (_sortBy == 'Top rated') {
      products.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    } else if (_sortBy == 'Newest') {
      products.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    }
    return products;
  }

  @override
  Widget build(BuildContext context) {
    final products = _visibleProducts;
    return CustomScrollView(
      key: PageStorageKey(widget.isFavoritesPage ? 'favorites' : 'products'),
      physics: const BouncingScrollPhysics(),
      slivers: [
        if (!widget.searchMode && !widget.isFavoritesPage)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            sliver: SliverToBoxAdapter(child: _announcement()),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          sliver: SliverToBoxAdapter(child: _searchField()),
        ),
        if (!widget.searchMode)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            sliver: SliverToBoxAdapter(child: _shoppingPerk()),
          ),
        if (!widget.searchMode && !widget.isFavoritesPage)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
            sliver: SliverToBoxAdapter(child: _campaignCard()),
          ),
        if (!widget.searchMode && !widget.isFavoritesPage)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
            sliver: const SliverToBoxAdapter(child: _DealCountdown()),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
          sliver: SliverToBoxAdapter(child: _sectionHeader(products.length)),
        ),
        SliverToBoxAdapter(child: _categoryChips()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          sliver: products.isEmpty
              ? SliverToBoxAdapter(child: _emptyState())
              : SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.crossAxisExtent > 650 ? 3 : 2;
                    return SliverGrid.builder(
                      itemCount: products.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: constraints.crossAxisExtent > 650
                            ? 0.76
                            : 0.70,
                      ),
                      itemBuilder: (context, index) => _ProductTile(
                        product: products[index],
                        isFavorite: widget.favoriteIds.contains(
                          products[index].id,
                        ),
                        onFavorite: () =>
                            widget.onToggleFavorite(products[index]),
                        onAdd: () => widget.onAddToCart(products[index]),
                        onToggleCart: () =>
                            widget.onToggleCart(products[index]),
                        inCart: widget.cartIds.contains(products[index].id),
                        onTap: () => widget.onOpenProduct(products[index]),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _announcement() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F1EB),
      borderRadius: BorderRadius.circular(11),
    ),
    child: Row(
      children: const [
        Icon(Icons.local_shipping_outlined, color: _accent, size: 16),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'A little treat: delivery on orders over 100',
            style: TextStyle(
              color: _ink,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Icon(Icons.arrow_forward_rounded, color: _accent, size: 15),
      ],
    ),
  );

  Widget _searchField() => TextField(
    controller: _searchController,
    autofocus: widget.searchMode,
    textInputAction: TextInputAction.search,
    onChanged: (_) => setState(() {}),
    decoration: InputDecoration(
      hintText: 'Search shoes, jackets, watches...',
      prefixIcon: const Icon(Icons.search_rounded, color: _muted),
      suffixIcon: _searchController.text.isEmpty
          ? IconButton(
              tooltip: 'Sort products',
              onPressed: _showSortOptions,
              icon: const Icon(Icons.tune_rounded, color: _ink),
            )
          : IconButton(
              tooltip: 'Clear search',
              onPressed: () {
                _searchController.clear();
                setState(() {});
              },
              icon: const Icon(Icons.close_rounded),
            ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: Color(0xFFE9ECE8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: _accent, width: 1.4),
      ),
    ),
  );

  Widget _shoppingPerk() => Row(
    children: [
      const Icon(Icons.local_shipping_outlined, color: _accent, size: 17),
      const SizedBox(width: 7),
      const Expanded(
        child: Text(
          'Complimentary delivery on orders over \$100',
          style: TextStyle(
            color: _ink,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      if (_sortBy != 'Featured')
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F1EB),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _sortBy == 'Price: low to high' ? 'Price ↑' : 'Price ↓',
            style: const TextStyle(
              color: _accent,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
    ],
  );

  Widget _campaignCard() => Container(
    height: 178,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: const LinearGradient(
        colors: [Color(0xFF183D30), Color(0xFF32795B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    clipBehavior: Clip.antiAlias,
    child: Stack(
      children: [
        Positioned(
          right: -17,
          bottom: -25,
          width: 205,
          height: 190,
          child: Transform.rotate(
            angle: -0.18,
            child: Image.asset('assets/shooe_tilt_1.png', fit: BoxFit.contain),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 8, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'NEW SEASON',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                'Move in\nyour own style.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 23,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Fresh picks, made for every day.',
                style: TextStyle(color: Color(0xFFDCEBE2), fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _sectionHeader(int count) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isFavoritesPage ? 'SAVED FOR LATER' : 'CURATED FOR YOU',
              style: const TextStyle(
                color: _muted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.isFavoritesPage ? 'Your wishlist' : 'Our Products',
              style: const TextStyle(
                color: _ink,
                fontSize: 23,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
          ],
        ),
      ),
      Text('$count items', style: const TextStyle(color: _muted, fontSize: 12)),
    ],
  );

  Widget _categoryChips() => SizedBox(
    height: 42,
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      scrollDirection: Axis.horizontal,
      itemCount: _categories.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final category = _categories[index];
        final selected = category == _selectedCategory;
        return ChoiceChip(
          label: Text(category),
          selected: selected,
          showCheckmark: false,
          onSelected: (_) => setState(() => _selectedCategory = category),
          labelStyle: TextStyle(
            color: selected ? Colors.white : _ink,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          selectedColor: _ink,
          backgroundColor: Colors.white,
          side: BorderSide(color: selected ? _ink : const Color(0xFFE8EBE7)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        );
      },
    ),
  );

  Widget _emptyState() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 55),
    child: Column(
      children: [
        Icon(
          widget.isFavoritesPage
              ? Icons.favorite_border_rounded
              : Icons.search_off_rounded,
          size: 42,
          color: const Color(0xFFB5BDB7),
        ),
        const SizedBox(height: 12),
        Text(
          widget.isFavoritesPage
              ? 'No saved items yet'
              : 'Nothing matched your search',
          style: const TextStyle(color: _ink, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        const Text(
          'Try another search or browse a different category.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _muted, fontSize: 12),
        ),
      ],
    ),
  );

  Future<void> _showSortOptions() async {
    final selection = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                'Sort products',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            for (final option in [
              'Featured',
              'Newest',
              'Top rated',
              'Price: low to high',
              'Price: high to low',
            ])
              ListTile(
                title: Text(option),
                trailing: _sortBy == option
                    ? const Icon(Icons.check_rounded, color: _accent)
                    : null,
                onTap: () => Navigator.pop(context, option),
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
    if (selection != null && mounted) setState(() => _sortBy = selection);
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    required this.isFavorite,
    required this.onFavorite,
    required this.onAdd,
    required this.onToggleCart,
    required this.inCart,
    required this.onTap,
  });

  final Product product;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onAdd;
  final VoidCallback onToggleCart;
  final bool inCart;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(21),
    child: InkWell(
      borderRadius: BorderRadius.circular(21),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: _canvas,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        product.image ?? '',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 3,
                    right: 3,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.95),
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: isFavorite
                            ? 'Remove from wishlist'
                            : 'Save to wishlist',
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints.tightFor(
                          width: 36,
                          height: 36,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: onFavorite,
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 18,
                          color: isFavorite ? const Color(0xFFE45B58) : _ink,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 11),
            Text(
              product.category?.toUpperCase() ?? 'ESSENTIALS',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _muted,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              product.name ?? 'Everyday essential',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _ink,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Row(
              children: [
                Icon(Icons.star_rounded, color: Color(0xFFF0B33E), size: 14),
                SizedBox(width: 3),
                Text(
                  '4.8',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 4),
                Text('·', style: TextStyle(color: _muted, fontSize: 10)),
                SizedBox(width: 4),
                Text(
                  'Popular pick',
                  style: TextStyle(color: _muted, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '\$${(product.price ?? 0).toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(
                  height: 34,
                  width: 34,
                  child: IconButton.filled(
                    tooltip: inCart ? 'Remove from bag' : 'Add to bag',
                    onPressed: onToggleCart,
                    padding: EdgeInsets.zero,
                    style: IconButton.styleFrom(
                      backgroundColor: inCart
                          ? const Color(0xFFE8F1EB)
                          : _accent,
                      foregroundColor: inCart ? _accent : Colors.white,
                    ),
                    icon: Icon(
                      inCart ? Icons.add_rounded : Icons.shopping_bag_outlined,
                      size: 18,
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

class _DealCountdown extends StatefulWidget {
  const _DealCountdown();
  @override
  State<_DealCountdown> createState() => _DealCountdownState();
}

class _DealCountdownState extends State<_DealCountdown> {
  late Duration _remaining;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _remaining = const Duration(hours: 5, minutes: 42, seconds: 18);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(
        () => _remaining = _remaining.inSeconds <= 1
            ? const Duration(hours: 5, minutes: 42, seconds: 18)
            : _remaining - const Duration(seconds: 1),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String two(int value) => value.toString().padLeft(2, '0');
    return Row(
      children: [
        const Icon(Icons.flash_on_rounded, color: Color(0xFFE69A35), size: 19),
        const SizedBox(width: 7),
        const Expanded(
          child: Text(
            'THE DAILY EDIT  ·  UP TO 30% OFF',
            style: TextStyle(
              color: _ink,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
            ),
          ),
        ),
        _timeBox(two(_remaining.inHours)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 3),
          child: Text(':', style: TextStyle(color: _muted)),
        ),
        _timeBox(two(_remaining.inMinutes.remainder(60))),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 3),
          child: Text(':', style: TextStyle(color: _muted)),
        ),
        _timeBox(two(_remaining.inSeconds.remainder(60))),
      ],
    );
  }

  Widget _timeBox(String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    decoration: BoxDecoration(
      color: _ink,
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      value,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
