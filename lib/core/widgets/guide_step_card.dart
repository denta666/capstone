import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_card.dart';

class GuideStepCard extends StatelessWidget {
  const GuideStepCard({
    super.key,
    required this.number,
    required this.title,
    required this.checked,
    required this.total,
    required this.onTap,
    this.isCurrent = false,
  });

  final int number;
  final String title;
  final int checked;
  final int total;
  final bool isCurrent;
  final VoidCallback onTap;

  bool get _done => total > 0 && checked >= total;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: _done
                  ? AppColors.primary
                  : (isCurrent ? AppColors.primarySoft : Colors.white),
              shape: BoxShape.circle,
              border: Border.all(
                color: _done || isCurrent ? AppColors.primary : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Center(
              child: _done
                  ? const Icon(Icons.check_rounded, size: 20, color: Colors.white)
                  : Text(
                      '$number',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: isCurrent
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _done ? 'Selesai' : '$checked dari $total tindakan',
                  style: TextStyle(
                    fontSize: 12,
                    color: _done ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: _done ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}