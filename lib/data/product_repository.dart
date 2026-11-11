import 'package:flutter/foundation.dart';
import '../features/account/auth_controller.dart';
import '../models/product.dart';
import 'dummy_data.dart';

/// Daftar produk marketplace (lokal, di memori). Berawal dari data contoh;
/// empat produk contoh dimiliki akun penjual demo.
class ProductRepository extends ChangeNotifier {
  ProductRepository._() {
    for (final p in DummyData.products) {
      if (_demoOwned.contains(p.id)) {
        _items.add(
          p.copyWith(
            ownerEmail: AuthController.demoSellerEmail,
            seller: 'Mitra Demo',
          ),
        );
      } else {
        _items.add(p);
      }
    }
  }

  static final ProductRepository instance = ProductRepository._();

  static const Set<String> _demoOwned = {'p1', 'p2', 'p3', 'p6'};

  final List<Product> _items = [];

  /// Yang tampil di marketplace: aktif dan stok > 0.
  List<Product> get visible => _items.where((p) => p.isListed).toList();

  List<Product> get featured => visible.take(6).toList();

  List<Product> ownedBy(String email) =>
      _items.where((p) => p.ownerEmail == email).toList();

  Product? byId(String id) {
    for (final p in _items) {
      if (p.id == id) return p;
    }
    return null;
  }

  String newId() => 'u${DateTime.now().microsecondsSinceEpoch}';

  void add(Product p) {
    _items.add(p);
    notifyListeners();
  }

  void update(Product p) {
    final i = _items.indexWhere((e) => e.id == p.id);
    if (i < 0) return;
    _items[i] = p;
    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void setStock(String id, int stock) {
    final i = _items.indexWhere((e) => e.id == id);
    if (i < 0) return;
    _items[i] = _items[i].copyWith(stock: stock < 0 ? 0 : stock);
    notifyListeners();
  }

  void setActive(String id, bool active) {
    final i = _items.indexWhere((e) => e.id == id);
    if (i < 0) return;
    _items[i] = _items[i].copyWith(isActive: active);
    notifyListeners();
  }

  /// Memperbarui rating rata-rata dan jumlah ulasan setelah ada ulasan baru.
  void applyReview(String productId, int stars) {
    final i = _items.indexWhere((e) => e.id == productId);
    if (i < 0) return;
    final p = _items[i];
    final n = p.reviews + 1;
    final avg = (p.rating * p.reviews + stars) / n;
    _items[i] = p.copyWith(rating: avg, reviews: n);
    notifyListeners();
  }
}