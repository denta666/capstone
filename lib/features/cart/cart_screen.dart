import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/quantity_stepper.dart';
import '../../navigation/app_navigation.dart';
import 'cart_controller.dart';

const int _shipping = 10000; // ongkir simulasi

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = CartController.instance;

    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) {
        final lines = cart.lines;

        return Scaffold(
          appBar: AppBar(title: const Text('Keranjang')),
          body: lines.isEmpty
              ? EmptyState(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Keranjang masih kosong',
                  message: 'Yuk, cari kompos, maggot BSF, atau pupuk organik.',
                  actionLabel: 'Mulai belanja',
                  onAction: () {
                    Navigator.of(context).popUntil((r) => r.isFirst);
                    mainTabIndex.value = 1;
                  },
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: lines.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, i) =>
                      _CartLineTile(line: lines[i], cart: cart),
                ),
          bottomNavigationBar: lines.isEmpty
              ? null
              : _SummaryBar(subtotal: cart.subtotal, cart: cart),
        );
      },
    );
  }
}

class _CartLineTile extends StatelessWidget {
  const _CartLineTile({required this.line, required this.cart});

  final CartLine line;
  final CartController cart;

  @override
  Widget build(BuildContext context) {
    final p = line.product;

    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppImage(
            assetPath: p.imagePath,
            icon: p.icon,
            height: 76,
            width: 76,
            radius: 12,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        p.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => cart.remove(p.id),
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 32, minHeight: 32),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
                Text(
                  p.unit,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        formatRupiah(line.total),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    QuantityStepper(
                      value: line.qty,
                      onDecrement: () => cart.decrement(p.id),
                      onIncrement: line.qty >= p.stock
                          ? null
                          : () => cart.increment(p.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.subtotal, required this.cart});

  final int subtotal;
  final CartController cart;

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

  Future<void> _checkout(BuildContext context, int total) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Checkout (simulasi)'),
        content: Text(
          'Total ${formatRupiah(total)}.\n\n'
          'Ini hanya simulasi untuk demo tampilan. '
          'Tidak ada pembayaran sungguhan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Buat pesanan'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      cart.clear();
      Navigator.of(context).pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Pesanan simulasi berhasil dibuat')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = subtotal + _shipping;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _row('Subtotal', formatRupiah(subtotal)),
              _row('Ongkos kirim (simulasi)', formatRupiah(_shipping)),
              const Divider(height: 16),
              _row('Total', formatRupiah(total), bold: true),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Checkout (simulasi)',
                icon: Icons.lock_outline_rounded,
                onPressed: () => _checkout(context, total),
              ),
            ],
          ),
        ),
      ),
    );
  }
}