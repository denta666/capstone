import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/product_card.dart';
import '../../data/dummy_data.dart';
import '../../models/product.dart';
import '../../navigation/app_navigation.dart';
import '../cart/cart_button.dart';
import 'product_detail_screen.dart';

enum SortOption { relevan, termurah, termahal, rating }

enum PriceFilter { semua, murah, sedang, mahal }

const _sortLabels = {
  SortOption.relevan: 'Paling relevan',
  SortOption.termurah: 'Harga terendah',
  SortOption.termahal: 'Harga tertinggi',
  SortOption.rating: 'Rating tertinggi',
};

const _priceLabels = {
  PriceFilter.semua: 'Semua harga',
  PriceFilter.murah: '< Rp30.000',
  PriceFilter.sedang: 'Rp30.000 - 60.000',
  PriceFilter.mahal: '> Rp60.000',
};

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _category; // null = semua
  SortOption _sort = SortOption.relevan;
  PriceFilter _price = PriceFilter.semua;

  @override
  void initState() {
    super.initState();
    marketplaceCategoryFilter.addListener(_onExternalCategory);
  }

  @override
  void dispose() {
    marketplaceCategoryFilter.removeListener(_onExternalCategory);
    _searchController.dispose();
    super.dispose();
  }

  /// Dipanggil saat kategori di Beranda diketuk.
  void _onExternalCategory() {
    final c = marketplaceCategoryFilter.value;
    if (c == null) return;
    setState(() => _category = c);
    marketplaceCategoryFilter.value = null;
  }

  List<Product> get _results {
    final q = _query.trim().toLowerCase();

    final list = DummyData.products.where((p) {
      final matchQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
      final matchCategory = _category == null || p.category == _category;
      final matchPrice = switch (_price) {
        PriceFilter.semua => true,
        PriceFilter.murah => p.price < 30000,
        PriceFilter.sedang => p.price >= 30000 && p.price <= 60000,
        PriceFilter.mahal => p.price > 60000,
      };
      return matchQuery && matchCategory && matchPrice;
    }).toList();

    switch (_sort) {
      case SortOption.relevan:
        break;
      case SortOption.termurah:
        list.sort((a, b) => a.price.compareTo(b.price));
      case SortOption.termahal:
        list.sort((a, b) => b.price.compareTo(a.price));
      case SortOption.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return list;
  }

  int get _activeFilterCount =>
      (_price != PriceFilter.semua ? 1 : 0) +
      (_sort != SortOption.relevan ? 1 : 0);

  void _resetAll() {
    _searchController.clear();
    setState(() {
      _query = '';
      _category = null;
      _sort = SortOption.relevan;
      _price = PriceFilter.semua;
    });
  }

  void _open(Product p) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)),
    );
  }

  OutlineInputBorder get _border => OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      );

  Widget _choice(String label, bool selected, VoidCallback onTap) {
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

  void _openFilter() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            void update(VoidCallback fn) {
              setState(fn);
              setSheet(() {});
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Urutkan',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final s in SortOption.values)
                          _choice(
                            _sortLabels[s]!,
                            _sort == s,
                            () => update(() => _sort = s),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Rentang harga',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final f in PriceFilter.values)
                          _choice(
                            _priceLabels[f]!,
                            _price == f,
                            () => update(() => _price = f),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            label: 'Reset',
                            outlined: true,
                            onPressed: () => update(() {
                              _sort = SortOption.relevan;
                              _price = PriceFilter.semua;
                            }),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PrimaryButton(
                            label: 'Terapkan',
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    final categories = ['Semua', ...DummyData.categories.map((c) => c.name)];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: const [CartButton(), SizedBox(width: 20)],
      ),
      body: Column(
        children: [
          // ---------- Pencarian + tombol filter ----------
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Cari produk...',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                            ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: _border,
                      enabledBorder: _border,
                      focusedBorder: _border.copyWith(
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _openFilter,
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: Center(
                        child: Badge(
                          label: Text('$_activeFilterCount'),
                          isLabelVisible: _activeFilterCount > 0,
                          backgroundColor: AppColors.primary,
                          child: const Icon(
                            Icons.tune_rounded,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ---------- Chip kategori ----------
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final name = categories[i];
                final selected =
                    i == 0 ? _category == null : _category == name;
                return _choice(
                  name,
                  selected,
                  () => setState(() => _category = i == 0 ? null : name),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${results.length} produk ditemukan',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),

          // ---------- Grid produk ----------
          Expanded(
            child: results.isEmpty
                ? EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'Produk tidak ditemukan',
                    message: 'Coba kata kunci lain atau reset filter.',
                    actionLabel: 'Reset filter',
                    onAction: _resetAll,
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 230,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.66,
                    ),
                    itemCount: results.length,
                    itemBuilder: (context, i) => ProductCard(
                      product: results[i],
                      onTap: () => _open(results[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}