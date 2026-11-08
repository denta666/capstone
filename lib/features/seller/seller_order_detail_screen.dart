import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/utils/id_format.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/seller_order.dart';
import 'seller_order_controller.dart';
import 'seller_widgets.dart';

class SellerOrderDetailScreen extends StatelessWidget {
  const SellerOrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  void _advance(BuildContext context, SellerOrder o, SellerOrderStatus next) {
    SellerOrderController.instance.updateStatus(o.id, next);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Status diubah menjadi ${next.label}')),
      );
  }

  Future<void> _cancel(BuildContext context, SellerOrder o) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan pesanan?'),
        content: Text(
          'Pesanan ${o.id} dari ${o.buyerName} akan dibatalkan dan tidak dihitung sebagai pendapatan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Kembali'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      _advance(context, o, SellerOrderStatus.dibatalkan);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SellerOrderController.instance,
      builder: (context, _) {
        final o = SellerOrderController.instance.byId(orderId);

        if (o == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Pesanan')),
            body: const EmptyState(
              icon: Icons.search_off_rounded,
              title: 'Pesanan tidak ditemukan',
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Detail Pesanan')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: [
              // ---------- Header ----------
              AppCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            o.id,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formatTanggal(o.date),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SellerOrderStatusBadge(o.status),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ---------- Progres status ----------
              if (o.status == SellerOrderStatus.dibatalkan)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.dangerSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.cancel_outlined, color: AppColors.danger),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Pesanan ini dibatalkan dan tidak dihitung sebagai pendapatan.',
                          style: TextStyle(fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                )
              else
                AppCard(child: _Timeline(status: o.status)),
              const SizedBox(height: 12),

              // ---------- Pembeli ----------
              AppCard(
                child: Row(
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            o.buyerName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                o.buyerCity,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ---------- Produk ----------
              const SellerSectionTitle('Produk dipesan'),
              AppCard(
                child: Column(
                  children: [
                    for (var i = 0; i < o.lines.length; i++) ...[
                      if (i > 0) const Divider(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  o.lines[i].name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${o.lines[i].qty} x ${formatRupiah(o.lines[i].price)} • ${o.lines[i].unit}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            formatRupiah(o.lines[i].total),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // ---------- Ringkasan ----------
              const SellerSectionTitle('Ringkasan pembayaran'),
              AppCard(
                child: Column(
                  children: [
                    _SumRow('Subtotal produk', formatRupiah(o.subtotal)),
                    _SumRow('Ongkos kirim', formatRupiah(o.shipping)),
                    const Divider(height: 18),
                    _SumRow('Total', formatRupiah(o.total), bold: true),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pendapatan di laporan dihitung dari subtotal produk (tanpa ongkir) pada pesanan berstatus Selesai. Menerima pesanan belum mengurangi stok di versi demo ini. Semua data adalah contoh.',
                style: TextStyle(
                  fontSize: 11,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          bottomNavigationBar: _ActionBar(
            order: o,
            onAdvance: (next) => _advance(context, o, next),
            onCancel: () => _cancel(context, o),
          ),
        );
      },
    );
  }
}

// ======================= Komponen lokal =======================

class _SumRow extends StatelessWidget {
  const _SumRow(this.label, this.value, {this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
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
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.status});

  final SellerOrderStatus status;

  static const _labels = ['Baru', 'Diproses', 'Dikirim', 'Selesai'];

  int get _current => switch (status) {
        SellerOrderStatus.baru => 0,
        SellerOrderStatus.diproses => 1,
        SellerOrderStatus.dikirim => 2,
        SellerOrderStatus.selesai => 3,
        SellerOrderStatus.dibatalkan => -1,
      };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _labels.length; i++)
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: i <= _current ? AppColors.primary : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: i <= _current
                          ? AppColors.primary
                          : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: i < _current || status == SellerOrderStatus.selesai
                        ? const Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: Colors.white,
                          )
                        : Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: i == _current
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _labels[i],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        i == _current ? FontWeight.w800 : FontWeight.w500,
                    color: i <= _current
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.order,
    required this.onAdvance,
    required this.onCancel,
  });

  final SellerOrder order;
  final ValueChanged<SellerOrderStatus> onAdvance;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final s = order.status;
    if (s.isFinal) return const SizedBox.shrink();

    final (String label, IconData icon, SellerOrderStatus next) = switch (s) {
      SellerOrderStatus.baru => (
          'Terima Pesanan',
          Icons.check_rounded,
          SellerOrderStatus.diproses,
        ),
      SellerOrderStatus.diproses => (
          'Tandai Dikirim',
          Icons.local_shipping_outlined,
          SellerOrderStatus.dikirim,
        ),
      _ => (
          'Tandai Selesai',
          Icons.task_alt_rounded,
          SellerOrderStatus.selesai,
        ),
    };

    // Pesanan yang sudah dikirim tidak bisa dibatalkan.
    final canCancel =
        s == SellerOrderStatus.baru || s == SellerOrderStatus.diproses;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              if (canCancel) ...[
                Expanded(
                  child: PrimaryButton(
                    label: s == SellerOrderStatus.baru ? 'Tolak' : 'Batalkan',
                    outlined: true,
                    onPressed: onCancel,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  label: label,
                  icon: icon,
                  onPressed: () => onAdvance(next),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}