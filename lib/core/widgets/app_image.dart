import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Menampilkan gambar aset. Kalau assetPath kosong atau file belum ada,
/// tampil placeholder hijau dengan ikon.
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    this.assetPath,
    this.icon = Icons.eco_rounded,
    this.height,
    this.width,
    this.radius = 16,
  });

  final String? assetPath;
  final IconData icon;
  final double? height;
  final double? width;
  final double radius;

  Widget _placeholder() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE6F6EC), Color(0xFFBFE6CC)],
        ),
      ),
      child: Center(
        child: Icon(icon, size: 44, color: AppColors.primaryFaint),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: height,
        width: width,
        child: assetPath == null
            ? _placeholder()
            : Image.asset(
                assetPath!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => _placeholder(),
              ),
      ),
    );
  }
}