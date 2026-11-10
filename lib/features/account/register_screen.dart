import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/input_style.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/primary_button.dart';
import 'auth_controller.dart';

/// Mengembalikan true lewat Navigator.pop kalau registrasi berhasil.
/// Semua akun baru terdaftar sebagai Pembeli.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final err = AuthController.instance.register(
      name: _name.text,
      email: _email.text,
      password: _password.text,
      phone: _phone.text,
    );
    if (err != null) {
      setState(() {
        _loading = false;
        _error = err;
      });
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop(true);
    messenger.showSnackBar(
      const SnackBar(content: Text('Akun berhasil dibuat (simulasi)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: [
              const Text(
                'Buat akun EcoHome',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              const Text(
                'Katalog bisa dilihat tanpa akun. Akun dibutuhkan untuk keranjang, checkout, dan EcoBot.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 20, color: AppColors.primary),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Semua akun baru terdaftar sebagai Pembeli. Ingin berjualan? Setelah masuk, ajukan menjadi Penjual / Mitra lewat menu Akun.',
                        style: TextStyle(fontSize: 12.5, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      decoration: appInputDecoration(
                        'Nama lengkap',
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                      ),
                      validator: (v) => (v == null || v.trim().length < 3)
                          ? 'Isi nama (minimal 3 huruf)'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: appInputDecoration(
                        'Email',
                        prefixIcon: const Icon(Icons.mail_outline_rounded),
                      ),
                      validator: validateEmail,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: appInputDecoration(
                        'Nomor HP (opsional)',
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                      validator: validateOptionalPhone,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      decoration: appInputDecoration(
                        'Kata sandi',
                        hint: 'Minimal 8 karakter',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: validateNewPassword,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _confirm,
                      obscureText: _obscure,
                      decoration: appInputDecoration(
                        'Ulangi kata sandi',
                        prefixIcon: const Icon(Icons.lock_reset_rounded),
                      ),
                      validator: (v) => v != _password.text
                          ? 'Kata sandi tidak sama'
                          : null,
                    ),
                  ],
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Buat Akun',
                loading: _loading,
                onPressed: _submit,
              ),
              const SizedBox(height: 12),
              const Text(
                'Pendaftaran ini simulasi lokal. Tidak ada data yang dikirim atau disimpan permanen.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}