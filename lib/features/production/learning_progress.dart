import 'package:flutter/foundation.dart';
import '../../models/guide.dart';

/// Progres belajar lokal (di memori, hilang saat aplikasi ditutup).
class LearningProgress extends ChangeNotifier {
  LearningProgress._();
  static final LearningProgress instance = LearningProgress._();

  final Set<String> _checked = {};
  String? lastGuideId;

  String _key(Guide g, int step, int item) => '${g.id}:$step:$item';

  bool isChecked(Guide g, int step, int item) =>
      _checked.contains(_key(g, step, item));

  void toggle(Guide g, int step, int item) {
    final k = _key(g, step, item);
    if (!_checked.add(k)) _checked.remove(k);
    lastGuideId = g.id;
    notifyListeners();
  }

  void completeStep(Guide g, int step) {
    for (var i = 0; i < g.steps[step].checklist.length; i++) {
      _checked.add(_key(g, step, i));
    }
    lastGuideId = g.id;
    notifyListeners();
  }

  int checkedInStep(Guide g, int step) {
    var n = 0;
    for (var i = 0; i < g.steps[step].checklist.length; i++) {
      if (isChecked(g, step, i)) n++;
    }
    return n;
  }

  bool isStepDone(Guide g, int step) =>
      checkedInStep(g, step) == g.steps[step].checklist.length;

  int stepsDone(Guide g) {
    var n = 0;
    for (var i = 0; i < g.steps.length; i++) {
      if (isStepDone(g, i)) n++;
    }
    return n;
  }

  int _totalItems(Guide g) =>
      g.steps.fold(0, (sum, s) => sum + s.checklist.length);

  int _checkedTotal(Guide g) {
    var n = 0;
    for (var i = 0; i < g.steps.length; i++) {
      n += checkedInStep(g, i);
    }
    return n;
  }

  /// 0.0 - 1.0, dihitung dari jumlah checklist yang dicentang.
  double progress(Guide g) {
    final total = _totalItems(g);
    return total == 0 ? 0 : _checkedTotal(g) / total;
  }

  bool started(Guide g) => _checkedTotal(g) > 0;
  bool isFinished(Guide g) => stepsDone(g) == g.steps.length;

  /// Tahap pertama yang belum selesai (atau tahap terakhir kalau semua selesai).
  int nextStepIndex(Guide g) {
    for (var i = 0; i < g.steps.length; i++) {
      if (!isStepDone(g, i)) return i;
    }
    return g.steps.length - 1;
  }
}