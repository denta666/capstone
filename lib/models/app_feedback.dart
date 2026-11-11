enum FeedbackCategory { saran, masalah, fitur, lainnya }

extension FeedbackCategoryX on FeedbackCategory {
  String get label => switch (this) {
        FeedbackCategory.saran => 'Saran',
        FeedbackCategory.masalah => 'Ada masalah',
        FeedbackCategory.fitur => 'Usul fitur',
        FeedbackCategory.lainnya => 'Lainnya',
      };
}

class AppFeedback {
  const AppFeedback({
    required this.id,
    required this.email,
    required this.rating,
    required this.category,
    required this.message,
    required this.createdAt,
    this.screenshotPath,
  });

  final String id;

  /// Email pengirim. Kosong kalau dikirim tanpa masuk akun (tamu).
  final String email;

  /// Penilaian 1 sampai 5.
  final int rating;
  final FeedbackCategory category;
  final String message;
  final DateTime createdAt;

  /// Path tangkapan layar (opsional).
  final String? screenshotPath;
}