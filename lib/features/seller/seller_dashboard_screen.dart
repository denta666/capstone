import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/product_repository.dart';
import '../../models/seller_order.dart';
import '../../models/user_account.dart';
import '../account/auth_controller.dart';
import 'seller_order_controller.dart';
import 'seller_order_detail_screen.dart';
import 'seller_orders_screen.dart';
import 'seller_product_form_screen.dart';
import 'seller_products_screen.dart';
import 'seller_report_screen.dart';
import 'seller_widgets.dart';

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        AuthController.instance,
        ProductRepository.instance,
        SellerOrderController.instance,
      ]),
      builder: (context, _) {
        final user = AuthController.instance.current;

        if (user == null || user.role != UserRole.penjual) {
          return Scaffold(
            appBar: AppBar(title: const Text('Dashboard Penjual')),
            body: const EmptyState(
              icon: Icons.lock_outline_rounded,
              title: 'Khusus akun penjual',
              message:
                  'Masuk atau daftar sebagai Penjual / Mitra untuk membuka dashboard.',
            ),
          );
        }

        final products = ProductRepository.instance.ownedBy(user.email);
        final orders = SellerOrderController.instance.forSeller(user.email);

        final newOrders =
            orders.where((o) => o.status == SellerOrderStatus.baru).toList();
        final listedCount = products.where((p) => p.isListed).length;
        final lowStock = products.where((p) => p.stock <= kLowStock).toList()
          ..sort((a, b) => a.stock.compareTo(b.stock));

        final now = DateTime.now();
        final start = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 29));
        final revenue = orders
            .where((o) =>
                o.status == SellerOrderStatus.selesai &&
                !DateTime(o.date.year, o.date.month, o.date.day)
                    .isBefore(start))
            .fold<int>(0, (sum, o) => sum + o.subtotal);

        return Scaffold(
          appBar: AppBar(title: const Text('Dashboard Penjual')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Text(
                'Halo, ${user.name}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              const Text(
                'Ringkasan tokomu',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),

              // ---------- Statistik ----------
              Row(
                children: [
                  Expanded(
                    child: SellerStatTile(
                      icon: Icons.mark_email_unread_outlined,
                      value: '${newOrders.length}',
                      label: 'Pesanan baru',
                      accent: newOrders.isNotEmpty,
                      onTap: () => _push(
                        context,
                        const SellerOrdersScreen(initial: SellerOrderStatus.baru),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SellerStatTile(
                      icon: Icons.storefront_outlined,
                      value: '$listedCount',
                      label: 'Produk tampil',
                      onTap: () =>
                          _push(context, const SellerProductsScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SellerStatTile(
                      icon: Icons.payments_outlined,
                      value: formatRupiah(revenue),
                      label: 'Pendapatan 30 hari',
                      onTap: () =>
                          _push(context, const SellerReportScreen()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SellerStatTile(
                      icon: Icons.warning_amber_rounded,
                      value: '${lowStock.length}',
                      label: 'Stok menipis',
                      accent: lowStock.isNotEmpty,
                      onTap: () => _push(
                        context,
                        const SellerProductsScreen(showLowStock: true),
                      ),
                    ),
                  ),
                ],
              ),

              // ---------- Menu cepat ----------
              const SellerSectionTitle('Menu cepat'),
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.add_box_outlined,
                      label: 'Tambah produk',
                      onTap: () =>
                          _push(context, const SellerProductFormScreen()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.inventory_2_outlined,
                      label: 'Kelola produk',
                      onTap: () =>
                          _push(context, const SellerProductsScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.receipt_long_outlined,
                      label: 'Semua pesanan',
                      onTap: () =>
                          _push(context, const SellerOrdersScreen()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.bar_chart_rounded,
                      label: 'Laporan penjualan',
                      onTap: () =>
                          _push(context, const SellerReportScreen()),
                    ),
                  ),
                ],
              ),

              // ---------- Produk kosong ----------
              if (products.isEmpty) ...[
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 36,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Kamu belum punya produk',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tambahkan produk pertama supaya tampil di marketplace.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      PrimaryButton(
                        label: 'Tambah produk pertama',
                        icon: Icons.add_rounded,
                        onPressed: () =>
                            _push(context, const SellerProductFormScreen()),
                      ),
                    ],
                  ),
                ),
              ],

              // ---------- Pesanan baru ----------
              SellerSectionTitle(
                'Pesanan baru',
                actionLabel: 'Lihat semua',
                onAction: () => _push(context, const SellerOrdersScreen()),
              ),
              if (newOrders.isEmpty)
                const AppCard(
                  child: Text(
                    'Tidak ada pesanan baru.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              else
                for (final o in newOrders.take(3)) ...[
                  _NewOrderTile(
                    order: o,
                    onTap: () => _push(
                      context,
                      SellerOrderDetailScreen(orderId: o.id),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

              // ---------- Stok menipis ----------
              SellerSectionTitle(
                'Stok menipis',
                actionLabel: 'Kelola',
                onAction: () => _push(
                  context,
                  const SellerProductsScreen(showLowStock: true),
                ),
              ),
              if (lowStock.isEmpty)
                const AppCard(
                  child: Text(
                    'Semua stok aman.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              else
                AppCard(
                  child: Column(
                    children: [
                      for (var i = 0; i < lowStock.take(4).length; i++) ...[
                        if (i > 0) const Divider(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                lowStock[i].name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              lowStock[i].stock == 0
                                  ? 'Habis'
                                  : 'Sisa ${lowStock[i].stock}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: lowStock[i].stock == 0
                                    ? AppColors.danger
                                    : AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

              const SizedBox(height: 16),
              const Text(
                'Data pesanan adalah contoh untuk demo. Pesanan dari pembeli belum masuk otomatis ke dashboard karena belum ada backend.',
                style: TextStyle(
                  fontSize: 11,
                  height: 1.4,
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

// ======================= Komponen lokal =======================

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 26, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _NewOrderTile extends StatelessWidget {
  const _NewOrderTile({required this.order, required this.onTap});

  final SellerOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${order.id} • ${order.buyerName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${order.itemCount} produk • ${order.buyerCity}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatRupiah(order.total),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}