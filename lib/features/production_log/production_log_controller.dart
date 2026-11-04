import 'package:flutter/foundation.dart';
import '../../models/production_record.dart';

/// Catatan produksi lokal (di memori). Tiga data awal hanyalah CONTOH demo.
class ProductionLogController extends ChangeNotifier {
  ProductionLogController._();
  static final ProductionLogController instance = ProductionLogController._();

  final List<ProductionRecord> _items = [
    ProductionRecord(
      id: 'contoh1',
      type: ProductionType.kompos,
      startDate: DateTime(2026, 9, 14),
      material: 'Sisa sayur dan daun kering',
      inputKg: 20,
      cost: 15000,
      notes: 'Contoh data demo.',
      hasPhoto: false,
      yieldKg: 8,
      status: ProductionStatus.selesai,
    ),
    ProductionRecord(
      id: 'contoh2',
      type: ProductionType.maggot,
      startDate: DateTime(2026, 10, 12),
      material: 'Sisa makanan rumah tangga',
      inputKg: 30,
      cost: 40000,
      notes: 'Contoh data demo.',
      hasPhoto: true,
      status: ProductionStatus.berjalan,
    ),
    ProductionRecord(
      id: 'contoh3',
      type: ProductionType.kompos,
      startDate: DateTime(2026, 10, 20),
      material: 'Kulit buah dan sayur',
      inputKg: 12,
      cost: 10000,
      notes: 'Contoh data demo.',
      hasPhoto: false,
      status: ProductionStatus.berjalan,
    ),
  ];

  /// Terbaru di atas.
  List<ProductionRecord> get items {
    final list = [..._items];
    list.sort((a, b) => b.startDate.compareTo(a.startDate));
    return list;
  }

  int countOf(ProductionStatus s) => _items.where((e) => e.status == s).length;

  double get totalInputKg => _items.fold(0.0, (sum, e) => sum + e.inputKg);

  double get totalYieldKg => _items
      .where((e) => e.status == ProductionStatus.selesai)
      .fold(0.0, (sum, e) => sum + (e.yieldKg ?? 0));

  String newId() => 'r${DateTime.now().microsecondsSinceEpoch}';

  /// Tambah baru, atau perbarui kalau id sudah ada.
  void save(ProductionRecord r) {
    final i = _items.indexWhere((e) => e.id == r.id);
    if (i >= 0) {
      _items[i] = r;
    } else {
      _items.add(r);
    }
    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}