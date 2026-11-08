import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/product_repository.dart';
import '../../models/product.dart';
import '../account/auth_controller.dart';
import 'seller_product_form_screen.dart';

class SellerProductsScreen extends StatelessWidget {
  const SellerProductsScreen({super.key, this.showLowStock = false});

  final bool showLowStock;

  @override
  Widget build(BuildContext context) {
    final email = AuthController.instance.current?.email ?? '';
    return ListenableBuilder(
      listenable: ProductRepository.instance,
      builder: (context, _) {
        final products = ProductRepository.instance.ownedBy(email).where((product) =>
            !showLowStock || product.stock <= 5).toList();
        return Scaffold(
          appBar: AppBar(title: Text(showLowStock ? 'Stok Menipis' : 'Kelola Produk')),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const SellerProductFormScreen(),
            )),
            child: const Icon(Icons.add_rounded),
          ),
          body: products.isEmpty
              ? EmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: showLowStock ? 'Tidak ada stok menipis' : 'Belum ada produk',
                  message: showLowStock ? 'Stok produkmu masih aman.' : 'Tambahkan produk untuk mulai mengelola tokomu.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 90),
                  itemCount: products.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _ProductTile(product: products[index]),
                ),
        );
      },
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) => AppCard(
        child: Row(
          children: [
            CircleAvatar(backgroundColor: AppColors.primarySoft, child: Icon(product.icon, color: AppColors.primary)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text('${formatRupiah(product.price)} • Stok ${product.stock}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ]),
            ),
            PopupMenuButton<String>(
              onSelected: (action) {
                if (action == 'edit') {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => SellerProductFormScreen(product: product),
                  ));
                } else if (action == 'toggle') {
                  ProductRepository.instance.update(product.copyWith(isActive: !product.isActive));
                } else if (action == 'delete') {
                  ProductRepository.instance.remove(product.id);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Ubah')),
                PopupMenuItem(value: 'toggle', child: Text(product.isActive ? 'Nonaktifkan' : 'Aktifkan')),
                const PopupMenuItem(value: 'delete', child: Text('Hapus')),
              ],
            ),
          ],
        ),
      );
}