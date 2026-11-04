enum UserRole { pembeli, penjual }

extension UserRoleX on UserRole {
  String get label => switch (this) {
        UserRole.pembeli => 'Pembeli',
        UserRole.penjual => 'Penjual / Mitra',
      };
}

class UserAccount {
  const UserAccount({
    required this.name,
    required this.email,
    required this.role,
    this.phone = '',
    this.address = '',
  });

  final String name;
  final String email;
  final UserRole role;
  final String phone;
  final String address;

  UserAccount copyWith({String? name, String? phone, String? address}) {
    return UserAccount(
      name: name ?? this.name,
      email: email,
      role: role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
}