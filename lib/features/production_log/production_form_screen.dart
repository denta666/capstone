import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/id_format.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/production_record.dart';
import 'production_log_controller.dart';

class ProductionFormScreen extends StatefulWidget {
  const ProductionFormScreen({super.key, this.initial});

  /// Kalau diisi, form masuk mode ubah.
  final ProductionRecord? initial;

  @override
  State<ProductionFormScreen> createState() => _ProductionFormScreenState();
}

class _ProductionFormScreenState extends State<ProductionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late ProductionType _type;
  late ProductionStatus _status;
  DateTime? _date;
  bool _hasPhoto = false;

  final _dateC = TextEditingController();
  final _materialC = TextEditingController();
  final _inputC = TextEditingController();
  final _costC = TextEditingController();
  final _yieldC = TextEditingController();
  final _notesC = TextEditingController();

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final r = widget.initial;
    _type = r?.type ?? ProductionType.kompos;
    _status = r?.status ?? ProductionStatus.berjalan;
    if (r != null) {
      _date = r.startDate;
      _dateC.text = formatTanggal(r.startDate);
      _materialC.text = r.material;
      _inputC.text = _plain(r.inputKg);
      _costC.text = '${r.cost}';
      _yieldC.text = r.yieldKg == null ? '' : _plain(r.yieldKg!);
      _notesC.text = r.notes;
      _hasPhoto = r.hasPhoto;
    }
  }

  @override
  void dispose() {
    _dateC.dispose();
    _materialC.dispose();
    _inputC.dispose();
    _costC.dispose();
    _yieldC.dispose();
    _notesC.dispose();
    super.dispose();
  }

  String _plain(double v) =>
      (v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString())
          .replaceAll('.', ',');

  /// Menerima koma atau titik sebagai pemisah desimal.
  double? _num(String? v) =>
      double.tryParse((v ?? '').trim().replaceAll(',', '.'));

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _dateC.text = formatTanggal(picked);
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final record = ProductionRecord(
      id: widget.initial?.id ?? ProductionLogController.instance.newId(),
      type: _type,
      startDate: _date!,
      material: _materialC.text.trim(),
      inputKg: _num(_inputC.text)!,
      cost: int.parse(_costC.text.trim()),
      notes: _notesC.text.trim(),
      hasPhoto: _hasPhoto,
      yieldKg: _num(_yieldC.text),
      status: _status,
    );

    ProductionLogController.instance.save(record);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(_isEdit ? 'Catatan diperbarui' : 'Catatan disimpan'),
      ),
    );
  }

  InputDecoration _dec(String label, {String? hint, String? suffix, Widget? icon}) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixText: suffix,
      suffixIcon: icon,
      filled: true,
      fillColor: Colors.white,
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final segStyle = SegmentedButton.styleFrom(
      selectedBackgroundColor: AppColors.primarySoft,
      selectedForegroundColor: AppColors.primary,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Ubah Catatan' : 'Catatan Produksi Baru'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            _label('Jenis produksi'),
            SegmentedButton<ProductionType>(
              segments: const [
                ButtonSegment(
                  value: ProductionType.kompos,
                  label: Text('Kompos'),
                  icon: Icon(Icons.grass_rounded),
                ),
                ButtonSegment(
                  value: ProductionType.maggot,
                  label: Text('Maggot BSF'),
                  icon: Icon(Icons.bug_report_rounded),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
              showSelectedIcon: false,
              style: segStyle,
            ),
            const SizedBox(height: 18),

            TextFormField(
              controller: _dateC,
              readOnly: true,
              onTap: _pickDate,
              decoration: _dec(
                'Tanggal mulai',
                hint: 'Pilih tanggal',
                icon: const Icon(Icons.calendar_today_rounded, size: 20),
              ),
              validator: (_) => _date == null ? 'Pilih tanggal mulai' : null,
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _materialC,
              textCapitalization: TextCapitalization.sentences,
              decoration: _dec(
                'Jenis bahan',
                hint: 'Contoh: sisa sayur dan daun kering',
              ),
              validator: (v) => (v == null || v.trim().length < 3)
                  ? 'Isi jenis bahan (minimal 3 huruf)'
                  : null,
            ),
            const SizedBox(height: 14),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _inputC,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    decoration: _dec('Bahan masuk', suffix: 'kg'),
                    validator: (v) {
                      final n = _num(v);
                      if (n == null || n <= 0) return 'Isi lebih dari 0';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _costC,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _dec('Biaya', suffix: 'Rp'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Isi biaya (boleh 0)';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            _label('Status produksi'),
            SegmentedButton<ProductionStatus>(
              segments: const [
                ButtonSegment(
                  value: ProductionStatus.berjalan,
                  label: Text('Berjalan'),
                ),
                ButtonSegment(
                  value: ProductionStatus.selesai,
                  label: Text('Selesai'),
                ),
                ButtonSegment(
                  value: ProductionStatus.gagal,
                  label: Text('Gagal'),
                ),
              ],
              selected: {_status},
              onSelectionChanged: (s) => setState(() => _status = s.first),
              showSelectedIcon: false,
              style: segStyle,
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _yieldC,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: _dec(
                'Berat hasil panen',
                hint: _status == ProductionStatus.selesai
                    ? 'Wajib diisi'
                    : 'Boleh dikosongkan dulu',
                suffix: 'kg',
              ),
              validator: (v) {
                final text = (v ?? '').trim();
                if (text.isEmpty) {
                  return _status == ProductionStatus.selesai
                      ? 'Wajib diisi kalau status Selesai'
                      : null;
                }
                final n = _num(text);
                if (n == null || n < 0) return 'Angka tidak valid';
                if (_status == ProductionStatus.selesai && n == 0) {
                  return 'Isi lebih dari 0 kalau status Selesai';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _notesC,
              minLines: 3,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: _dec(
                'Catatan perkembangan',
                hint: 'Aroma, kelembapan, kendala, hal yang diubah...',
              ),
            ),
            const SizedBox(height: 14),

            // Foto: simulasi (pemilih foto sungguhan perlu package image_picker)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _hasPhoto
                            ? Icons.photo_rounded
                            : Icons.add_a_photo_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _hasPhoto
                              ? 'Foto dokumentasi dilampirkan (simulasi)'
                              : 'Foto dokumentasi (opsional)',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _hasPhoto = !_hasPhoto),
                        child: Text(_hasPhoto ? 'Hapus' : 'Lampirkan'),
                      ),
                    ],
                  ),
                  const Text(
                    'Pada tahap UI ini tombol hanya penanda. Pemilih foto sungguhan ditambahkan saat integrasi.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
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
              label: _isEdit ? 'Simpan Perubahan' : 'Simpan Catatan',
              icon: Icons.check_rounded,
              onPressed: _submit,
            ),
          ),
        ),
      ),
    );
  }
}