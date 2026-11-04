import 'package:flutter/foundation.dart';
import '../../models/user_account.dart';

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
  UserAccount? _current;

  UserAccount? get current => _current;
  bool get isLoggedIn => _current != null;
  bool get isSeller => _current?.role == UserRole.penjual;

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

  /// Mengembalikan pesan error, atau null kalau berhasil (langsung masuk).
  String? register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String phone = '',
  }) {
    final key = email.trim().toLowerCase();
    if (_users.containsKey(key)) return 'Email sudah terdaftar';

    final account = UserAccount(
      name: name.trim(),
      email: key,
      role: role,
      phone: phone.trim(),
    );
    _users[key] = _Credential(password, account);
    _current = account;
    notifyListeners();
    return null;
  }

  void logout() {
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
}