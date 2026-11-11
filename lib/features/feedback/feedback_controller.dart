import 'package:flutter/foundation.dart';
import '../../models/app_feedback.dart';

/// Feedback aplikasi yang disimpan lokal (di memori). Belum terkirim ke
/// server mana pun; akan hilang saat aplikasi ditutup.
class FeedbackController extends ChangeNotifier {
  FeedbackController._();

  static final FeedbackController instance = FeedbackController._();

  final List<AppFeedback> _items = [];

  /// Feedback milik [email], yang terbaru di urutan pertama.
  List<AppFeedback> mine(String email) => _items
      .where((item) => item.email == email)
      .toList(growable: false)
      .reversed
      .toList(growable: false);

  String newId() => 'fb-${DateTime.now().microsecondsSinceEpoch}';

  void submit(AppFeedback feedback) {
    _items.add(feedback);
    notifyListeners();
  }
}