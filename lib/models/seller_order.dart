enum SellerOrderStatus { baru, diproses, dikirim, selesai, dibatalkan }

extension SellerOrderStatusX on SellerOrderStatus {
  String get label => switch (this) {
        SellerOrderStatus.baru => 'Baru',
        SellerOrderStatus.diproses => 'Diproses',
        SellerOrderStatus.dikirim => 'Dikirim',
        SellerOrderStatus.selesai => 'Selesai',
        SellerOrderStatus.dibatalkan => 'Dibatalkan',
      };

  bool get isFinal =>
      this == SellerOrderStatus.selesai || this == SellerOrderStatus.dibatalkan;
}

class SellerOrderLine {
  const SellerOrderLine({
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

class SellerOrder {
  const SellerOrder({
    required this.id,
    required this.sellerEmail,
    required this.buyerName,
    required this.buyerCity,
    required this.date,
    required this.lines,
    required this.shipping,
    required this.status,
  });

  final String id;
  final String sellerEmail;
  final String buyerName;
  final String buyerCity;
  final DateTime date;
  final List<SellerOrderLine> lines;
  final int shipping;
  final SellerOrderStatus status;

  int get subtotal => lines.fold(0, (sum, line) => sum + line.total);
  int get total => subtotal + shipping;
  int get itemCount => lines.fold(0, (sum, line) => sum + line.qty);

  SellerOrder copyWith({SellerOrderStatus? status}) => SellerOrder(
        id: id,
        sellerEmail: sellerEmail,
        buyerName: buyerName,
        buyerCity: buyerCity,
        date: date,
        lines: lines,
        shipping: shipping,
        status: status ?? this.status,
      );
}