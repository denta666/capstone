import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/app_card.dart';
import '../../models/seller_order.dart';
import '../account/auth_controller.dart';
import 'seller_order_controller.dart';
import 'seller_widgets.dart';

enum _Period { tujuh, tigaPuluh }

class _Bar {
  const _Bar(this.label, this.value);

  final String label;
  final int value;
}

class _Agg {
  int qty = 0;
  int revenue = 0;
}

const _hari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

/// 45000 -> "45rb", 1250000 -> "1,3jt", 0 -> "-"
String _compact(int v) {
  if (v <= 0) return '-';
  if (v >= 1000000) {
    return '${(v / 1000000).toStringAsFixed(1).replaceAll('.', ',')}jt';
  }
  if (v >= 1000) return '${(v / 1000).round()}rb';
  return '$v';
}

class SellerReportScreen extends StatefulWidget {
  const SellerReportScreen({super.key});

  @override
  State<SellerReportScreen> createState() => _SellerReportScreenState();
}

class _SellerReportScreenState extends State<SellerReportScreen> {
  _Period _period = _Period.tujuh;

  int get _days => _period == _Period.tujuh ? 7 : 30;

  DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime get _today => _dayOf(DateTime.now());

  List<_Bar> _bars(List<SellerOrder> done) {
    final today = _today;
    final bars = <_Bar>[];

    if (_period == _Period.tujuh) {
      for (var i = 6; i >= 0; i--) {
        final day = today.subtract(Duration(days: i));
        final value = done
            .where((o) => _dayOf(o.date) == day)
            .fold<int>(0, (sum, o) => sum + o.subtotal);
        bars.add(_Bar(_hari[day.weekday - 1], value));
      }
    } else {
      // 6 kelompok, masing-masing 5 hari (kelompok terakhir = terbaru)
      for (var b = 0; b < 6; b++) {
        final ageStart = 5 * (5 - b);
        final ageEnd = ageStart + 4;
        final value = done.where((o) {
          final age = today.difference(_dayOf(o.date)).inDays;
          return age >= ageStart && age <= ageEnd;
        }).fold<int>(0, (sum, o) => sum + o.subtotal);
        final start = today.subtract(Duration(days: ageEnd));
        bars.add(_Bar('${start.day}/${start.month}', value));
      }
    }
    return bars;
  }

  @override
  Widget build(BuildContext context) {
    final email = AuthController.instance.current?.email ?? '';

    return ListenableBuilder(
      listenable: SellerOrderController.instance,
      builder: (context, _) {
        final all = SellerOrderController.instance.forSeller(email);
        final start = _today.subtract(Duration(days: _days - 1));

        final inPeriod =
            all.where((o) => !_dayOf(o.date).isBefore(start)).toList();
        final done =
            inPeriod.where((o) => o.status == SellerOrderStatus.selesai).toList();
        final cancelled = inPeriod
            .where((o) => o.status == SellerOrderStatus.dibatalkan)
            .length;

        final revenue = done.fold<int>(0, (sum, o) => sum + o.subtotal);
        final itemsSold = done.fold<int>(0, (sum, o) => sum + o.itemCount);
        final average = done.isEmpty ? 0 : (revenue / done.length).round();

        final bars = _bars(done);
        final maxV = bars.fold<int>(0, (m, b) => b.value > m ? b.value : m);

        // produk terlaris (dari pesanan selesai)
        final agg = <String, _Agg>{};
        for (final o in done) {
          for (final l in o.lines) {
            final a = agg.putIfAbsent(l.name, () => _Agg());
            a.qty += l.qty;
            a.revenue += l.total;
          }
        }
        final top = agg.entries.toList()
          ..sort((a, b) => b.value.revenue.compareTo(a.value.revenue));
        final topShown = top.take(5).toList();
        final topMax = topShown.isEmpty ? 0 : topShown.first.value.revenue;

        return Scaffold(
          appBar: AppBar(title: const Text('Laporan Penjualan')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              SegmentedButton<_Period>(
                segments: const [
                  ButtonSegment(value: _Period.tujuh, label: Text('7 hari')),
                  ButtonSegment(
                    value: _Period.tigaPuluh,
                    label: Text('30 hari'),
                  ),
                ],
                selected: {_period},
                onSelectionChanged: (s) => setState(() => _period = s.first),
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: AppColors.primarySoft,
                  selectedForegroundColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: 14),

              // ---------- Ringkasan ----------
              Row(
                children: [
                  Expanded(
                    child: SellerStatTile(
                      icon: Icons.payments_outlined,
                      value: formatRupiah(revenue),
                      label: 'Pendapatan',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SellerStatTile(
                      icon: Icons.check_circle_outline_rounded,
                      value: '${done.length}',
                      label: 'Pesanan selesai',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SellerStatTile(
                      icon: Icons.receipt_long_outlined,
                      value: formatRupiah(average),
                      label: 'Rata-rata per pesanan',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SellerStatTile(
                      icon: Icons.inventory_2_outlined,
                      value: '$itemsSold',
                      label: 'Produk terjual',
                    ),
                  ),
                ],
              ),

              // ---------- Grafik ----------
              SellerSectionTitle(
                _period == _Period.tujuh
                    ? 'Pendapatan per hari'
                    : 'Pendapatan per 5 hari',
              ),
              AppCard(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                child: maxV == 0
                    ? const SizedBox(
                        height: 120,
                        child: Center(
                          child: Text(
                            'Belum ada pesanan selesai pada periode ini.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 150,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (final b in bars)
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      _compact(b.value),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      height: b.value == 0
                                          ? 4
                                          : (b.value / maxV * 86)
                                              .clamp(4.0, 86.0)
                                              .toDouble(),
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: b.value == 0
                                            ? Colors.black12
                                            : AppColors.primary,
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      b.label,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
              ),

              // ---------- Produk terlaris ----------
              const SellerSectionTitle('Produk terlaris'),
              if (topShown.isEmpty)
                const AppCard(
                  child: Text(
                    'Belum ada penjualan pada periode ini.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              else
                AppCard(
                  child: Column(
                    children: [
                      for (var i = 0; i < topShown.length; i++) ...[
                        if (i > 0) const SizedBox(height: 14),
                        _TopRow(
                          rank: i + 1,
                          name: topShown[i].key,
                          qty: topShown[i].value.qty,
                          revenue: topShown[i].value.revenue,
                          fraction: topMax == 0
                              ? 0
                              : topShown[i].value.revenue / topMax,
                        ),
                      ],
                    ],
                  ),
                ),

              const SizedBox(height: 14),
              Text(
                'Pendapatan = subtotal produk dari pesanan berstatus Selesai (tanpa ongkir). '
                '${cancelled > 0 ? '$cancelled pesanan dibatalkan pada periode ini tidak dihitung. ' : ''}'
                'Semua data adalah contoh untuk demo.',
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({
    required this.rank,
    required this.name,
    required this.qty,
    required this.revenue,
    required this.fraction,
  });

  final int rank;
  final String name;
  final int qty;
  final int revenue;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              height: 24,
              width: 24,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$rank',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              formatRupiah(revenue),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: fraction.clamp(0.0, 1.0).toDouble(),
                  minHeight: 6,
                  backgroundColor: AppColors.primarySoft,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$qty terjual',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}