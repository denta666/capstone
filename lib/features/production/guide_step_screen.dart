import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/guide.dart';
import 'learning_progress.dart';

class GuideStepScreen extends StatelessWidget {
  const GuideStepScreen({super.key, required this.guide, required this.index});

  final Guide guide;
  final int index;

  GuideStep get _step => guide.steps[index];
  bool get _isLast => index == guide.steps.length - 1;

  void _next(BuildContext context) {
    if (_isLast) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => GuideStepScreen(guide: guide, index: index + 1),
        ),
      );
    }
  }

  void _complete(BuildContext context) {
    LearningProgress.instance.completeStep(guide, index);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Tahap ${index + 1} ditandai selesai')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final progress = LearningProgress.instance;

    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) {
        final done = progress.isStepDone(guide, index);
        final checked = progress.checkedInStep(guide, index);

        return Scaffold(
          appBar: AppBar(
            title: Text('Tahap ${index + 1} dari ${guide.steps.length}'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: [
              // progres panduan
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress.progress(guide),
                  minHeight: 8,
                  backgroundColor: AppColors.primarySoft,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${guide.title}: ${(progress.progress(guide) * 100).round()}% selesai',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              AppImage(icon: _step.icon, height: 160, radius: 18),
              const SizedBox(height: 16),

              Text(
                'TAHAP ${index + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _step.title,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _step.description,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),

              // ---------- Checklist ----------
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Checklist tindakan',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    '$checked/${_step.checklist.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AppCard(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    for (var i = 0; i < _step.checklist.length; i++)
                      CheckboxListTile(
                        value: progress.isChecked(guide, index, i),
                        onChanged: (_) => progress.toggle(guide, index, i),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: AppColors.primary,
                        dense: true,
                        title: Text(
                          _step.checklist[i],
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.35,
                            decoration: progress.isChecked(guide, index, i)
                                ? TextDecoration.lineThrough
                                : null,
                            color: progress.isChecked(guide, index, i)
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ---------- Tips ----------
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb_outline_rounded,
                            size: 20, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'Tips',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (final t in _step.tips)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• $t',
                          style: const TextStyle(fontSize: 13, height: 1.4),
                        ),
                      ),
                  ],
                ),
              ),

              // ---------- Peringatan ----------
              if (_step.warning != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warningSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          size: 22, color: AppColors.warning),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _step.warning!,
                          style: const TextStyle(fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                      child: PrimaryButton(
                        label: done ? 'Selesai' : 'Tandai Selesai',
                        icon: done
                            ? Icons.check_circle_rounded
                            : Icons.check_rounded,
                        outlined: true,
                        onPressed: done ? null : () => _complete(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        label: _isLast ? 'Kembali' : 'Tahap Berikutnya',
                        onPressed: () => _next(context),
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