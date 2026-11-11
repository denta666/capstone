import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/input_style.dart';
import '../../core/utils/id_format.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/app_feedback.dart';
import '../account/auth_controller.dart';
import 'feedback_controller.dart';

const _ratingLabels = [
  'Sangat buruk',
  'Kurang baik',
  'Cukup',
  'Baik',
  'Sangat baik',
];

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _message = TextEditingController();
  final _picker = ImagePicker();

  int _rating = 0;
  FeedbackCategory _category = FeedbackCategory.saran;
  String? _screenshot;
  bool _submitted = false; // true setelah tombol kirim ditekan sekali
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _pickScreenshot() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 80,
      );
      if (picked == null || !mounted) return; // dibatalkan
      setState(() => _screenshot = picked.path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gambar tidak bisa dibuka. Periksa izin galeri lalu coba lagi.'),
        ),
      );
    }
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    final formOk = _formKey.currentState!.validate();
    if (!formOk || _rating == 0) return;

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    FeedbackController.instance.submit(
      AppFeedback(
        id: FeedbackController.instance.newId(),
        email: AuthController.instance.current?.email ?? '',
        rating: _rating,
        category: _category,
        message: _message.text.trim(),
        createdAt: DateTime.now(),
        screenshotPath: _screenshot,
      ),
    );

    setState(() {
      _loading = false;
      _sent = true;
    });
  }

  void _reset() {
    setState(() {
      _message.clear();
      _rating = 0;
      _category = FeedbackCategory.saran;
      _screenshot = null;
      _submitted = false;
      _sent = false;
    });
  }

  // ======================= Tampilan =======================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beri Feedback')),
      body: _sent ? _successView() : _formView(),
      bottomNavigationBar: _sent
          ? null
          : Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: PrimaryButton(
                    label: 'Kirim Feedback',
                    icon: Icons.send_rounded,
                    loading: _loading,
                    onPressed: _submit,
                  ),
                ),
              ),
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

  Widget _ratingRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 1; i <= 5; i++)
              IconButton(
                onPressed: () => setState(() => _rating = i),
                tooltip: '$i bintang',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: Icon(
                  i <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 36,
                  color: i <= _rating ? AppColors.warning : AppColors.border,
                ),
              ),
          ],
        ),
        if (_rating > 0)
          Text(
            _ratingLabels[_rating - 1],
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          )
        else if (_submitted)
          const Text(
            'Pilih penilaian dulu',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.danger,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _screenshotPicker() {
    if (_screenshot == null) {
      return OutlinedButton.icon(
        onPressed: _pickScreenshot,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('Lampirkan tangkapan layar (opsional)'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.border),
        ),
      );
    }
    return Row(
      children: [
        AppImage(assetPath: _screenshot, width: 72, height: 72, radius: 12),
        const SizedBox(width: 12),
        Expanded(
          child: Wrap(
            spacing: 8,
            children: [
              TextButton(onPressed: _pickScreenshot, child: const Text('Ganti')),
              TextButton(
                onPressed: () => setState(() => _screenshot = null),
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                child: const Text('Hapus'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _formView() {
    final auto = _submitted
        ? AutovalidateMode.onUserInteraction
        : AutovalidateMode.disabled;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          const AppCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.favorite_border_rounded, color: AppColors.primary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ceritakan pengalamanmu memakai aplikasi ini. Masukanmu membantu kami memperbaikinya.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          _sectionLabel('Seberapa puas kamu dengan aplikasi ini?'),
          _ratingRow(),
          _sectionLabel('Jenis feedback'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in FeedbackCategory.values)
                ChoiceChip(
                  label: Text(c.label),
                  selected: _category == c,
                  onSelected: (_) => setState(() => _category = c),
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  side: BorderSide(
                    color: _category == c ? AppColors.primary : AppColors.border,
                  ),
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _category == c ? Colors.white : AppColors.textPrimary,
                  ),
                ),
            ],
          ),
          _sectionLabel('Pesan'),
          TextFormField(
            controller: _message,
            autovalidateMode: auto,
            minLines: 4,
            maxLines: 8,
            maxLength: 500,
            textCapitalization: TextCapitalization.sentences,
            decoration: appInputDecoration(
              'Tulis feedback',
              hint: 'Contoh: tombol keranjang susah ditemukan...',
            ),
            validator: (v) => (v == null || v.trim().length < 10)
                ? 'Tulis minimal 10 karakter'
                : null,
          ),
          _sectionLabel('Tangkapan layar'),
          _screenshotPicker(),
          const SizedBox(height: 12),
          const Text(
            'Feedback disimpan lokal untuk demo dan belum dikirim ke server.',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          ListenableBuilder(
            listenable: FeedbackController.instance,
            builder: (context, _) => _history(),
          ),
        ],
      ),
    );
  }

  Widget _history() {
    final email = AuthController.instance.current?.email ?? '';
    final items = FeedbackController.instance.mine(email);
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Feedback yang sudah kamu kirim'),
        for (final item in items) ...[
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    for (var i = 1; i <= 5; i++)
                      Icon(
                        i <= item.rating
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 16,
                        color: i <= item.rating
                            ? AppColors.warning
                            : AppColors.border,
                      ),
                    const SizedBox(width: 8),
                    Text(
                      item.category.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      formatTanggal(item.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.message,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _successView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
      children: [
        Center(
          child: Container(
            height: 84,
            width: 84,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 46,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Terima kasih!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'Feedbackmu sudah kami catat.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Kirim feedback lain',
          outlined: true,
          onPressed: _reset,
        ),
        const SizedBox(height: 10),
        PrimaryButton(
          label: 'Kembali',
          onPressed: () => Navigator.of(context).pop(),
        ),
        ListenableBuilder(
          listenable: FeedbackController.instance,
          builder: (context, _) => _history(),
        ),
      ],
    );
  }
}