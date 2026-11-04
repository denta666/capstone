final RegExp _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
final RegExp _phoneRe = RegExp(r'^[0-9+]{9,15}$');

String? validateEmail(String? v) {
  final t = (v ?? '').trim();
  if (t.isEmpty) return 'Isi email';
  if (!_emailRe.hasMatch(t)) return 'Format email belum benar';
  return null;
}

/// Untuk login: cukup wajib diisi.
String? validateRequired(String? v, String message) {
  if (v == null || v.trim().isEmpty) return message;
  return null;
}

/// Untuk registrasi: minimal 8 karakter.
String? validateNewPassword(String? v) {
  final t = v ?? '';
  if (t.isEmpty) return 'Isi kata sandi';
  if (t.length < 8) return 'Minimal 8 karakter';
  return null;
}

/// Nomor HP boleh kosong. Kalau diisi harus 9-15 digit.
String? validateOptionalPhone(String? v) {
  final t = (v ?? '').trim();
  if (t.isEmpty) return null;
  if (!_phoneRe.hasMatch(t)) return 'Nomor HP tidak valid';
  return null;
}