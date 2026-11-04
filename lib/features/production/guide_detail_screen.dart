import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/guide_step_card.dart';
import '../../core/widgets/info_chip.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/progress_card.dart';
import '../../models/guide.dart';
import '../../navigation/app_navigation.dart';
import 'guide_step_screen.dart';
import 'learning_progress.dart';

class GuideDetailScreen extends StatelessWidget {
  const GuideDetailScreen({super.key, required this.guide});

  final Guide guide;

  void _openStep(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GuideStepScreen(guide: guide, index: index),
      ),
    );
  }

  void _askEcoBot(BuildContext context) {
    Navigator.of(context).popUntil((r) => r.isFirst);
    mainTabIndex.value = 3;
  }

  @override
  Widget build(BuildContext context) {
    final progress = LearningProgress.instance;
    final top = MediaQuery.of(context).padding.top;

    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) {
        final started = progress.started(guide);
        final finished = progress.isFinished(guide);
        final next = progress.nextStepIndex(guide);

        final startLabel = !started
            ? 'Mulai Tahap Pertama'
            : (finished ? 'Tinjau dari Awal' : 'Lanjutkan Tahap ${next + 1}');

        return Scaffold(
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              // ---------- Hero ----------
              SizedBox(
                height: 240,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: AppImage(
                        assetPath: guide.imagePath,
                        icon: guide.icon,
                        radius: 0,
                      ),
                    ),
                    Positioned(
                      top: top + 8,
                      left: 16,
                      child: Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.of(context).pop(),
                          child: const SizedBox(
                            height: 44,
                            width: 44,
                            child: Icon(Icons.arrow_back_rounded),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guide.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      guide.description,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        InfoChip(
                          icon: Icons.signal_cellular_alt_rounded,
                          label: 'Tingkat: ${guide.difficulty}',
                        ),
                        InfoChip(
                          icon: Icons.schedule_rounded,
                          label: 'Estimasi: ${guide.duration}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Estimasi bersifat indikatif dan bergantung pada metode serta kondisi.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    // ---------- Alat dan bahan ----------
                    const SizedBox(height: 22),
                    const Text(
                      'Alat dan bahan',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    AppCard(
                      child: Column(
                        children: [
                          for (final t in guide.tools)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      t,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    // ---------- Progres ----------
                    const SizedBox(height: 22),
                    ProgressCard(
                      title: 'Progres belajar',
                      subtitle:
                          '${progress.stepsDone(guide)} dari ${guide.steps.length} tahap selesai',
                      progress: progress.progress(guide),
                      icon: guide.icon,
                      trailingText:
                          '${progress.stepsDone(guide)}/${guide.steps.length}',
                    ),

                    // ---------- Daftar tahap ----------
                    const SizedBox(height: 22),
                    const Text(
                      'Tahapan pembelajaran',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    for (var i = 0; i < guide.steps.length; i++) ...[
                      GuideStepCard(
                        number: i + 1,
                        title: guide.steps[i].title,
                        checked: progress.checkedInStep(guide, i),
                        total: guide.steps[i].checklist.length,
                        isCurrent: started && !finished && i == next,
                        onTap: () => _openStep(context, i),
                      ),
                      const SizedBox(height: 10),
                    ],

                    const SizedBox(height: 6),
                    const Text(
                      'Panduan ini bersifat umum. Parameter seperti suhu, kelembapan, takaran pakan, dan durasi berbeda pada tiap metode. Ikuti sumber yang valid atau konfirmasi ke pembimbing atau pengelola bank sampah.',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        label: startLabel,
                        onPressed: () =>
                            _openStep(context, finished ? 0 : next),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        label: 'EcoBot',
                        icon: Icons.smart_toy_rounded,
                        outlined: true,
                        onPressed: () => _askEcoBot(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}