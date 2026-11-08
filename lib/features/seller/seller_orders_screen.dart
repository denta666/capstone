import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/utils/id_format.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../models/seller_order.dart';
import '../account/auth_controller.dart';
import 'seller_order_controller.dart';
import 'seller_order_detail_screen.dart';
import 'seller_widgets.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key, this.initial});

  /// Status yang langsung dipilih saat layar dibuka (null = semua).
  final SellerOrderStatus? initial;

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  SellerOrderStatus? _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initial;
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      shape: const StadiumBorder(),
      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: selected ? Colors.white : AppColors.textPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = AuthController.instance.current?.email ?? '';

    return ListenableBuilder(
      listenable: SellerOrderController.instance,
      builder: (context, _) {
        final all = SellerOrderController.instance.forSeller(email);
        final shown =
            _filter == null ? all : all.where((o) => o.status == _filter).toList();

        int countOf(SellerOrderStatus s) =>
            all.where((o) => o.status == s).length;

        return Scaffold(
          appBar: AppBar(title: const Text('Pesanan Masuk')),
          body: all.isEmpty
              ? const EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Belum ada pesanan',
                  message:
                      'Pesanan dari pembeli akan muncul di sini setelah produkmu dibeli.',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: [
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _chip(
                            'Semua (${all.length})',
                            _filter == null,
                            () => setState(() => _filter = null),
                          ),
                          for (final s in SellerOrderStatus.values) ...[
                            const SizedBox(width: 8),
                            _chip(
                              '${s.label} (${countOf(s)})',
                              _filter == s,
                              () => setState(() => _filter = s),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (shown.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: Text(
                            'Tidak ada pesanan pada filter ini.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    else
                      for (final o in shown) ...[
                        _OrderCard(
                          order: o,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  SellerOrderDetailScreen(orderId: o.id),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    const Text(
                      'Semua pesanan di halaman ini adalah data contoh untuk demo.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});

  final SellerOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final first = order.lines.first;
    final more = order.lines.length - 1;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.id,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SellerOrderStatusBadge(order.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${order.buyerName} • ${order.buyerCity}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const Divider(height: 20),
          Text(
            '${first.qty} x ${first.name}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          if (more > 0)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '+ $more produk lainnya',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  formatTanggal(order.date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                formatRupiah(order.total),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}