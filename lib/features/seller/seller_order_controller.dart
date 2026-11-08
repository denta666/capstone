import 'package:flutter/foundation.dart';
import '../../models/seller_order.dart';
import '../account/auth_controller.dart';

class SellerOrderController extends ChangeNotifier {
  SellerOrderController._() {
    final today = DateTime.now();
    _orders.addAll([
      SellerOrder(
        id: 'EH-MITRA-001',
        sellerEmail: AuthController.demoSellerEmail,
        buyerName: 'Ayu Pratiwi',
        buyerCity: 'Kota Bandung',
        date: today.subtract(const Duration(days: 1)),
        shipping: 10000,
        status: SellerOrderStatus.baru,
        lines: const [
          SellerOrderLine(
            name: 'Kompos Organik Premium',
            unit: 'karung 5 kg',
            qty: 2,
            price: 45000,
          ),
        ],
      ),
      SellerOrder(
        id: 'EH-MITRA-002',
        sellerEmail: AuthController.demoSellerEmail,
        buyerName: 'Rizky Maulana',
        buyerCity: 'Kab. Tegal',
        date: today.subtract(const Duration(days: 3)),
        shipping: 12000,
        status: SellerOrderStatus.selesai,
        lines: const [
          SellerOrderLine(
            name: 'Maggot BSF Fresh',
            unit: 'kemasan 1 kg',
            qty: 2,
            price: 28000,
          ),
        ],
      ),
    ]);
  }

  static final SellerOrderController instance = SellerOrderController._();

  final List<SellerOrder> _orders = [];

  List<SellerOrder> forSeller(String email) {
    final result = _orders.where((order) => order.sellerEmail == email).toList();
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  SellerOrder? byId(String id) {
    for (final order in _orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  void updateStatus(String id, SellerOrderStatus status) {
    final index = _orders.indexWhere((order) => order.id == id);
    if (index < 0) return;
    _orders[index] = _orders[index].copyWith(status: status);
    notifyListeners();
  }
}