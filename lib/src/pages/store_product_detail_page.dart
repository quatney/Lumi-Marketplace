import 'package:flutter/material.dart';

import '../model/product.dart';

const _ink = Color(0xFF17211D);
const _muted = Color(0xFF818A84);
const _green = Color(0xFF246B50);
const _canvas = Color(0xFFF7F8F5);

class StoreProductDetailPage extends StatefulWidget {
  const StoreProductDetailPage({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onAddToCart,
  });

  final Product product;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAddToCart;

  @override
  State<StoreProductDetailPage> createState() => _StoreProductDetailPageState();
}

class _StoreProductDetailPageState extends State<StoreProductDetailPage> {
  late bool _isFavorite;
  String _selectedSize = 'US 7';

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  void didUpdateWidget(covariant StoreProductDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      _isFavorite = widget.isFavorite;
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      backgroundColor: _canvas,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: _canvas,
            surfaceTintColor: _canvas,
            leading: IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded, color: _ink),
            ),
            actions: [
              IconButton(
                tooltip: _isFavorite
                    ? 'Remove from wishlist'
                    : 'Save to wishlist',
                onPressed: () {
                  setState(() => _isFavorite = !_isFavorite);
                  widget.onToggleFavorite();
                },
                icon: Icon(
                  _isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: _isFavorite ? const Color(0xFFE45B58) : _ink,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 310,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    padding: const EdgeInsets.all(25),
                    child: Hero(
                      tag: 'product-${product.id}',
                      child: Image.asset(
                        product.image ?? '',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (product.category ?? 'ESSENTIALS').toUpperCase(),
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.4,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              product.name ?? 'Everyday essential',
                              style: const TextStyle(
                                color: _ink,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${(product.price ?? 0).toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: _green,
                          fontWeight: FontWeight.w800,
                          fontSize: 21,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: Color(0xFFF0B33E),
                        size: 19,
                      ),
                      Icon(
                        Icons.star_rounded,
                        color: Color(0xFFF0B33E),
                        size: 19,
                      ),
                      Icon(
                        Icons.star_rounded,
                        color: Color(0xFFF0B33E),
                        size: 19,
                      ),
                      Icon(
                        Icons.star_rounded,
                        color: Color(0xFFF0B33E),
                        size: 19,
                      ),
                      Icon(
                        Icons.star_half_rounded,
                        color: Color(0xFFF0B33E),
                        size: 19,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '4.8  · 124 reviews',
                        style: TextStyle(color: _muted, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'Choose your size',
                    style: TextStyle(
                      color: _ink,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 9,
                    runSpacing: 9,
                    children: ['US 6', 'US 7', 'US 8', 'US 9', 'US 10'].map((
                      size,
                    ) {
                      final selected = _selectedSize == size;
                      return ChoiceChip(
                        label: Text(size),
                        selected: selected,
                        showCheckmark: false,
                        onSelected: (_) => setState(() => _selectedSize = size),
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : _ink,
                          fontWeight: FontWeight.w700,
                        ),
                        selectedColor: _green,
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: selected ? _green : const Color(0xFFE6EAE5),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'About this item',
                    style: TextStyle(
                      color: _ink,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'Thoughtfully designed for all-day comfort and everyday versatility. '
                    'Premium details meet a timeless silhouette, making this an easy '
                    'favorite season after season.',
                    style: const TextStyle(
                      color: _muted,
                      height: 1.6,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 13),
          child: SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: () {
                widget.onAddToCart();
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text('${product.name} added to your bag'),
                      behavior: SnackBarBehavior.floating,
                      action: SnackBarAction(
                        label: 'VIEW BAG',
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
              },
              style: FilledButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text(
                'Add to bag',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
