import 'package:flutter/foundation.dart';
import '../../models/seller_application.dart';
import '../../models/user_account.dart';
import '../cart/cart_controller.dart';

class _Credential {
  _Credential(this.password, this.account);

  final String password;
  UserAccount account;
}

/// Autentikasi SIMULASI lokal (di memori). Bukan sistem login produksi:
/// kata sandi tidak di-hash dan semua data hilang saat aplikasi ditutup.
class AuthController extends ChangeNotifier {
  AuthController._() {
    _users[demoBuyerEmail] = _Credential(
      demoBuyerPassword,
      const UserAccount(
        name: 'Pengguna Demo',
        email: demoBuyerEmail,
        role: UserRole.pembeli,
      ),
    );
    _users[demoSellerEmail] = _Credential(
      demoSellerPassword,
      const UserAccount(
        name: 'Mitra Demo',
        email: demoSellerEmail,
        role: UserRole.penjual,
      ),
    );
  }

  static final AuthController instance = AuthController._();

  static const demoBuyerEmail = 'demo@ecohome.id';
  static const demoBuyerPassword = 'demo1234';
  static const demoSellerEmail = 'mitra@ecohome.id';
  static const demoSellerPassword = 'mitra1234';

  final Map<String, _Credential> _users = {};
  final Map<String, SellerApplication> _applications = {};
  UserAccount? _current;

  UserAccount? get current => _current;
  bool get isLoggedIn => _current != null;
  bool get isSeller => _current?.role == UserRole.penjual;

  SellerApplication? applicationOf(String email) => _applications[email];

  /// Mengembalikan pesan error, atau null kalau berhasil.
  String? login(String email, String password) {
    final c = _users[email.trim().toLowerCase()];
    if (c == null || c.password != password) {
      return 'Email atau kata sandi salah';
    }
    _current = c.account;
    notifyListeners();
    return null;
  }

  /// Semua akun baru adalah Pembeli. Untuk menjadi penjual, pengguna harus
  /// mengajukan lewat formulir (lihat [submitSellerApplication]).
  /// Mengembalikan pesan error, atau null kalau berhasil (langsung masuk).
  String? register({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) {
    final key = email.trim().toLowerCase();
    if (_users.containsKey(key)) return 'Email sudah terdaftar';

    final account = UserAccount(
      name: name.trim(),
      email: key,
      role: UserRole.pembeli,
      phone: phone.trim(),
    );
    _users[key] = _Credential(password, account);
    _current = account;
    notifyListeners();
    return null;
  }

  void logout() {
    // Keranjang hanya untuk pengguna yang login, jadi dikosongkan saat keluar.
    CartController.instance.clear();
    _current = null;
    notifyListeners();
  }

  void updateProfile({
    required String name,
    required String phone,
    required String address,
  }) {
    final cur = _current;
    if (cur == null) return;
    final updated = cur.copyWith(
      name: name.trim(),
      phone: phone.trim(),
      address: address.trim(),
    );
    _current = updated;
    final c = _users[cur.email];
    if (c != null) c.account = updated;
    notifyListeners();
  }

  /// Mengirim pengajuan menjadi penjual / mitra.
  /// Mengembalikan pesan error, atau null kalau berhasil.
  String? submitSellerApplication(SellerApplication application) {
    final cur = _current;
    if (cur == null) return 'Masuk dulu untuk mengajukan';
    if (cur.role == UserRole.penjual) {
      return 'Akunmu sudah terdaftar sebagai penjual';
    }
    final existing = _applications[cur.email];
    if (existing != null && existing.status == ApplicationStatus.menunggu) {
      return 'Pengajuanmu masih menunggu verifikasi';
    }

    _applications[cur.email] = application;

    // Lengkapi nomor HP di profil kalau masih kosong.
    if (cur.phone.isEmpty) {
      final updated = cur.copyWith(phone: application.phone);
      _current = updated;
      final c = _users[cur.email];
      if (c != null) c.account = updated;
    }
    notifyListeners();
    return null;
  }

  /// HANYA UNTUK DEMO: menggantikan admin yang memverifikasi pengajuan.
  /// Di sistem nyata keputusan ini dibuat admin di server.
  void demoDecideApplication(String email, {required bool approve}) {
    final a = _applications[email];
    if (a == null) return;

    if (approve) {
      _applications[email] = a.copyWith(status: ApplicationStatus.disetujui);
      final c = _users[email];
      if (c != null) {
        final updated = c.account.copyWith(role: UserRole.penjual);
        c.account = updated;
        if (_current?.email == email) _current = updated;
      }
    } else {
      _applications[email] = a.copyWith(
        status: ApplicationStatus.ditolak,
        rejectionNote:
            'Contoh alasan (simulasi): informasi usaha belum memenuhi syarat. Lengkapi lalu ajukan kembali.',
      );
    }
    notifyListeners();
  }
}