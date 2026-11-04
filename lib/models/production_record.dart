enum ProductionType { kompos, maggot }

enum ProductionStatus { berjalan, selesai, gagal }

extension ProductionTypeX on ProductionType {
  String get label =>
      this == ProductionType.kompos ? 'Kompos' : 'Maggot BSF';
}

extension ProductionStatusX on ProductionStatus {
  String get label => switch (this) {
        ProductionStatus.berjalan => 'Berjalan',
        ProductionStatus.selesai => 'Selesai',
        ProductionStatus.gagal => 'Gagal',
      };
}

class ProductionRecord {
  const ProductionRecord({
    required this.id,
    required this.type,
    required this.startDate,
    required this.material,
    required this.inputKg,
    required this.cost,
    required this.notes,
    required this.hasPhoto,
    required this.status,
    this.yieldKg,
  });

  final String id;
  final ProductionType type;
  final DateTime startDate;
  final String material;
  final double inputKg;
  final int cost; // rupiah
  final String notes;
  final bool hasPhoto;
  final double? yieldKg;
  final ProductionStatus status;

  /// Hasil dibagi bahan masuk, dalam persen. Null kalau hasil belum diisi.
  double? get efficiency {
    final y = yieldKg;
    if (y == null || inputKg <= 0) return null;
    return y / inputKg * 100;
  }

  /// Biaya dibagi berat hasil. Null kalau hasil belum diisi.
  int? get costPerKg {
    final y = yieldKg;
    if (y == null || y <= 0) return null;
    return (cost / y).round();
  }
}