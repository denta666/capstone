import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/input_style.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/user_account.dart';
import 'auth_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _address;

  @override
  void initState() {
    super.initState();
    final u = AuthController.instance.current!;
    _name = TextEditingController(text: u.name);
    _phone = TextEditingController(text: u.phone);
    _address = TextEditingController(text: u.address);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    AuthController.instance.updateProfile(
      name: _name.text,
      phone: _phone.text,
      address: _address.text,
    );
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      const SnackBar(content: Text('Profil diperbarui')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthController.instance.current!;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
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
              initialValue: user.email,
              enabled: false,
              decoration: appInputDecoration(
                'Email',
                prefixIcon: const Icon(Icons.mail_outline_rounded),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              initialValue: user.role.label,
              enabled: false,
              decoration: appInputDecoration(
                'Peran',
                prefixIcon: const Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: appInputDecoration(
                'Nomor HP',
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              validator: validateOptionalPhone,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _address,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: appInputDecoration(
                'Alamat',
                hint: 'Alamat pengiriman (opsional)',
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Email dan peran tidak bisa diubah di versi demo ini. Data profil hanya tersimpan sementara di aplikasi.',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
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
              label: 'Simpan Perubahan',
              icon: Icons.check_rounded,
              onPressed: _save,
            ),
          ),
        ),
      ),
    );
  }
}