class ProductReview {
  const ProductReview({
    required this.id,
    required this.productId,
    required this.orderId,
    required this.authorEmail,
    required this.authorName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  final String id;
  final String productId;
  final String orderId;
  final String authorEmail;
  final String authorName;
  final int rating; // 1 - 5
  final String comment;
  final DateTime date;
}

/// "Denta Adi Ramadhani" -> "Denta A."
String maskedName(String name) {
  final parts =
      name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return 'Pengguna';
  if (parts.length == 1) return parts.first;
  return '${parts.first} ${parts[1][0].toUpperCase()}.';
}