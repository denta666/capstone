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

class OrderLine {
  const OrderLine({
    required this.name,
    required this.unit,
    required this.qty,
    required this.price,
    this.productId,
  });

  final String name;
  final String unit;
  final int qty;
  final int price;

  /// Id produk di katalog (dipakai untuk ulasan). Null untuk data lama.
  final String? productId;

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
  });

  final String id;
  final String ownerEmail;
  final DateTime date;
  final List<OrderLine> lines;
  final int shipping;
  final OrderStatus status;

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
    );
  }
}