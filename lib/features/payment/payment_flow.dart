import 'package:flutter/material.dart';
import '../../models/order_record.dart';
import '../account/order_controller.dart';
import 'payment_screen.dart';
import 'payment_service.dart';

/// Menjalankan alur pembayaran satu pesanan: buat sesi, buka halaman
/// pembayaran, lalu perbarui status pesanan sesuai hasilnya.
/// Memakai NavigatorState dan ScaffoldMessengerState (bukan BuildContext)
/// supaya tetap aman dipakai setelah layar pemanggilnya berubah.
Future<void> payOrder({
  required NavigatorState navigator,
  required ScaffoldMessengerState messenger,
  required OrderRecord order,
}) async {
  void say(String text) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  PaymentSession session;
  try {
    session = await PaymentConfig.service.createSession(order);
  } catch (_) {
    say('Gagal membuat sesi pembayaran. Coba lagi dari Riwayat transaksi.');
    return;
  }
  if (!navigator.mounted) return;

  final result = await navigator.push<PaymentResult>(
    MaterialPageRoute(
      builder: (_) => PaymentScreen(order: order, session: session),
    ),
  );

  final orders = OrderController.instance;
  switch (result) {
    case PaymentResult.settlement:
      orders.updateStatus(order.id, OrderStatus.diproses);
      say('Pembayaran berhasil (simulasi). Pesanan diproses.');
    case PaymentResult.pending:
      orders.updateStatus(order.id, OrderStatus.menungguPembayaran);
      say('Menunggu pembayaran (simulasi). Cek di Riwayat transaksi.');
    case PaymentResult.denied:
    case PaymentResult.cancelled:
    case PaymentResult.expired:
      orders.updateStatus(order.id, OrderStatus.dibatalkan);
      say('Pembayaran tidak berhasil (simulasi). Pesanan dibatalkan.');
    case null:
      say('Pembayaran belum selesai. Lanjutkan dari Akun > Riwayat transaksi.');
  }
}