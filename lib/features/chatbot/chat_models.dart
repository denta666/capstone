import 'package:flutter/material.dart';
import '../../core/utils/format.dart';
import '../../models/guide.dart';
import '../../models/product.dart';

enum BotActionKind { guide, guideStep, product, tab }

/// Tombol rekomendasi di bawah jawaban EcoBot.
class BotAction {
  BotAction.guide(Guide g, {String? label})
      : kind = BotActionKind.guide,
        label = label ?? g.title,
        icon = g.icon,
        guide = g,
        stepIndex = null,
        product = null,
        tabIndex = null;

  BotAction.guideStep(Guide g, int step, {String? label})
      : kind = BotActionKind.guideStep,
        label = label ?? 'Tahap ${step + 1}: ${g.steps[step].title}',
        icon = g.steps[step].icon,
        guide = g,
        stepIndex = step,
        product = null,
        tabIndex = null;

  BotAction.product(Product p)
      : kind = BotActionKind.product,
        label = '${p.name} • ${formatRupiah(p.price)}',
        icon = p.icon,
        guide = null,
        stepIndex = null,
        product = p,
        tabIndex = null;

  BotAction.tab(int index, this.label, this.icon)
      : kind = BotActionKind.tab,
        guide = null,
        stepIndex = null,
        product = null,
        tabIndex = index;

  final BotActionKind kind;
  final String label;
  final IconData icon;
  final Guide? guide;
  final int? stepIndex;
  final Product? product;
  final int? tabIndex;
}

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.isUser,
    this.actions = const [],
  });

  final String text;
  final bool isUser;
  final List<BotAction> actions;
}