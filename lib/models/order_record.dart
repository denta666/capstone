enum OrderStatus { diproses, dikirim, selesai }

extension OrderStatusX on OrderStatus {
  String get label => switch (this) {
        OrderStatus.diproses => 'Diproses',
        OrderStatus.dikirim => 'Dikirim',
        OrderStatus.selesai => 'Selesai',
      };
}

class OrderLine {
  const OrderLine({
    required this.name,
    required this.unit,
    required this.qty,
    required this.price,
  });

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
}