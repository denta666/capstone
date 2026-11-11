import '../../models/order_record.dart';

/// Hasil pembayaran, mengikuti status transaksi di Midtrans:
/// settlement = berhasil, pending = menunggu, deny = ditolak,
/// cancel = dibatalkan, expire = kedaluwarsa.
enum PaymentResult { settlement, pending, denied, cancelled, expired }

class PaymentSession {
  const PaymentSession({
    required this.orderId,
    required this.token,
    this.redirectUrl,
  });

  final String orderId;

  /// Snap token dari backend (di versi simulasi: kode palsu).
  final String token;

  /// URL halaman pembayaran Snap (null di versi simulasi).
  final String? redirectUrl;
}

/// Kontrak layanan pembayaran. Aplikasi hanya bergantung pada kelas ini,
/// jadi saat backend Midtrans siap, cukup ganti implementasinya.
///
/// Implementasi sungguhan (Midtrans Snap) membutuhkan backend, karena Server
/// Key TIDAK boleh ada di dalam aplikasi. Alurnya:
///  1. Aplikasi mengirim pesanan (id, item, total, [OrderRecord.method]) ke
///     backend.
///  2. Backend memanggil Snap API dengan Server Key dan mengembalikan token
///     dan redirect_url (diisi ke [PaymentSession]).
///  3. Aplikasi membuka halaman Snap (WebView atau browser).
///  4. Status akhir (settlement, pending, deny, cancel, expire) dibaca dari
///     backend, yang menerimanya lewat webhook Midtrans. Jangan percaya
///     status dari aplikasi saja.
abstract class PaymentService {
  Future<PaymentSession> createSession(OrderRecord order);
}

/// SIMULASI: tidak menghubungi Midtrans sama sekali.
class MockPaymentService implements PaymentService {
  @override
  Future<PaymentSession> createSession(OrderRecord order) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return PaymentSession(orderId: order.id, token: 'SIMULASI-${order.id}');
  }
}

class PaymentConfig {
  PaymentConfig._();

  /// Ganti dengan layanan sungguhan (yang memanggil backend) di Tahap 10B.
  static PaymentService service = MockPaymentService();
}