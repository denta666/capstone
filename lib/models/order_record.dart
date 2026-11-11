enum OrderStatus { menungguPembayaran, diproses, dikirim, selesai, dibatalkan }

extension OrderStatusX on OrderStatus {
  String get label => switch (this) {
        OrderStatus.menungguPembayaran => 'Menunggu pembayaran',
        OrderStatus.diproses => 'Diproses',
        OrderStatus.dikirim => 'Dikirim',
        OrderStatus.selesai => 'Selesai',
        OrderStatus.dibatalkan => 'Dibatalkan',
      };
}

/// Metode pembayaran yang dipilih pembeli di checkout. Metode online
/// (bukan COD) dibayar lewat gateway; COD dibayar saat pesanan diterima.
enum PaymentMethod { transferBank, eWallet, qris, cod }

extension PaymentMethodX on PaymentMethod {
  String get label => switch (this) {
        PaymentMethod.transferBank => 'Transfer bank (Virtual Account)',
        PaymentMethod.eWallet => 'Dompet digital (e-wallet)',
        PaymentMethod.qris => 'QRIS',
        PaymentMethod.cod => 'Bayar di tempat (COD)',
      };

  /// Dibayar lewat gateway pembayaran.
  bool get isOnline => this != PaymentMethod.cod;
}

class ShippingAddress {
  const ShippingAddress({
    required this.recipient,
    required this.phone,
    this.address = '',
    this.city = '',
  });

  final String recipient;
  final String phone;

  /// Kosong kalau pesanan diambil sendiri.
  final String address;
  final String city;

  String get summary {
    final place = [address, city].where((s) => s.isNotEmpty).join(', ');
    return place.isEmpty ? '$recipient ($phone)' : '$recipient ($phone) - $place';
  }
}

class OrderLine {
  const OrderLine({
    required this.productId,
    required this.name,
    required this.unit,
    required this.qty,
    required this.price,
  });

  /// Id produk di [Product.id], untuk menghubungkan baris pesanan ke produk.
  final String productId;
  final String name;
  final String unit;
  final int qty;
  final int price;

  int get total => qty * price;
}

class OrderRecord {
  const OrderRecord({
    required this.id,
    required this.ownerEmail,
    required this.date,
    required this.lines,
    required this.shipping,
    required this.status,
    this.address,
    this.courier,
    this.method,
    this.note,
  });

  final String id;
  final String ownerEmail;
  final DateTime date;
  final List<OrderLine> lines;
  final int shipping;
  final OrderStatus status;

  /// Data checkout. Null untuk pesanan contoh (demo) yang dibuat sebelum
  /// ada layar checkout.
  final ShippingAddress? address;
  final String? courier;
  final PaymentMethod? method;
  final String? note;

  int get subtotal => lines.fold(0, (sum, l) => sum + l.total);
  int get total => subtotal + shipping;
  int get itemCount => lines.fold(0, (sum, l) => sum + l.qty);

  OrderRecord copyWith({OrderStatus? status}) {
    return OrderRecord(
      id: id,
      ownerEmail: ownerEmail,
      date: date,
      lines: lines,
      shipping: shipping,
      status: status ?? this.status,
      address: address,
      courier: courier,
      method: method,
      note: note,
    );
  }
}