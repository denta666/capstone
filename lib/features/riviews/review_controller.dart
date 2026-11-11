import 'package:flutter/foundation.dart';
import '../../data/product_repository.dart';
import '../../models/product_review.dart';

DateTime _daysAgo(int days) {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day).subtract(Duration(days: days));
}

/// Ulasan produk (lokal, di memori). Ulasan awal dengan id "rv-contoh" hanyalah
/// CONTOH demo, bukan ulasan pembeli sungguhan.
class ReviewController extends ChangeNotifier {
  ReviewController._() {
    _reviews.addAll([
      ProductReview(
        id: 'rv-contoh-1',
        productId: 'p1',
        orderId: 'CONTOH',
        authorEmail: 'contoh1@ecohome.id',
        authorName: 'Rina Wulandari',
        rating: 5,
        comment:
            'Kompos remah dan tidak berbau menyengat. Cocok untuk tanaman di pot.',
        date: _daysAgo(6),
      ),
      ProductReview(
        id: 'rv-contoh-2',
        productId: 'p1',
        orderId: 'CONTOH',
        authorEmail: 'contoh2@ecohome.id',
        authorName: 'Budi Santoso',
        rating: 4,
        comment: 'Kemasan rapi dan pengiriman cepat. Semoga stoknya selalu ada.',
        date: _daysAgo(14),
      ),
      ProductReview(
        id: 'rv-contoh-3',
        productId: 'p2',
        orderId: 'CONTOH',
        authorEmail: 'contoh3@ecohome.id',
        authorName: 'Siti Aminah',
        rating: 5,
        comment: 'Maggot segar dan aktif. Pakan ayam jadi lebih hemat.',
        date: _daysAgo(9),
      ),
      ProductReview(
        id: 'rv-contoh-4',
        productId: 'p2',
        orderId: 'CONTOH',
        authorEmail: 'contoh4@ecohome.id',
        authorName: 'Agus Pratama',
        rating: 4,
        comment: 'Ukuran larva seragam dan packing aman.',
        date: _daysAgo(21),
      ),
      ProductReview(
        id: 'rv-contoh-5',
        productId: 'p4',
        orderId: 'CONTOH',
        authorEmail: 'contoh5@ecohome.id',
        authorName: 'Dewi Lestari',
        rating: 5,
        comment: 'Cocok untuk tanaman sayur di kebun belakang rumah.',
        date: _daysAgo(11),
      ),
    ]);
  }

  static final ReviewController instance = ReviewController._();

  final List<ProductReview> _reviews = [];

  /// Terbaru di atas.
  List<ProductReview> forProduct(String productId) {
    final list = _reviews.where((r) => r.productId == productId).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  bool hasReviewed({
    required String email,
    required String orderId,
    required String productId,
  }) {
    return _reviews.any(
      (r) =>
          r.authorEmail == email &&
          r.orderId == orderId &&
          r.productId == productId,
    );
  }

  String newId() => 'rv-${DateTime.now().microsecondsSinceEpoch}';

  /// Mengembalikan pesan error, atau null kalau berhasil.
  String? add(ProductReview r) {
    if (r.rating < 1 || r.rating > 5) return 'Pilih rating 1 sampai 5';
    if (hasReviewed(
      email: r.authorEmail,
      orderId: r.orderId,
      productId: r.productId,
    )) {
      return 'Kamu sudah mengulas produk ini untuk pesanan tersebut';
    }
    _reviews.add(r);
    ProductRepository.instance.applyReview(r.productId, r.rating);
    notifyListeners();
    return null;
  }
}