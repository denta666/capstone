import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Pengaturan lokal untuk demo (belum disimpan permanen).
  bool _productionReminder = true;
  bool _promoNotif = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                SwitchListTile(
                  value: _productionReminder,
                  onChanged: (v) => setState(() => _productionReminder = v),
                  activeThumbColor: AppColors.primary,
                  title: const Text(
                    'Pengingat produksi',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Pengingat jadwal perawatan kompos dan maggot',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: _promoNotif,
                  onChanged: (v) => setState(() => _promoNotif = v),
                  activeThumbColor: AppColors.primary,
                  title: const Text(
                    'Info promo marketplace',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Kabar produk dan penawaran baru',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.language_rounded),
                  title: Text(
                    'Bahasa',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  trailing: Text(
                    'Indonesia',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text(
                'Tentang EcoHome',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'EcoHome',
                applicationVersion: 'Versi demo tampilan',
                applicationIcon: const Icon(
                  Icons.eco_rounded,
                  size: 36,
                  color: AppColors.primary,
                ),
                children: const [
                  SizedBox(height: 8),
                  Text(
                    'Sampah Organik, Solusi Bernilai.\n\nVersi ini hanya menampilkan antarmuka dengan data contoh. Login, pesanan, dan EcoBot masih simulasi lokal.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Pengaturan di halaman ini belum tersimpan permanen dan akan kembali ke bawaan saat aplikasi ditutup.',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}