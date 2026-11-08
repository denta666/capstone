import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../models/seller_order.dart';

const int kLowStock = 5;

class SellerSectionTitle extends StatelessWidget {
  const SellerSectionTitle(this.title, {super.key, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 22, 2, 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
            if (actionLabel != null)
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ),
      );
}

class SellerStatTile extends StatelessWidget {
  const SellerStatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.accent = false,
    this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: accent ? AppColors.warning : AppColors.primary),
            const SizedBox(height: 8),
            Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      );
}

class SellerOrderStatusBadge extends StatelessWidget {
  const SellerOrderStatusBadge(this.status, {super.key});

  final SellerOrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (Color foreground, Color background) = switch (status) {
      SellerOrderStatus.baru => (AppColors.primary, AppColors.primarySoft),
      SellerOrderStatus.diproses => (AppColors.warning, AppColors.warningSoft),
      SellerOrderStatus.dikirim => (Colors.blue.shade700, Colors.blue.shade50),
      SellerOrderStatus.selesai => (AppColors.primary, AppColors.primarySoft),
      SellerOrderStatus.dibatalkan => (AppColors.danger, AppColors.dangerSoft),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
      child: Text(status.label, style: TextStyle(color: foreground, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}