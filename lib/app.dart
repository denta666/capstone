import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/splash_screen.dart';

class EcoHomeApp extends StatelessWidget {
  const EcoHomeApp({super.key});

  /// Lebar "layar HP" saat dijalankan di layar lebar (Chrome/desktop).
  static const double _phoneWidth = 430;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoHome',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) {
        final mq = MediaQuery.of(context);

        // Di HP asli, tidak diubah.
        if (mq.size.width <= _phoneWidth) return child!;

        return ColoredBox(
          color: const Color(0xFFE9EEE9),
          child: Center(
            child: ClipRect(
              child: SizedBox(
                width: _phoneWidth,
                height: double.infinity,
                child: MediaQuery(
                  data: mq.copyWith(size: Size(_phoneWidth, mq.size.height)),
                  child: child!,
                ),
              ),
            ),
          ),
        );
      },
      home: const SplashScreen(),
    );
  }
}