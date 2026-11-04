import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/utils/id_format.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../models/production_record.dart';
import 'production_form_screen.dart';
import 'production_log_controller.dart';

class ProductionHistoryScreen extends StatefulWidget {
  const ProductionHistoryScreen({super.key});

  @override
  State<ProductionHistoryScreen> createState() =>
      _ProductionHistoryScreenState();
}

class _ProductionHistoryScreenState extends State<ProductionHistoryScreen> {
  ProductionStatus? _filter; // null = semua

  void _openForm([ProductionRecord? r]) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductionFormScreen(initial: r)),
    );
  }

  Future<void> _confirmDelete(ProductionRecord r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus catatan?'),
        content: Text(
          'Catatan ${r.type.label} (${formatTanggal(r.startDate)}) akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok == true) ProductionLogController.instance.remove(r.id);
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      shape: const StadiumBorder(),
      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: selected ? Colors.white : AppColors.textPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final log = ProductionLogController.instance;

    return ListenableBuilder(
      listenable: log,
      builder: (context, _) {
        final all = log.items;
        final shown = _filter == null
            ? all
            : all.where((e) => e.status == _filter).toList();

        return Scaffold(
          appBar: AppBar(title: const Text('Riwayat Produksi')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openForm(),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Catatan Baru'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
            children: [
              // ---------- Ringkasan ----------
              Row(
                children: [
                  Expanded(
                    child: _SummaryTile(
                      label: 'Berjalan',
                      value: '${log.countOf(ProductionStatus.berjalan)}',
                      icon: Icons.autorenew_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryTile(
                      label: 'Selesai',
                      value: '${log.countOf(ProductionStatus.selesai)}',
                      icon: Icons.check_circle_outline_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SummaryTile(
                      label: 'Bahan masuk',
                      value: formatKg(log.totalInputKg),
                      icon: Icons.scale_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryTile(
                      label: 'Hasil panen (selesai)',
                      value: formatKg(log.totalYieldKg),
                      icon: Icons.inventory_2_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ---------- Filter ----------
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _chip('Semua', _filter == null,
                        () => setState(() => _filter = null)),
                    for (final s in ProductionStatus.values) ...[
                      const SizedBox(width: 8),
                      _chip(s.label, _filter == s,
                          () => setState(() => _filter = s)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ---------- Daftar ----------
              if (shown.isEmpty)
                SizedBox(
                  height: 280,
                  child: EmptyState(
                    icon: Icons.edit_note_rounded,
                    title: _filter == null
                        ? 'Belum ada catatan produksi'
                        : 'Tidak ada catatan berstatus ${_filter!.label}',
                    message:
                        'Mulai dengan menambah catatan bahan masuk dan perkembangan produksimu.',
                    actionLabel: 'Tambah catatan',
                    onAction: () => _openForm(),
                  ),
                )
              else
                for (final r in shown) ...[
                  _RecordCard(
                    record: r,
                    onTap: () => _openForm(r),
                    onDelete: () => _confirmDelete(r),
                  ),
                  const SizedBox(height: 12),
                ],

              const SizedBox(height: 4),
              const Text(
                'Efisiensi = berat hasil ÷ bahan masuk. Biaya per kg = biaya ÷ berat hasil. Keduanya hanya hitungan dari data yang kamu catat, bukan standar teknis. Tiga catatan awal adalah contoh demo.',
                style: TextStyle(
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

// ======================= Komponen lokal =======================

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge(this.status);

  final ProductionStatus status;

  @override
  Widget build(BuildContext context) {
    final (Color fg, Color bg) = switch (status) {
      ProductionStatus.berjalan => (const Color(0xFF8D6E00), AppColors.warningSoft),
      ProductionStatus.selesai => (AppColors.primary, AppColors.primarySoft),
      ProductionStatus.gagal => (AppColors.danger, AppColors.dangerSoft),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({
    required this.record,
    required this.onTap,
    required this.onDelete,
  });

  final ProductionRecord record;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final r = record;
    final isCompost = r.type == ProductionType.kompos;
    final eff = r.efficiency;
    final perKg = r.costPerKg;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCompost
                      ? Icons.grass_rounded
                      : Icons.bug_report_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.type.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Mulai ${formatTanggal(r.startDate)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(r.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            r.material,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const Divider(height: 22),
          Row(
            children: [
              Expanded(
                child: _Metric(label: 'Bahan masuk', value: formatKg(r.inputKg)),
              ),
              Expanded(
                child: _Metric(
                  label: 'Hasil panen',
                  value: r.yieldKg == null ? '-' : formatKg(r.yieldKg!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _Metric(label: 'Biaya', value: formatRupiah(r.cost)),
              ),
              Expanded(
                child: _Metric(
                  label: 'Efisiensi',
                  value: eff == null ? '-' : '${eff.round()}%',
                ),
              ),
            ],
          ),
          if (perKg != null) ...[
            const SizedBox(height: 10),
            _Metric(label: 'Biaya per kg hasil', value: formatRupiah(perKg)),
          ],
          if (r.notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              r.notes,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              if (r.hasPhoto) ...[
                const Icon(Icons.photo_outlined,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                const Text(
                  'Ada foto',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const Spacer(),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Hapus'),
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              ),
            ],
          ),
        ],
      ),
    );
  }
}