import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/input_style.dart';
import '../../core/utils/format.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/order_record.dart';
import '../account/auth_controller.dart';
import '../account/order_controller.dart';
import '../payment/payment_flow.dart';
import 'cart_controller.dart';

class _Courier {
  const _Courier(this.name, this.eta, this.fee, {this.pickup = false});

  final String name;
  final String eta;
  final int fee;

  /// Ambil sendiri: tidak perlu alamat pengiriman.
  final bool pickup;
}

/// Tarif CONTOH untuk demo, bukan tarif kurir sungguhan.
const _couriers = [
  _Courier('Reguler', 'Estimasi 2-4 hari', 10000),
  _Courier('Ekonomi', 'Estimasi 4-7 hari', 7000),
  _Courier('Kilat', 'Estimasi 1 hari', 20000),
  _Courier('Ambil sendiri', 'Ambil di lokasi penjual', 0, pickup: true),
];

IconData _methodIcon(PaymentMethod m) => switch (m) {
      PaymentMethod.transferBank => Icons.account_balance_outlined,
      PaymentMethod.eWallet => Icons.account_balance_wallet_outlined,
      PaymentMethod.qris => Icons.qr_code_2_rounded,
      PaymentMethod.cod => Icons.payments_outlined,
    };

String _methodHint(PaymentMethod m) => switch (m) {
      PaymentMethod.transferBank => 'Bayar lewat Virtual Account bank',
      PaymentMethod.eWallet => 'Bayar lewat aplikasi dompet digital',
      PaymentMethod.qris => 'Scan kode dengan aplikasi bank atau e-wallet',
      PaymentMethod.cod => 'Bayar langsung saat pesanan diterima',
    };

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _note = TextEditingController();

  int _courierIndex = 0;
  PaymentMethod _method = PaymentMethod.transferBank;
  bool _submitted = false;
  bool _loading = false;

  _Courier get _courier => _couriers[_courierIndex];

  @override
  void initState() {
    super.initState();
    final user = AuthController.instance.current;
    if (user != null) {
      _name.text = user.name;
      _phone.text = user.phone;
      _address.text = user.address;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _city.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    final user = AuthController.instance.current;
    final cart = CartController.instance;
    if (user == null || cart.isEmpty) return;

    setState(() => _loading = true);

    final courier = _courier;
    final order = OrderRecord(
      id: OrderController.instance.newId(),
      ownerEmail: user.email,
      date: DateTime.now(),
      shipping: courier.fee,
      // Metode online menunggu pembayaran; COD langsung diproses.
      status: _method.isOnline
          ? OrderStatus.menungguPembayaran
          : OrderStatus.diproses,
      address: ShippingAddress(
        recipient: _name.text.trim(),
        phone: _phone.text.trim(),
        address: courier.pickup ? '' : _address.text.trim(),
        city: courier.pickup ? '' : _city.text.trim(),
      ),
      courier: courier.name,
      method: _method,
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      lines: [
        for (final l in cart.lines)
          OrderLine(
            productId: l.product.id,
            name: l.product.name,
            unit: l.product.unit,
            qty: l.qty,
            price: l.product.price,
          ),
      ],
    );

    OrderController.instance.add(order);
    cart.clear();

    // Ambil dulu sebelum layar ini ditutup, supaya tetap aman dipakai.
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    navigator.pop(); // tutup checkout
    navigator.pop(); // tutup keranjang

    if (order.method!.isOnline) {
      await payOrder(navigator: navigator, messenger: messenger, order: order);
    } else {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Pesanan COD dibuat. Lihat di Akun > Riwayat transaksi',
            ),
          ),
        );
    }
  }

  // ======================= Tampilan =======================

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Text(
          text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      );

  Widget _row(String label, String value, {bool bold = false}) {
    final style = TextStyle(
      fontSize: bold ? 16 : 13,
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
      color: bold ? AppColors.textPrimary : AppColors.textSecondary,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartController.instance;
    final subtotal = cart.subtotal;
    final total = subtotal + _courier.fee;
    final auto = _submitted
        ? AutovalidateMode.onUserInteraction
        : AutovalidateMode.disabled;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            _sectionLabel('Pengiriman'),
            for (final c in _couriers) ...[
              _OptionTile(
                selected: _courier == c,
                onTap: () => setState(() => _courierIndex = _couriers.indexOf(c)),
                icon: c.pickup
                    ? Icons.storefront_outlined
                    : Icons.local_shipping_outlined,
                title: c.name,
                subtitle: c.eta,
                trailing: c.fee == 0 ? 'Gratis' : formatRupiah(c.fee),
              ),
              const SizedBox(height: 8),
            ],
            const Text(
              'Tarif kurir di atas hanya contoh untuk demo.',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),

            _sectionLabel(_courier.pickup ? 'Data pengambil' : 'Alamat pengiriman'),
            TextFormField(
              controller: _name,
              autovalidateMode: auto,
              textCapitalization: TextCapitalization.words,
              decoration: appInputDecoration(
                _courier.pickup ? 'Nama pengambil' : 'Nama penerima',
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
              validator: (v) => (v == null || v.trim().length < 3)
                  ? 'Isi nama (minimal 3 huruf)'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phone,
              autovalidateMode: auto,
              keyboardType: TextInputType.phone,
              decoration: appInputDecoration(
                'Nomor HP',
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Isi nomor HP';
                return validateOptionalPhone(v);
              },
            ),
            if (!_courier.pickup) ...[
              const SizedBox(height: 14),
              TextFormField(
                controller: _address,
                autovalidateMode: auto,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: appInputDecoration(
                  'Alamat lengkap',
                  hint: 'Jalan, RT/RW, kelurahan, kecamatan',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
                validator: (v) => (v == null || v.trim().length < 10)
                    ? 'Isi alamat lengkap (minimal 10 karakter)'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _city,
                autovalidateMode: auto,
                textCapitalization: TextCapitalization.words,
                decoration: appInputDecoration(
                  'Kota / kabupaten',
                  hint: 'Contoh: Kab. Tegal',
                  prefixIcon: const Icon(Icons.location_city_outlined),
                ),
                validator: (v) => (v == null || v.trim().length < 3)
                    ? 'Isi kota atau kabupaten'
                    : null,
              ),
            ],

            _sectionLabel('Metode pembayaran'),
            for (final m in PaymentMethod.values) ...[
              _OptionTile(
                selected: _method == m,
                onTap: () => setState(() => _method = m),
                icon: _methodIcon(m),
                title: m.label,
                subtitle: _methodHint(m),
              ),
              const SizedBox(height: 8),
            ],

            _sectionLabel('Catatan untuk penjual'),
            TextFormField(
              controller: _note,
              minLines: 2,
              maxLines: 4,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              decoration: appInputDecoration(
                'Catatan (opsional)',
                hint: 'Contoh: tolong dikemas rapat',
              ),
            ),

            _sectionLabel('Ringkasan'),
            AppCard(
              child: Column(
                children: [
                  for (final l in cart.lines)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${l.qty} x ${l.product.name}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          Text(
                            formatRupiah(l.total),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  const Divider(height: 18),
                  _row('Subtotal', formatRupiah(subtotal)),
                  _row(
                    'Ongkos kirim (${_courier.name})',
                    _courier.fee == 0 ? 'Gratis' : formatRupiah(_courier.fee),
                  ),
                  const Divider(height: 18),
                  _row('Total', formatRupiah(total), bold: true),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: PrimaryButton(
              label: _method.isOnline
                  ? 'Bayar ${formatRupiah(total)}'
                  : 'Buat pesanan (COD)',
              icon: _method.isOnline
                  ? Icons.lock_outline_rounded
                  : Icons.check_rounded,
              loading: _loading,
              onPressed: _submit,
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu pilihan (kurir atau metode bayar) dengan penanda terpilih.
class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.selected,
    required this.onTap,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final bool selected;
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primarySoft : Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                Text(
                  trailing!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? AppColors.primary : AppColors.textSecondary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}