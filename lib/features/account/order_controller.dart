import 'package:flutter/foundation.dart';
import '../../models/order_record.dart';
import 'auth_controller.dart';

/// Riwayat pesanan lokal (di memori). Dua pesanan awal hanyalah CONTOH demo
/// untuk akun pembeli demo.
class OrderController extends ChangeNotifier {
  OrderController._() {
    _orders.addAll([
      OrderRecord(
        id: 'EH-CONTOH-01',
        ownerEmail: AuthController.demoBuyerEmail,
        date: DateTime(2026, 10, 18),
        shipping: 10000,
        status: OrderStatus.selesai,
        lines: const [
          OrderLine(
            name: 'Kompos Organik Premium',
            unit: 'karung 5 kg',
            qty: 2,
            price: 45000,
            productId: 'p1',
          ),
        ],
      ),
      OrderRecord(
        id: 'EH-CONTOH-02',
        ownerEmail: AuthController.demoBuyerEmail,
        date: DateTime(2026, 10, 27),
        shipping: 10000,
        status: OrderStatus.dikirim,
        lines: const [
          OrderLine(
            name: 'Maggot BSF Fresh',
            unit: 'kemasan 1 kg',
            qty: 1,
            price: 28000,
            productId: 'p2',
          ),
          OrderLine(
            name: 'Pupuk Organik Cair (POC)',
            unit: 'botol 1 L',
            qty: 1,
            price: 25000,
            productId: 'p5',
          ),
        ],
      ),
    ]);
  }

  static final OrderController instance = OrderController._();

  final List<OrderRecord> _orders = [];

  /// Terbaru di atas.
  List<OrderRecord> forUser(String email) {
    final list = _orders.where((o) => o.ownerEmail == email).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  OrderRecord? byId(String id) {
    for (final o in _orders) {
      if (o.id == id) return o;
    }
    return null;
  }

  String newId() => 'EH-${DateTime.now().millisecondsSinceEpoch}';

  void add(OrderRecord order) {
    _orders.add(order);
    notifyListeners();
  }

  void updateStatus(String id, OrderStatus status) {
    final i = _orders.indexWhere((o) => o.id == id);
    if (i < 0) return;
    _orders[i] = _orders[i].copyWith(status: status);
    notifyListeners();
  }
}