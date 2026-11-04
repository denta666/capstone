import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/info_chip.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/progress_card.dart';
import '../../data/guide_data.dart';
import '../../models/guide.dart';
import '../../models/production_record.dart';
import '../production_log/production_form_screen.dart';
import '../production_log/production_history_screen.dart';
import '../production_log/production_log_controller.dart';
import 'guide_detail_screen.dart';
import 'guide_step_screen.dart';
import 'learning_progress.dart';

class ProductionScreen extends StatelessWidget {
  const ProductionScreen({super.key});

  void _openGuide(BuildContext context, Guide g) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GuideDetailScreen(guide: g)),
    );
  }

  void _openStep(BuildContext context, Guide g, int i) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GuideStepScreen(guide: g, index: i)),
    );
  }

  /// Panduan yang sedang berjalan: prioritas yang terakhir dibuka.
  Guide? _continueGuide(LearningProgress p) {
    final active = GuideData.all
        .where((g) => p.started(g) && !p.isFinished(g))
        .toList();
    if (active.isEmpty) return null;
    for (final g in active) {
      if (g.id == p.lastGuideId) return g;
    }
    return active.first;
  }

  @override
  Widget build(BuildContext context) {
    final progress = LearningProgress.instance;

    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) {
        final cont = _continueGuide(progress);
        final totalSteps =
            GuideData.all.fold<int>(0, (s, g) => s + g.steps.length);
        final doneSteps =
            GuideData.all.fold<int>(0, (s, g) => s + progress.stepsDone(g));

        return Scaffold(
          appBar: AppBar(title: const Text('Mulai Produksi')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              const Text(
                'Belum pernah membuat kompos atau budidaya maggot? Mulai dari sini, langkah demi langkah.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),

              // ---------- Lanjutkan belajar ----------
              const _Section('Lanjutkan belajar'),
              if (cont != null)
                ProgressCard(
                  title: cont.title,
                  subtitle:
                      'Lanjut: Tahap ${progress.nextStepIndex(cont) + 1} • ${cont.steps[progress.nextStepIndex(cont)].title}',
                  progress: progress.progress(cont),
                  icon: cont.icon,
                  trailingText:
                      '${progress.stepsDone(cont)}/${cont.steps.length}',
                  onTap: () => _openStep(
                    context,
                    cont,
                    progress.nextStepIndex(cont),
                  ),
                )
              else
                const AppCard(
                  child: Row(
                    children: [
                      Icon(Icons.menu_book_rounded,
                          color: AppColors.textSecondary),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Belum ada panduan yang sedang berjalan. Pilih salah satu di bawah.',
                          style: TextStyle(fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),

              // ---------- Pilih panduan ----------
              const _Section('Pilih panduan'),
              for (final g in GuideData.all) ...[
                _GuideCard(
                  guide: g,
                  progress: progress,
                  onOpen: () => _openGuide(context, g),
                ),
                const SizedBox(height: 14),
              ],

              // ---------- Progres pembelajaran ----------
              const _Section('Progres pembelajaran'),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$doneSteps dari $totalSteps tahap selesai',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final g in GuideData.all)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    g.title,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${progress.stepsDone(g)}/${g.steps.length}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progress.progress(g),
                                minHeight: 6,
                                backgroundColor: AppColors.primarySoft,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // ---------- Catatan produksi ----------
              const _Section('Catatan produksi'),
              ListenableBuilder(
                listenable: ProductionLogController.instance,
                builder: (context, _) {
                  final log = ProductionLogController.instance;
                  return AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.edit_note_rounded,
                                color: AppColors.primary, size: 26),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${log.items.length} catatan • ${log.countOf(ProductionStatus.berjalan)} berjalan. Catat bahan masuk, biaya, perkembangan, dan hasil panen.',
                                style: const TextStyle(
                                    fontSize: 13, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        PrimaryButton(
                          label: 'Tambah Catatan',
                          icon: Icons.add_rounded,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ProductionFormScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        PrimaryButton(
                          label: 'Lihat Riwayat Produksi',
                          icon: Icons.history_rounded,
                          outlined: true,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ProductionHistoryScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // ---------- Jadwal kegiatan ----------
              const _Section('Jadwal kegiatan'),
              const AppCard(
                child: Column(
                  children: [
                    _ScheduleRow(
                      icon: Icons.water_drop_outlined,
                      title: 'Cek kelembapan dan aroma media',
                      when: 'Hari ini',
                    ),
                    Divider(height: 20),
                    _ScheduleRow(
                      icon: Icons.restaurant_rounded,
                      title: 'Atur pemberian pakan maggot',
                      when: 'Besok',
                    ),
                    Divider(height: 20),
                    _ScheduleRow(
                      icon: Icons.edit_note_rounded,
                      title: 'Catat perkembangan produksi',
                      when: 'Akhir pekan',
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'Contoh jadwal untuk demo. Pengingat sungguhan dibuat saat fitur ini disambungkan.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              // ---------- Direkomendasikan ----------
              const _Section('Panduan yang direkomendasikan'),
              AppCard(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    _RecommendRow(
                      guide: GuideData.compost,
                      index: 4,
                      onTap: () => _openStep(context, GuideData.compost, 4),
                    ),
                    const Divider(height: 1),
                    _RecommendRow(
                      guide: GuideData.maggot,
                      index: 0,
                      onTap: () => _openStep(context, GuideData.maggot, 0),
                    ),
                    const Divider(height: 1),
                    _RecommendRow(
                      guide: GuideData.compost,
                      index: 7,
                      onTap: () => _openStep(context, GuideData.compost, 7),
                    ),
                  ],
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

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({
    required this.guide,
    required this.progress,
    required this.onOpen,
  });

  final Guide guide;
  final LearningProgress progress;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final started = progress.started(guide);
    final finished = progress.isFinished(guide);
    final label = !started
        ? 'Mulai Belajar'
        : (finished ? 'Tinjau Panduan' : 'Lanjutkan Belajar');

    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppImage(
            assetPath: guide.imagePath,
            icon: guide.icon,
            height: 150,
            radius: 14,
          ),
          const SizedBox(height: 12),
          Text(
            guide.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            guide.subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              InfoChip(
                icon: Icons.signal_cellular_alt_rounded,
                label: guide.difficulty,
              ),
              InfoChip(
                icon: Icons.format_list_numbered_rounded,
                label: '${guide.steps.length} tahap',
              ),
            ],
          ),
          if (started) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.progress(guide),
                minHeight: 8,
                backgroundColor: AppColors.primarySoft,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${progress.stepsDone(guide)} dari ${guide.steps.length} tahap selesai',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 14),
          PrimaryButton(label: label, onPressed: onOpen),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.icon,
    required this.title,
    required this.when,
  });

  final IconData icon;
  final String title;
  final String when;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.brownAccent),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          when,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _RecommendRow extends StatelessWidget {
  const _RecommendRow({
    required this.guide,
    required this.index,
    required this.onTap,
  });

  final Guide guide;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(guide.steps[index].icon, size: 20, color: AppColors.primary),
      ),
      title: Text(
        guide.steps[index].title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        '${guide.title} • Tahap ${index + 1}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}