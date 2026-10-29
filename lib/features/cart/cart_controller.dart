import 'package:flutter/foundation.dart';
import '../../models/product.dart';

class CartLine {
  CartLine({required this.product, required this.qty});

  final Product product;
  int qty;

  int get total => product.price * qty;
}

/// Keranjang lokal (hanya di memori, hilang saat aplikasi ditutup).
class CartController extends ChangeNotifier {
  CartController._();
  static final CartController instance = CartController._();

  final Map<String, CartLine> _lines = {};

  List<CartLine> get lines => _lines.values.toList();
  bool get isEmpty => _lines.isEmpty;

  int get totalItems => _lines.values.fold(0, (sum, l) => sum + l.qty);
  int get subtotal => _lines.values.fold(0, (sum, l) => sum + l.total);

  /// Mengembalikan false kalau jumlahnya terpotong oleh batas stok.
  bool add(Product p, {int qty = 1}) {
    final current = _lines[p.id]?.qty ?? 0;
    final wanted = current + qty;
    final next = wanted > p.stock ? p.stock : wanted;
    if (next <= 0) return false;
    _lines[p.id] = CartLine(product: p, qty: next);
    notifyListeners();
    return wanted <= p.stock;
  }

  bool increment(String id) {
    final line = _lines[id];
    if (line == null || line.qty >= line.product.stock) return false;
    line.qty++;
    notifyListeners();
    return true;
  }

  void decrement(String id) {
    final line = _lines[id];
    if (line == null) return;
    if (line.qty <= 1) {
      _lines.remove(id);
    } else {
      line.qty--;
    }
    notifyListeners();
  }

  void remove(String id) {
    _lines.remove(id);
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    notifyListeners();
  }
}