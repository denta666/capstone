import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import 'auth_controller.dart';
import 'login_screen.dart';
import 'register_screen.dart';

/// Membungkus fitur yang wajib login. Tamu melihat halaman ajakan masuk,
/// pengguna yang sudah login langsung melihat [child]. Otomatis berganti
/// saat status login berubah (masuk atau keluar).
class LoginGate extends StatelessWidget {
  const LoginGate({
    super.key,
    required this.title,
    required this.icon,
    required this.message,
    required this.child,
  });

  final String title;
  final IconData icon;
  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthController.instance,
      builder: (context, _) {
        if (AuthController.instance.isLoggedIn) return child;

        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 88,
                      width: 88,
                      decoration: const BoxDecoration(
                        color: AppColors.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 40, color: AppColors.primary),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Masuk untuk memakai $title',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 22),
                    PrimaryButton(
                      label: 'Masuk',
                      icon: Icons.login_rounded,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => LoginScreen(
                            message: 'Masuk dulu untuk memakai $title.',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    PrimaryButton(
                      label: 'Daftar',
                      outlined: true,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
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


Future<bool> requireLogin(BuildContext context, {String? message}) async {
  if (AuthController.instance.isLoggedIn) return true;

  final ok = await Navigator.of(context).push<bool>(
    MaterialPageRoute(builder: (_) => LoginScreen(message: message)),
  );
  return ok == true && AuthController.instance.isLoggedIn;
}