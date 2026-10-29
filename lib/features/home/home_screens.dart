import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/category_item.dart';
import '../../core/widgets/product_card.dart';
import '../../data/dummy_data.dart';
import '../../navigation/app_navigation.dart';
import '../cart/cart_button.dart';
import '../marketplace/product_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _userName = 'Denta'; // dummy

  void _info(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final featured = DummyData.featured;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            // ---------- Header ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat datang,',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Halo, $_userName 👋',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _RoundIconButton(
                    icon: Icons.notifications_none_rounded,
                    onTap: () => _info(context, 'Belum ada notifikasi baru'),
                  ),
                  const SizedBox(width: 8),
                  const CartButton(),
                ],
              ),
            ),

            // ---------- Pencarian ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Material(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => mainTabIndex.value = 1,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded,
                            color: AppColors.textSecondary),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Cari kompos, maggot BSF, pupuk...',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ---------- Banner ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, Color(0xFF0F5C33)],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Marketplace EcoHome',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Ubah Sampah Organik Jadi Nilai Ekonomi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => mainTabIndex.value = 1,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: const Text('Belanja Sekarang'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.recycling_rounded,
                      size: 72,
                      color: Colors.white24,
                    ),
                  ],
                ),
              ),
            ),

            // ---------- Kategori ----------
            const _SectionHeader(title: 'Kategori'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final c in DummyData.categories)
                    CategoryItem(
                      icon: c.icon,
                      label: c.name,
                      onTap: () {marketplaceCategoryFilter.value = c.name;mainTabIndex.value = 1;
            },
                    ),
                ],
              ),
            ),

            // ---------- Produk unggulan ----------
            _SectionHeader(
              title: 'Produk unggulan',
              actionLabel: 'Lihat semua',
              onAction: () => mainTabIndex.value = 1,
            ),
            SizedBox(
              height: 252,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: featured.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final p = featured[i];
                  return SizedBox(
                    width: 160,
                    child: ProductCard(
                      product: p,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: p),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ---------- Pintasan Mulai Produksi ----------
            const _SectionHeader(title: 'Mulai produksi sendiri'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _ShortcutCard(
                icon: Icons.spa_rounded,
                title: 'Mulai Produksi',
                subtitle:
                    'Belajar membuat kompos dan budidaya maggot BSF dari nol',
                onTap: () => mainTabIndex.value = 2,
              ),
            ),

            // ---------- Rekomendasi pengolahan ----------
            const _SectionHeader(title: 'Rekomendasi pengolahan sampah'),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AppCard(
                child: Column(
                  children: [
                    _RecommendationRow(
                      icon: Icons.grass_rounded,
                      material: 'Sisa sayur dan daun kering',
                      result: 'Umumnya cocok untuk kompos',
                    ),
                    Divider(height: 24),
                    _RecommendationRow(
                      icon: Icons.bug_report_rounded,
                      material: 'Sisa makanan',
                      result: 'Umumnya cocok untuk pakan maggot BSF',
                    ),
                    Divider(height: 24),
                    _RecommendationRow(
                      icon: Icons.water_drop_rounded,
                      material: 'Kulit buah',
                      result: 'Umumnya cocok untuk pupuk cair atau eco-enzyme',
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Text(
                'Rekomendasi bersifat umum. Metode dan parameter produksi bisa berbeda, ikuti panduan di menu Produksi.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ),

            // ---------- Pintasan EcoBot ----------
            const _SectionHeader(title: 'Butuh bantuan?'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _ShortcutCard(
                icon: Icons.smart_toy_rounded,
                title: 'Tanya EcoBot',
                subtitle:
                    'Bau kompos, pakan maggot, sampai cara menjual hasil produksi',
                onTap: () => mainTabIndex.value = 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= Komponen lokal =======================

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          height: 44,
          width: 44,
          child: Icon(icon, size: 22, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 26, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
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
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _RecommendationRow extends StatelessWidget {
  const _RecommendationRow({
    required this.icon,
    required this.material,
    required this.result,
  });

  final IconData icon;
  final String material;
  final String result;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                material,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                result,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}