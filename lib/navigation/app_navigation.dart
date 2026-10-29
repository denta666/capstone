import 'package:flutter/foundation.dart';

/// Indeks tab aktif. Ubah nilainya untuk pindah tab dari halaman mana pun.
/// 0 Beranda, 1 Marketplace, 2 Produksi, 3 EcoBot, 4 Akun
final ValueNotifier<int> mainTabIndex = ValueNotifier<int>(0);

/// Kategori yang ingin langsung difilter saat membuka Marketplace
/// (diisi dari Beranda, lalu dikosongkan lagi oleh Marketplace).
final ValueNotifier<String?> marketplaceCategoryFilter =
    ValueNotifier<String?>(null);