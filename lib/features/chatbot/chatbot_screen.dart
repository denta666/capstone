import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/chat_bubble.dart';
import '../../navigation/app_navigation.dart';
import '../marketplace/product_detail_screen.dart';
import '../production/guide_detail_screen.dart';
import '../production/guide_step_screen.dart';
import 'chat_models.dart';
import 'ecobot_engine.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  late List<ChatMessage> _messages;
  bool _typing = false;
  int _session = 0; // naik tiap chat di-reset, supaya balasan lama diabaikan

  @override
  void initState() {
    super.initState();
    _messages = _initial();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  List<ChatMessage> _initial() => [
        ChatMessage(
          text: EcoBotEngine.greeting,
          isUser: false,
          actions: EcoBotEngine.startActions,
        ),
      ];

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _send(String raw) {
    final text = raw.trim();
    if (text.isEmpty || _typing) return;

    final session = _session;
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _typing = true;
    });
    _scrollToEnd();

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted || session != _session) return;
      final r = EcoBotEngine.reply(text);
      setState(() {
        _messages.add(
          ChatMessage(text: r.text, isUser: false, actions: r.actions),
        );
        _typing = false;
      });
      _scrollToEnd();
    });
  }

  void _submit() {
    final t = _controller.text;
    _controller.clear();
    _send(t);
  }

  void _reset() {
    setState(() {
      _session++;
      _typing = false;
      _messages = _initial();
    });
  }

  void _run(BotAction a) {
    final nav = Navigator.of(context);
    switch (a.kind) {
      case BotActionKind.guide:
        nav.push(MaterialPageRoute(
          builder: (_) => GuideDetailScreen(guide: a.guide!),
        ));
      case BotActionKind.guideStep:
        nav.push(MaterialPageRoute(
          builder: (_) =>
              GuideStepScreen(guide: a.guide!, index: a.stepIndex!),
        ));
      case BotActionKind.product:
        nav.push(MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: a.product!),
        ));
      case BotActionKind.tab:
        mainTabIndex.value = a.tabIndex!;
    }
  }

  Widget _messageTile(ChatMessage m) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
            m.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ChatBubble(text: m.text, isUser: m.isUser),
          if (m.actions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final a in m.actions)
                  _ActionButton(action: a, onTap: () => _run(a)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primarySoft,
              child: Icon(
                Icons.smart_toy_rounded,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EcoBot',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                Text(
                  'Asisten produksi (demo)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Mulai ulang',
            onPressed: _reset,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.primarySoft,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: const Text(
              'Demo: jawaban EcoBot berasal dari aturan sederhana dan belum terhubung ke AI sungguhan. Isinya bersifat umum, bukan pengganti panduan metode atau saran ahli.',
              style: TextStyle(
                fontSize: 11,
                height: 1.35,
                color: AppColors.primary,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              itemCount: _messages.length + (_typing ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == _messages.length) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: ChatBubble(
                      text: 'EcoBot sedang mengetik...',
                      isUser: false,
                    ),
                  );
                }
                return _messageTile(_messages[i]);
              },
            ),
          ),

          // ---------- Pertanyaan cepat ----------
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: EcoBotEngine.quickQuestions.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final q = EcoBotEngine.quickQuestions[i];
                return ActionChip(
                  label: Text(q),
                  onPressed: _typing ? null : () => _send(q),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.border),
                  shape: const StadiumBorder(),
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                );
              },
            ),
          ),

          // ---------- Input ----------
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _submit(),
                        minLines: 1,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Tulis pertanyaanmu...',
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          filled: true,
                          fillColor: AppColors.background,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _typing ? null : _submit,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(46, 46),
                      ),
                      icon: const Icon(Icons.send_rounded, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action, required this.onTap});

  final BotAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.primary),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(action.icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    action.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}