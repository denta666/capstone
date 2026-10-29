import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.outlined = false,
    this.loading = false,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outlined;
  final bool loading;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.button),
    );
    const textStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);

    final Widget child = loading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: outlined ? AppColors.primary : Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    final VoidCallback? action = loading ? null : onPressed;

    final Widget button = outlined
        ? OutlinedButton(
            onPressed: action,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 50),
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: shape,
              textStyle: textStyle,
            ),
            child: child,
          )
        : FilledButton(
            onPressed: action,
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 50),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: shape,
              textStyle: textStyle,
            ),
            child: child,
          );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}