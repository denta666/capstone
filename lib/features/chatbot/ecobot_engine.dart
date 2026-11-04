import 'package:flutter/material.dart';
import '../../data/dummy_data.dart';
import '../../data/guide_data.dart';
import '../../models/product.dart';
import 'chat_models.dart';

class EcoBotReply {
  EcoBotReply(this.text, [this.actions = const []]);

  final String text;
  final List<BotAction> actions;
}

/// Jawaban berbasis aturan kata kunci (DUMMY, bukan AI sungguhan).
class EcoBotEngine {
  EcoBotEngine._();

  static const String greeting =
      'Halo! Aku EcoBot, asisten demo EcoHome. Aku bisa menjelaskan langkah umum membuat kompos dan budidaya maggot BSF, membantu soal kendala seperti bau, dan memberi gambaran cara menjual hasil produksi. Mau mulai dari mana?';

  static const List<String> quickQuestions = [
    'Bagaimana cara membuat kompos?',
    'Saya ingin memulai budidaya maggot.',
    'Bagaimana cara mengurangi bau pada kompos?',
    'Bagaimana cara menjual hasil produksi?',
    'Produk apa yang tersedia?',
  ];

  static List<BotAction> get startActions => [
        BotAction.guide(GuideData.compost),
        BotAction.guide(GuideData.maggot),
      ];

  static Product _product(String id) =>
      DummyData.products.firstWhere((p) => p.id == id);

  static EcoBotReply reply(String input) {
    final cleaned =
        input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
    final tokens =
        cleaned.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    bool has(List<String> keys) => keys.any((k) => cleaned.contains(k));

    // ---- Terima kasih ----
    if (has(['terima kasih', 'terimakasih', 'makasih', 'thanks'])) {
      return EcoBotReply(
        'Sama-sama! Kabari aku kalau ada kendala produksi atau pertanyaan lain.',
      );
    }

    // ---- Sapaan ----
    const greets = ['halo', 'hai', 'hi', 'hello', 'pagi', 'siang', 'sore', 'malam'];
    if (tokens.length <= 3 && tokens.any(greets.contains)) {
      return EcoBotReply(
        'Halo! Ada yang bisa aku bantu soal kompos, maggot BSF, atau penjualan hasil produksi?',
        startActions,
      );
    }

    // ---- Bau ----
    if (has(['bau', 'busuk', 'menyengat', 'amis'])) {
      return EcoBotReply(
        'Bau yang menyengat umumnya tanda kondisi perlu disesuaikan. Hal yang bisa dicek: apakah media terlalu basah atau becek, apakah sirkulasi udara cukup, apakah bahan basah terlalu banyak dibanding bahan kering, dan apakah ada bahan yang tidak sesuai dengan metodemu. Setelah itu sesuaikan mengikuti petunjuk metode yang kamu pakai. Kalau bau tetap kuat, tanyakan ke pengelola bank sampah atau pembimbing.',
        [
          BotAction.guideStep(
            GuideData.compost,
            4,
            label: 'Panduan: memantau kompos',
          ),
          BotAction.guideStep(
            GuideData.maggot,
            4,
            label: 'Panduan: memantau maggot',
          ),
        ],
      );
    }

    // ---- Menjual ----
    if (has(['jual', 'menjual', 'dijual', 'penjualan'])) {
      return EcoBotReply(
        'Alur umumnya: pastikan hasil sudah siap (kompos sudah matang, maggot sudah dipanen), timbang dan kemas dengan label tanggal dan jenis, lalu catat berat hasil dan biaya di Catatan Produksi supaya kamu tahu biaya per kg. Setelah itu produk bisa dipasang di marketplace. Fitur menambah produk lewat dashboard penjual masih disiapkan di versi demo ini.',
        [
          BotAction.guideStep(
            GuideData.compost,
            7,
            label: 'Panduan: mengemas hasil',
          ),
          BotAction.tab(2, 'Catatan produksi', Icons.edit_note_rounded),
          BotAction.tab(1, 'Buka Marketplace', Icons.storefront_rounded),
        ],
      );
    }

    // ---- Maggot ----
    if (has(['maggot', 'bsf', 'larva', 'belatung'])) {
      return EcoBotReply(
        'Budidaya maggot BSF umumnya dimulai dengan memahami siklus hidupnya, menyiapkan lokasi dan wadah berventilasi, mendapatkan bibit dari sumber tepercaya, lalu menyiapkan pakan organik dan memantau perkembangan larva. Jenis dan takaran pakan berbeda tiap metode, jadi tanyakan ke penyedia bibit atau pengelola budidaya. Panduan 8 tahapnya bisa dibuka di bawah.',
        [
          BotAction.guide(GuideData.maggot),
          BotAction.guideStep(
            GuideData.maggot,
            0,
            label: 'Mulai: siklus hidup BSF',
          ),
        ],
      );
    }

    // ---- Belanja ----
    if (has(['beli', 'belanja', 'toko', 'produk', 'marketplace'])) {
      return EcoBotReply(
        'Di Marketplace ada kompos, maggot BSF, pupuk organik, dan perlengkapan. Ini beberapa contoh produk (data demo):',
        [
          BotAction.product(_product('p1')),
          BotAction.product(_product('p2')),
          BotAction.product(_product('p4')),
          BotAction.tab(1, 'Lihat semua produk', Icons.storefront_rounded),
        ],
      );
    }

    // ---- Kompos ----
    if (has(['kompos', 'pupuk', 'dekomposer'])) {
      return EcoBotReply(
        'Garis besarnya, membuat kompos terdiri dari beberapa tahap: kenali dan pilah bahan organik, siapkan wadah, campur bahan basah dan kering sesuai metode, pantau kelembapan dan aroma, rawat secara rutin, lalu periksa kematangan sebelum dikemas. Perbandingan bahan dan lama prosesnya berbeda tiap metode, jadi ikuti sumber yang valid. Panduan 8 tahap dengan checklist ada di bawah.',
        [
          BotAction.guide(GuideData.compost),
          BotAction.guideStep(
            GuideData.compost,
            0,
            label: 'Mulai: memilih bahan organik',
          ),
        ],
      );
    }

    // ---- Tidak dikenali ----
    return EcoBotReply(
      'Maaf, aku belum paham pertanyaan itu. Aku masih versi demo berbasis aturan, jadi hanya mengenali topik tertentu. Coba tanyakan tentang cara membuat kompos, memulai budidaya maggot, mengurangi bau, atau menjual hasil produksi.',
    );
  }
}