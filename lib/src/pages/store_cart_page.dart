import 'package:flutter/material.dart';

import '../model/product.dart';

const _ink = Color(0xFF17211D);
const _muted = Color(0xFF818A84);
const _green = Color(0xFF246B50);
const _canvas = Color(0xFFF7F8F5);

class StoreCartPage extends StatefulWidget {
  const StoreCartPage({
    super.key,
    required this.products,
    required this.quantities,
    required this.onQuantityChanged,
    required this.onRemove,
    required this.onCheckout,
  });

  final List<Product> products;
  final Map<int, int> quantities;
  final void Function(Product product, int quantity) onQuantityChanged;
  final ValueChanged<Product> onRemove;
  final VoidCallback onCheckout;

  @override
  State<StoreCartPage> createState() => _StoreCartPageState();
}

class _StoreCartPageState extends State<StoreCartPage> {
  final _promoController = TextEditingController();
  bool _promoApplied = false;
  String? _promoError;

  int _quantity(Product product) => widget.quantities[product.id] ?? 1;

  double get _subtotal => widget.products.fold(
    0,
    (total, product) => total + (product.price ?? 0) * _quantity(product),
  );

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 92,
                width: 92,
                decoration: const BoxDecoration(
                  color: _canvas,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  size: 40,
                  color: _green,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Your bag is waiting',
                style: TextStyle(
                  color: _ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add something you love and it will show up here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, height: 1.5),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            itemCount: widget.products.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _CartItem(
              product: widget.products[index],
              quantity: _quantity(widget.products[index]),
              onQuantityChanged: (value) =>
                  widget.onQuantityChanged(widget.products[index], value),
              onRemove: () => widget.onRemove(widget.products[index]),
            ),
          ),
        ),
        _summary(context),
      ],
    );
  }

  Widget _summary(BuildContext context) {
    final delivery = _subtotal >= 100 ? 0.0 : 8.0;
    final discount = _promoApplied ? _subtotal * 0.10 : 0.0;
    final total = _subtotal + delivery - discount;
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 19, 22, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: _ink.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.local_shipping_outlined,
                  color: _green,
                  size: 19,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _subtotal >= 100
                        ? 'You unlocked free delivery!'
                        : 'Free delivery on orders over \$100',
                    style: const TextStyle(
                      color: _green,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promoController,
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (_) => setState(() => _promoError = null),
                    decoration: InputDecoration(
                      hintText: 'Promo code',
                      isDense: true,
                      errorText: _promoError,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                OutlinedButton(
                  onPressed: () {
                    final code = _promoController.text.trim().toUpperCase();
                    setState(() {
                      _promoApplied = code == 'GOOD10';
                      _promoError = _promoApplied ? null : 'Try GOOD10';
                    });
                  },
                  child: Text(_promoApplied ? 'Applied' : 'Apply'),
                ),
              ],
            ),
            if (_promoApplied) ...[
              const SizedBox(height: 10),
              _priceRow('GOOD10 discount (10%)', -discount),
            ],
            const SizedBox(height: 14),
            _priceRow('Subtotal', _subtotal),
            const SizedBox(height: 9),
            _priceRow('Delivery', delivery, free: delivery == 0),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 13),
              child: Divider(height: 1, color: Color(0xFFE9ECE8)),
            ),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: widget.onCheckout,
                style: FilledButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.lock_outline_rounded, size: 18),
                label: const Text(
                  'Continue to checkout',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, double value, {bool free = false}) => Row(
    children: [
      Expanded(
        child: Text(label, style: const TextStyle(color: _muted)),
      ),
      Text(
        free
            ? 'FREE'
            : value < 0
            ? '-\$${value.abs().toStringAsFixed(2)}'
            : '\$${value.toStringAsFixed(2)}',
        style: TextStyle(
          color: free || value < 0 ? _green : _ink,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _CartItem extends StatelessWidget {
  const _CartItem({
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  final Product product;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: const Color(0xFFECEFEC)),
    ),
    child: Row(
      children: [
        Container(
          height: 84,
          width: 84,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _canvas,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Image.asset(product.image ?? '', fit: BoxFit.contain),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.category?.toUpperCase() ?? 'ESSENTIALS',
                style: const TextStyle(
                  color: _muted,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                product.name ?? 'Everyday essential',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${((product.price ?? 0) * quantity).toStringAsFixed(2)}',
                style: const TextStyle(
                  color: _green,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Column(
          children: [
            IconButton(
              tooltip: 'Remove item',
              visualDensity: VisualDensity.compact,
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline_rounded, size: 19),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _QuantityButton(
                  icon: Icons.remove_rounded,
                  onTap: () => onQuantityChanged(quantity - 1),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '$quantity',
                    style: const TextStyle(
                      color: _ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _QuantityButton(
                  icon: Icons.add_rounded,
                  onTap: () => onQuantityChanged(quantity + 1),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 28,
    width: 28,
    child: IconButton(
      tooltip: icon == Icons.add_rounded
          ? 'Increase quantity'
          : 'Decrease quantity',
      onPressed: onTap,
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        backgroundColor: _canvas,
        foregroundColor: _ink,
      ),
      icon: Icon(icon, size: 15),
    ),
  );
}
