import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/seller_application.dart';
import '../../models/user_account.dart';
import '../feedback/feedback_screen.dart';
import '../production_log/production_history_screen.dart';
import '../seller/seller_dashboard_screen.dart';
import 'auth_controller.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';
import 'order_history_screen.dart';
import 'register_screen.dart';
import 'seller_application_screen.dart';
import 'settings_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  void _info(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text('Kamu bisa masuk lagi kapan saja.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      AuthController.instance.logout();
      _info(context, 'Berhasil keluar');
    }
  }

  String _applicationSubtitle(SellerApplication? a) {
    if (a == null) return 'Ajukan lewat formulir dan syarat';
    return switch (a.status) {
      ApplicationStatus.menunggu => 'Pengajuan menunggu verifikasi',
      ApplicationStatus.ditolak => 'Pengajuan ditolak, bisa diajukan ulang',
      ApplicationStatus.disetujui => 'Disetujui',
    };
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthController.instance,
      builder: (context, _) {
        final user = AuthController.instance.current;

        return Scaffold(
          appBar: AppBar(title: const Text('Akun')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: user == null
                ? _guest(context)
                : _loggedIn(context, user),
          ),
        );
      },
    );
  }

  // ---------------- Tamu ----------------
  List<Widget> _guest(BuildContext context) {
    return [
      AppCard(
        child: Column(
          children: [
            Container(
              height: 72,
              width: 72,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Masuk untuk pengalaman lengkap',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Katalog dan panduan produksi bisa dibuka tanpa akun. Akun dibutuhkan untuk keranjang, checkout, dan EcoBot.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Masuk',
              onPressed: () => _push(context, const LoginScreen()),
            ),
            const SizedBox(height: 10),
            PrimaryButton(
              label: 'Daftar',
              outlined: true,
              onPressed: () => _push(context, const RegisterScreen()),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      AppCard(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            _MenuTile(
              icon: Icons.feedback_outlined,
              title: 'Beri feedback',
              subtitle: 'Saran dan masukan untuk aplikasi',
              onTap: () => _push(context, const FeedbackScreen()),
            ),
            const Divider(height: 1),
            _MenuTile(
              icon: Icons.settings_outlined,
              title: 'Pengaturan',
              onTap: () => _push(context, const SettingsScreen()),
            ),
          ],
        ),
      ),
    ];
  }

  // ---------------- Sudah masuk ----------------
  List<Widget> _loggedIn(BuildContext context, UserAccount user) {
    final initial =
        user.name.trim().isEmpty ? '?' : user.name.trim()[0].toUpperCase();
    final application = AuthController.instance.applicationOf(user.email);

    return [
      AppCard(
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primary,
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user.role.label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      AppCard(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            _MenuTile(
              icon: Icons.edit_outlined,
              title: 'Edit profil',
              onTap: () => _push(context, const EditProfileScreen()),
            ),
            const Divider(height: 1),
            _MenuTile(
              icon: Icons.receipt_long_outlined,
              title: 'Riwayat transaksi',
              onTap: () => _push(context, const OrderHistoryScreen()),
            ),
            const Divider(height: 1),
            _MenuTile(
              icon: Icons.history_rounded,
              title: 'Riwayat produksi',
              onTap: () => _push(context, const ProductionHistoryScreen()),
            ),
            if (user.role == UserRole.pembeli) ...[
              const Divider(height: 1),
              _MenuTile(
                icon: Icons.storefront_outlined,
                title: 'Jadi penjual / mitra',
                subtitle: _applicationSubtitle(application),
                onTap: () => _push(context, const SellerApplicationScreen()),
              ),
            ],
            if (user.role == UserRole.penjual) ...[
              const Divider(height: 1),
              _MenuTile(
                icon: Icons.dashboard_outlined,
                title: 'Dashboard penjual',
                subtitle: 'Kelola produk, stok, dan pesanan',
                onTap: () => _push(context, const SellerDashboardScreen()),
              ),
            ],
            const Divider(height: 1),
            _MenuTile(
              icon: Icons.feedback_outlined,
              title: 'Beri feedback',
              subtitle: 'Saran dan masukan untuk aplikasi',
              onTap: () => _push(context, const FeedbackScreen()),
            ),
            const Divider(height: 1),
            _MenuTile(
              icon: Icons.settings_outlined,
              title: 'Pengaturan',
              onTap: () => _push(context, const SettingsScreen()),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      AppCard(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: _MenuTile(
          icon: Icons.logout_rounded,
          title: 'Keluar',
          color: AppColors.danger,
          showChevron: false,
          onTap: () => _logout(context),
        ),
      ),
    ];
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.color,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? color;
  final bool showChevron;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color ?? AppColors.primary),
      title: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c),
      ),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: const TextStyle(fontSize: 12)),
      trailing: showChevron ? const Icon(Icons.chevron_right_rounded) : null,
    );
  }
}