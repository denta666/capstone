import 'dart:io' show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Menampilkan gambar. Sumber gambar dikenali dari [assetPath]:
/// - null / kosong      -> placeholder hijau dengan ikon
/// - `assets/...`       -> aset bawaan aplikasi
/// - `http(s)://`/`blob:` -> gambar jaringan (termasuk foto upload di web)
/// - path lain          -> file lokal (foto upload di Android/iOS/desktop)
/// Kalau gagal dimuat, tampil placeholder.
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

  Widget _image(String path) {
    Widget error(BuildContext context, Object error, StackTrace? stack) =>
        _placeholder();

    final isNetwork = path.startsWith('http://') ||
        path.startsWith('https://') ||
        path.startsWith('blob:');
    if (isNetwork || (kIsWeb && !path.startsWith('assets/'))) {
      return Image.network(path, fit: BoxFit.cover, errorBuilder: error);
    }
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover, errorBuilder: error);
    }
    return Image.file(File(path), fit: BoxFit.cover, errorBuilder: error);
  }

  @override
  Widget build(BuildContext context) {
    final path = assetPath;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: height,
        width: width,
        child: path == null || path.isEmpty ? _placeholder() : _image(path),
      ),
    );
  }
}