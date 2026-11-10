enum ApplicationStatus { menunggu, disetujui, ditolak }

extension ApplicationStatusX on ApplicationStatus {
  String get label => switch (this) {
        ApplicationStatus.menunggu => 'Menunggu verifikasi',
        ApplicationStatus.disetujui => 'Disetujui',
        ApplicationStatus.ditolak => 'Ditolak',
      };
}

class SellerApplication {
  const SellerApplication({
    required this.email,
    required this.storeName,
    required this.productTypes,
    required this.source,
    required this.city,
    required this.address,
    required this.phone,
    required this.description,
    required this.submittedAt,
    required this.status,
    this.rejectionNote,
  });

  final String email;
  final String storeName;
  final List<String> productTypes;
  final String source;
  final String city;
  final String address;
  final String phone;
  final String description;
  final DateTime submittedAt;
  final ApplicationStatus status;
  final String? rejectionNote;

  SellerApplication copyWith({
    ApplicationStatus? status,
    String? rejectionNote,
  }) {
    return SellerApplication(
      email: email,
      storeName: storeName,
      productTypes: productTypes,
      source: source,
      city: city,
      address: address,
      phone: phone,
      description: description,
      submittedAt: submittedAt,
      status: status ?? this.status,
      rejectionNote: rejectionNote ?? this.rejectionNote,
    );
  }
}