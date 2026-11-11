import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/order_record.dart';
import 'payment_service.dart';

/// Halaman pembayaran SIMULASI (menggantikan halaman Midtrans Snap).
/// Mengembalikan [PaymentResult] lewat Navigator.pop. Ditutup tanpa hasil
/// (tombol X atau kembali) berarti pembayaran belum diselesaikan.
class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key, required this.order, required this.session});

  final OrderRecord order;
  final PaymentSession session;

  void _finish(BuildContext context, PaymentResult r) =>
      Navigator.of(context).pop(r);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warningSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.science_outlined, color: AppColors.warning),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Ini SIMULASI halaman pembayaran (pengganti Midtrans Snap). Tidak ada uang sungguhan dan tidak ada koneksi ke Midtrans.',
                    style: TextStyle(fontSize: 12.5, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.id,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Kode sesi: ${session.token}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (order.method != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Metode dipilih: ${order.method!.label}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const Divider(height: 22),
                for (final l in order.lines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${l.qty} x ${l.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Text(
                          formatRupiah(l.total),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Ongkos kirim',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      formatRupiah(order.shipping),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 22),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Total bayar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      formatRupiah(order.total),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),
          const Text(
            'Pilih hasil simulasi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            'Di Midtrans sungguhan, pembeli memilih metode (transfer bank, e-wallet, dan lainnya sesuai pengaturan akun merchant), lalu status dikirim ke server.',
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: 'Pembayaran berhasil',
            icon: Icons.check_circle_outline_rounded,
            onPressed: () => _finish(context, PaymentResult.settlement),
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'Menunggu pembayaran (pending)',
            icon: Icons.schedule_rounded,
            outlined: true,
            onPressed: () => _finish(context, PaymentResult.pending),
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'Pembayaran ditolak',
            icon: Icons.block_rounded,
            outlined: true,
            onPressed: () => _finish(context, PaymentResult.denied),
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'Kedaluwarsa',
            icon: Icons.timer_off_outlined,
            outlined: true,
            onPressed: () => _finish(context, PaymentResult.expired),
          ),
          const SizedBox(height: 14),
          const Text(
            'Menutup halaman ini (tombol X) berarti pembayaran belum selesai. Pesanan tetap berstatus Menunggu pembayaran dan bisa dilanjutkan dari Riwayat transaksi.',
            style: TextStyle(fontSize: 11, height: 1.4, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}