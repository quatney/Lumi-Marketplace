import 'package:flutter/material.dart';

import '../model/product.dart';

const _green = Color(0xFF246B50);
const _ink = Color(0xFF17211D);
const _muted = Color(0xFF818A84);
const _canvas = Color(0xFFF7F8F5);

class StoreCheckoutPage extends StatefulWidget {
  const StoreCheckoutPage({
    super.key,
    required this.products,
    required this.quantities,
    required this.onPlaced,
  });
  final List<Product> products;
  final Map<int, int> quantities;
  final VoidCallback onPlaced;

  @override
  State<StoreCheckoutPage> createState() => _StoreCheckoutPageState();
}

class _StoreCheckoutPageState extends State<StoreCheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  int _step = 0;
  String _delivery = 'Standard · 2–4 days';
  String _payment = 'M-Pesa (demo)';
  bool _placed = false;
  late final String _orderNumber =
      'GG${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

  double get _subtotal => widget.products.fold(
    0,
    (sum, p) => sum + (p.price ?? 0) * (widget.quantities[p.id] ?? 1),
  );
  double get _deliveryFee =>
      _subtotal >= 100 ? 0 : (_delivery.startsWith('Express') ? 14 : 8);
  double get _total => _subtotal + _deliveryFee;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_placed) return _successPage();
    return Scaffold(
      backgroundColor: _canvas,
      appBar: AppBar(
        backgroundColor: _canvas,
        title: const Text(
          'Checkout',
          style: TextStyle(color: _ink, fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () =>
              _step == 0 ? Navigator.pop(context) : setState(() => _step--),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: List.generate(
                  3,
                  (i) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: i == 2 ? 0 : 7),
                      height: 4,
                      decoration: BoxDecoration(
                        color: i <= _step ? _green : const Color(0xFFE2E7E2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _step == 0
                    ? _contactStep()
                    : _step == 1
                    ? _deliveryStep()
                    : _reviewStep(),
              ),
            ),
            _bottomAction(),
          ],
        ),
      ),
    );
  }

  Widget _contactStep() => Form(
    key: _formKey,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      children: [
        _stepTitle('Your details', 'Where should we send your order?'),
        _field(
          _name,
          'Full name',
          Icons.person_outline,
          validator: (v) =>
              (v == null || v.trim().length < 2) ? 'Enter your name' : null,
        ),
        const SizedBox(height: 12),
        _field(
          _email,
          'Email address',
          Icons.mail_outline,
          keyboard: TextInputType.emailAddress,
          validator: (v) => (v == null || !v.contains('@'))
              ? 'Enter a valid email address'
              : null,
        ),
        const SizedBox(height: 12),
        _field(
          _phone,
          'Phone number',
          Icons.phone_outlined,
          keyboard: TextInputType.phone,
          validator: (v) => (v == null || v.trim().length < 7)
              ? 'Enter a valid phone number'
              : null,
        ),
        const SizedBox(height: 12),
        _field(
          _address,
          'Delivery address',
          Icons.location_on_outlined,
          validator: (v) => (v == null || v.trim().length < 5)
              ? 'Enter your delivery address'
              : null,
        ),
        const SizedBox(height: 18),
        _demoNotice(
          'This is a storefront demo. Your details are not sent or stored.',
        ),
      ],
    ),
  );

  Widget _deliveryStep() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
    children: [
      _stepTitle('Delivery & payment', 'Choose how your order gets to you.'),
      _choiceCard(
        'Standard · 2–4 days',
        'Complimentary over \$100 · otherwise \$8',
        Icons.local_shipping_outlined,
        _delivery,
        (v) => setState(() => _delivery = v),
      ),
      const SizedBox(height: 10),
      _choiceCard(
        'Express · next day',
        '\$14 · selected areas only',
        Icons.bolt_rounded,
        _delivery,
        (v) => setState(() => _delivery = v),
      ),
      const SizedBox(height: 24),
      const Text(
        'PAYMENT METHOD',
        style: TextStyle(
          color: _muted,
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 1.2,
        ),
      ),
      const SizedBox(height: 10),
      _choiceCard(
        'M-Pesa (demo)',
        'Simulated payment option for Kenya',
        Icons.phone_android_rounded,
        _payment,
        (v) => setState(() => _payment = v),
      ),
      const SizedBox(height: 10),
      _choiceCard(
        'Pay on delivery (demo)',
        'No payment will be collected',
        Icons.payments_outlined,
        _payment,
        (v) => setState(() => _payment = v),
      ),
      const SizedBox(height: 18),
      _demoNotice(
        'No real payment is processed. This checkout is for demonstration only.',
      ),
    ],
  );

  Widget _reviewStep() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
    children: [
      _stepTitle('Review your order', 'Everything looking good?'),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _name.text,
              style: const TextStyle(fontWeight: FontWeight.w800, color: _ink),
            ),
            const SizedBox(height: 4),
            Text(_email.text, style: const TextStyle(color: _muted)),
            Text(_phone.text, style: const TextStyle(color: _muted)),
            const SizedBox(height: 8),
            Text(_address.text, style: const TextStyle(color: _muted)),
            const Divider(height: 24),
            Text(
              _delivery,
              style: const TextStyle(color: _ink, fontWeight: FontWeight.w700),
            ),
            Text(_payment, style: const TextStyle(color: _muted)),
          ],
        ),
      ),
      const SizedBox(height: 14),
      ...widget.products.map(
        (p) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${p.name}  × ${widget.quantities[p.id] ?? 1}',
                  style: const TextStyle(color: _ink),
                ),
              ),
              Text(
                '\$${((p.price ?? 0) * (widget.quantities[p.id] ?? 1)).toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
      const Divider(height: 24),
      _summaryRow('Subtotal', _subtotal),
      const SizedBox(height: 8),
      _summaryRow('Delivery', _deliveryFee, free: _deliveryFee == 0),
      const Divider(height: 22),
      _summaryRow('Total', _total, strong: true),
      const SizedBox(height: 15),
      _demoNotice('Demo order only — placing this order does not charge you.'),
    ],
  );

  Widget _bottomAction() => Container(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
    color: Colors.white,
    child: SafeArea(
      top: false,
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: FilledButton(
          onPressed: _continue,
          style: FilledButton.styleFrom(
            backgroundColor: _green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Text(
            _step == 2
                ? 'Place demo order · \$${_total.toStringAsFixed(2)}'
                : 'Continue',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
    ),
  );

  void _continue() {
    if (_step == 0 && !_formKey.currentState!.validate()) return;
    if (_step < 2) {
      setState(() => _step++);
      return;
    }
    setState(() => _placed = true);
    widget.onPlaced();
  }

  Widget _successPage() {
    return Scaffold(
      backgroundColor: _canvas,
      appBar: AppBar(
        backgroundColor: _canvas,
        automaticallyImplyLeading: false,
        title: const Text(
          'Order confirmed',
          style: TextStyle(color: _ink, fontWeight: FontWeight.w800),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F1EB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, size: 44, color: _green),
              ),
              const SizedBox(height: 22),
              const Text(
                'Thanks, your order is in!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 25,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This is a simulated order confirmation. No payment was made.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, height: 1.5),
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    const Text(
                      'DEMO ORDER NUMBER',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _orderNumber,
                      style: const TextStyle(
                        color: _green,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Divider(height: 28),
                    _summaryRow('Items', widget.products.length.toDouble()),
                    _summaryRow('Order total', _total, strong: true),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  style: FilledButton.styleFrom(backgroundColor: _green),
                  child: const Text('Continue shopping'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepTitle(String title, String subtitle) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _ink,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(subtitle, style: const TextStyle(color: _muted)),
      ],
    ),
  );
  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: controller,
    keyboardType: keyboard,
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE8EBE7)),
      ),
    ),
  );
  Widget _choiceCard(
    String title,
    String subtitle,
    IconData icon,
    String selected,
    ValueChanged<String> onSelected,
  ) => InkWell(
    onTap: () => onSelected(title),
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected == title ? _green : const Color(0xFFE8EBE7),
          width: selected == title ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: _green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(
            selected == title
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_off_rounded,
            color: selected == title ? _green : _muted,
          ),
        ],
      ),
    ),
  );
  Widget _demoNotice(String text) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F1EB),
      borderRadius: BorderRadius.circular(13),
    ),
    child: Row(
      children: [
        const Icon(Icons.info_outline_rounded, size: 18, color: _green),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: _green, fontSize: 12, height: 1.4),
          ),
        ),
      ],
    ),
  );
  Widget _summaryRow(
    String label,
    double value, {
    bool free = false,
    bool strong = false,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: strong ? _ink : _muted,
              fontWeight: strong ? FontWeight.w800 : FontWeight.normal,
            ),
          ),
        ),
        Text(
          free ? 'FREE' : '\$${value.toStringAsFixed(2)}',
          style: TextStyle(
            color: free ? _green : _ink,
            fontWeight: FontWeight.w800,
            fontSize: strong ? 17 : 14,
          ),
        ),
      ],
    ),
  );
}
