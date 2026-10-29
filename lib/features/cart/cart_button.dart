import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'cart_controller.dart';
import 'cart_screen.dart';

class CartButton extends StatelessWidget {
  const CartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartController.instance,
      builder: (context, _) {
        final n = CartController.instance.totalItems;
        return Material(
          color: Colors.white,
          shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
            child: SizedBox(
              height: 44,
              width: 44,
              child: Center(
                child: Badge(
                  label: Text('$n'),
                  isLabelVisible: n > 0,
                  backgroundColor: AppColors.primary,
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    size: 22,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}