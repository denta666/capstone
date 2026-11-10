import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/input_style.dart';
import '../../core/utils/id_format.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/seller_application.dart';
import '../../models/user_account.dart';
import '../seller/seller_dashboard_screen.dart';
import 'auth_controller.dart';

const _productTypes = ['Kompos', 'Maggot BSF', 'Pupuk organik', 'Perlengkapan'];
const _sources = ['Produksi sendiri', 'Kelompok / bank sampah', 'Reseller'];

class SellerApplicationScreen extends StatefulWidget {
  const SellerApplicationScreen({super.key});

  @override
  State<SellerApplicationScreen> createState() =>
      _SellerApplicationScreenState();
}

class _SellerApplicationScreenState extends State<SellerApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _store = TextEditingController();
  final _city = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _desc = TextEditingController();

  final Set<String> _types = {};
  String _source = _sources.first;
  bool _a1 = false;
  bool _a2 = false;
  bool _a3 = false;
  bool _submitted = false; // true setelah tombol kirim ditekan sekali
  bool _reapply = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = AuthController.instance.current;
    if (user != null) {
      _phone.text = user.phone;
      final prev = AuthController.instance.applicationOf(user.email);
      if (prev != null) {
        _store.text = prev.storeName;
        _city.text = prev.city;
        _address.text = prev.address;
        _desc.text = prev.description;
        _phone.text = prev.phone;
        _types.addAll(prev.productTypes);
        _source = prev.source;
      }
    }
  }

  @override
  void dispose() {
    _store.dispose();
    _city.dispose();
    _address.dispose();
    _phone.dispose();
    _desc.dispose();
    super.dispose();
  }

  void _say(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _submit(UserAccount user) async {
    setState(() => _submitted = true);

    final formOk = _formKey.currentState!.validate();
    final typesOk = _types.isNotEmpty;
    final agreeOk = _a1 && _a2 && _a3;
    if (!formOk || !typesOk || !agreeOk) return;

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final err = AuthController.instance.submitSellerApplication(
      SellerApplication(
        email: user.email,
        storeName: _store.text.trim(),
        productTypes: _productTypes.where(_types.contains).toList(),
        source: _source,
        city: _city.text.trim(),
        address: _address.text.trim(),
        phone: _phone.text.trim(),
        description: _desc.text.trim(),
        submittedAt: DateTime.now(),
        status: ApplicationStatus.menunggu,
      ),
    );

    setState(() => _loading = false);
    if (err != null) {
      _say(err);
      return;
    }
    _reapply = false;
    _say('Pengajuan terkirim. Menunggu verifikasi (simulasi).');
  }

  // ======================= Tampilan =======================

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthController.instance,
      builder: (context, _) {
        final user = AuthController.instance.current;

        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Jadi Penjual / Mitra')),
            body: const EmptyState(
              icon: Icons.lock_outline_rounded,
              title: 'Masuk dulu',
              message: 'Kamu perlu masuk sebagai pembeli untuk mengajukan.',
            ),
          );
        }

        if (user.role == UserRole.penjual) return _approvedView();

        final app = AuthController.instance.applicationOf(user.email);
        if (app != null && app.status == ApplicationStatus.menunggu) {
          return _pendingView(user, app);
        }
        if (app != null &&
            app.status == ApplicationStatus.ditolak &&
            !_reapply) {
          return _rejectedView(app);
        }
        return _formView(user);
      },
    );
  }

  Widget _banner({
    required IconData icon,
    required Color fg,
    required Color bg,
    required String title,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fg, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(text, style: const TextStyle(fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(SellerApplication a) {
    return AppCard(
      child: Column(
        children: [
          _infoRow('Nama usaha', a.storeName),
          _infoRow('Jenis produk', a.productTypes.join(', ')),
          _infoRow('Sumber produk', a.source),
          _infoRow('Lokasi', a.city),
          _infoRow('Nomor HP', a.phone),
          _infoRow('Diajukan', formatTanggal(a.submittedAt)),
        ],
      ),
    );
  }

  // ---- Disetujui ----
  Widget _approvedView() {
    return Scaffold(
      appBar: AppBar(title: const Text('Jadi Penjual / Mitra')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _banner(
            icon: Icons.check_circle_rounded,
            fg: AppColors.primary,
            bg: AppColors.primarySoft,
            title: 'Kamu sudah menjadi Penjual / Mitra',
            text:
                'Pengajuanmu disetujui. Kamu bisa menambah produk, mengelola stok, dan memproses pesanan.',
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Buka dashboard penjual',
            icon: Icons.dashboard_outlined,
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const SellerDashboardScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Menunggu verifikasi ----
  Widget _pendingView(UserAccount user, SellerApplication app) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jadi Penjual / Mitra')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _banner(
            icon: Icons.hourglass_top_rounded,
            fg: AppColors.warning,
            bg: AppColors.warningSoft,
            title: 'Menunggu verifikasi',
            text:
                'Pengajuanmu sudah diterima. Hasilnya akan muncul di sini setelah diperiksa admin.',
          ),
          const SizedBox(height: 16),
          _summaryCard(app),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.science_outlined,
                        size: 20, color: AppColors.warning),
                    SizedBox(width: 8),
                    Text(
                      'Simulasi verifikasi admin',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Hanya untuk demo. Di sistem nyata, admin memeriksa data dan dokumen usaha, lalu memutuskan. Tombol ini menggantikan peran admin.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        label: 'Tolak',
                        outlined: true,
                        onPressed: () => AuthController.instance
                            .demoDecideApplication(user.email, approve: false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Setujui',
                        onPressed: () => AuthController.instance
                            .demoDecideApplication(user.email, approve: true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- Ditolak ----
  Widget _rejectedView(SellerApplication app) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jadi Penjual / Mitra')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _banner(
            icon: Icons.cancel_outlined,
            fg: AppColors.danger,
            bg: AppColors.dangerSoft,
            title: 'Pengajuan ditolak',
            text: app.rejectionNote ?? 'Lengkapi data lalu ajukan kembali.',
          ),
          const SizedBox(height: 16),
          _summaryCard(app),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Ajukan ulang',
            icon: Icons.refresh_rounded,
            onPressed: () => setState(() {
              _reapply = true;
              _submitted = false;
              _a1 = _a2 = _a3 = false;
            }),
          ),
        ],
      ),
    );
  }

  // ---- Formulir ----
  Widget _requirementRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, height: 1.35)),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      );

  Widget _errorText(String text) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.danger,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  Widget _agree(String text, bool value, ValueChanged<bool> onChanged) {
    return CheckboxListTile(
      value: value,
      onChanged: (v) => onChanged(v ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
      activeColor: AppColors.primary,
      title: Text(text, style: const TextStyle(fontSize: 13, height: 1.35)),
    );
  }

  Widget _formView(UserAccount user) {
    final auto = _submitted
        ? AutovalidateMode.onUserInteraction
        : AutovalidateMode.disabled;

    return Scaffold(
      appBar: AppBar(title: const Text('Jadi Penjual / Mitra')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Syarat menjadi Penjual / Mitra',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  _requirementRow('Memiliki akun pembeli yang aktif'),
                  _requirementRow('Nomor HP aktif yang bisa dihubungi'),
                  _requirementRow(
                    'Menjual produk olahan sampah organik: kompos, maggot BSF, pupuk organik, atau perlengkapannya',
                  ),
                  _requirementRow('Informasi usaha lengkap dan benar'),
                  _requirementRow('Menyetujui ketentuan mitra di bawah'),
                ],
              ),
            ),

            _sectionLabel('Data usaha'),
            TextFormField(
              controller: _store,
              autovalidateMode: auto,
              textCapitalization: TextCapitalization.words,
              decoration: appInputDecoration(
                'Nama usaha / toko',
                prefixIcon: const Icon(Icons.storefront_outlined),
              ),
              validator: (v) => (v == null || v.trim().length < 3)
                  ? 'Isi nama usaha (minimal 3 huruf)'
                  : null,
            ),

            _sectionLabel('Jenis produk yang dijual'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in _productTypes)
                  FilterChip(
                    label: Text(t),
                    selected: _types.contains(t),
                    onSelected: (v) => setState(() {
                      if (v) {
                        _types.add(t);
                      } else {
                        _types.remove(t);
                      }
                    }),
                    showCheckmark: false,
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    side: BorderSide(
                      color: _types.contains(t)
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _types.contains(t)
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                  ),
              ],
            ),
            if (_submitted && _types.isEmpty)
              _errorText('Pilih minimal satu jenis produk'),

            _sectionLabel('Sumber produk'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in _sources)
                  ChoiceChip(
                    label: Text(s),
                    selected: _source == s,
                    onSelected: (_) => setState(() => _source = s),
                    showCheckmark: false,
                    selectedColor: AppColors.primarySoft,
                    backgroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    side: BorderSide(
                      color: _source == s
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _source == s
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
              ],
            ),

            _sectionLabel('Lokasi dan kontak'),
            TextFormField(
              controller: _city,
              autovalidateMode: auto,
              textCapitalization: TextCapitalization.words,
              decoration: appInputDecoration(
                'Kota / kabupaten',
                hint: 'Contoh: Kab. Tegal',
                prefixIcon: const Icon(Icons.location_city_outlined),
              ),
              validator: (v) => (v == null || v.trim().length < 3)
                  ? 'Isi kota atau kabupaten usaha'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _address,
              autovalidateMode: auto,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: appInputDecoration(
                'Alamat usaha',
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
              validator: (v) => (v == null || v.trim().length < 10)
                  ? 'Isi alamat lengkap (minimal 10 karakter)'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phone,
              autovalidateMode: auto,
              keyboardType: TextInputType.phone,
              decoration: appInputDecoration(
                'Nomor HP aktif',
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Isi nomor HP aktif';
                return validateOptionalPhone(v);
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _desc,
              autovalidateMode: auto,
              minLines: 3,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: appInputDecoration(
                'Deskripsi usaha',
                hint: 'Ceritakan produk dan cara produksimu',
              ),
              validator: (v) => (v == null || v.trim().length < 20)
                  ? 'Deskripsi minimal 20 karakter'
                  : null,
            ),

            _sectionLabel('Pernyataan'),
            _agree(
              'Data yang saya isi benar dan dapat dipertanggungjawabkan.',
              _a1,
              (v) => setState(() => _a1 = v),
            ),
            _agree(
              'Produk yang saya jual sesuai deskripsi dan tidak mengandung sampah non-organik atau bahan berbahaya.',
              _a2,
              (v) => setState(() => _a2 = v),
            ),
            _agree(
              'Saya menyetujui ketentuan mitra EcoHome, termasuk pemeriksaan data oleh admin.',
              _a3,
              (v) => setState(() => _a3 = v),
            ),
            if (_submitted && !(_a1 && _a2 && _a3))
              _errorText('Semua pernyataan harus disetujui'),

            const SizedBox(height: 14),
            const Text(
              'Demo ini tidak mengumpulkan dokumen identitas atau izin usaha. Di sistem nyata, dokumen diperiksa admin di server sebelum akun penjual diaktifkan.',
              style: TextStyle(
                fontSize: 11,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: PrimaryButton(
              label: 'Kirim Pengajuan',
              icon: Icons.send_rounded,
              loading: _loading,
              onPressed: () => _submit(user),
            ),
          ),
        ),
      ),
    );
  }
}