import 'package:flutter/material.dart';
import '../models/guide.dart';

/// Konten panduan bersifat umum. Parameter teknis (suhu, kelembapan,
/// takaran, durasi) berbeda tiap metode, jadi tidak ditetapkan di sini.
class GuideData {
  GuideData._();

  static const Guide compost = Guide(
    id: 'compost',
    title: 'Produksi Kompos',
    subtitle: 'Ubah sisa sayur dan daun jadi kompos',
    description:
        'Belajar membuat kompos dari sisa dapur dan daun kering, dari memilih bahan sampai mengemas hasil untuk dijual.',
    difficulty: 'Mudah',
    duration: 'Beberapa minggu - bulan (tergantung metode)',
    icon: Icons.grass_rounded,
    tools: [
      'Wadah atau komposter sesuai metode',
      'Bahan organik basah (sisa sayur, kulit buah)',
      'Bahan organik kering (daun kering, dan sejenisnya)',
      'Alat pengaduk dan sarung tangan',
      'Penutup wadah',
      'Timbangan dan buku catatan',
    ],
    steps: [
      GuideStep(
        title: 'Mengenal dan memilih bahan organik',
        description:
            'Kenali bahan yang cocok dan tidak cocok untuk dikomposkan sebelum mulai.',
        icon: Icons.search_rounded,
        checklist: [
          'Kenali bahan basah, misalnya sisa sayur dan kulit buah',
          'Kenali bahan kering, misalnya daun kering',
          'Catat bahan organik yang tersedia di rumahmu',
          'Pisahkan bahan yang tidak boleh masuk: plastik, logam, kaca, puntung rokok',
        ],
        tips: [
          'Mulai dari bahan yang paling mudah kamu dapatkan setiap hari.',
          'Pilih satu metode dulu, lalu ikuti aturan metode itu dengan konsisten.',
        ],
        warning:
            'Bahan yang tidak sesuai metode bisa menimbulkan bau atau mengundang hama. Cek aturan bahan pada metode yang kamu pilih.',
      ),
      GuideStep(
        title: 'Menyiapkan alat dan wadah',
        description:
            'Siapkan wadah dan perlengkapan sesuai skala dan metode yang dipilih.',
        icon: Icons.inventory_2_rounded,
        checklist: [
          'Pilih metode (misalnya komposter ember atau tumpukan) sesuai ruang',
          'Siapkan wadah dengan aliran udara dan pembuangan air sesuai metode',
          'Siapkan alat pengaduk, sarung tangan, dan penutup',
          'Tentukan lokasi yang terlindung dari hujan dan mudah dijangkau',
        ],
        tips: [
          'Skala kecil dulu lebih mudah dipantau untuk pemula.',
          'Letakkan di tempat yang tidak mengganggu tetangga.',
        ],
      ),
      GuideStep(
        title: 'Memilah dan menyiapkan bahan',
        description:
            'Bahan yang sudah dipilah dan diperkecil ukurannya lebih mudah terurai.',
        icon: Icons.content_cut_rounded,
        checklist: [
          'Pisahkan bahan organik dari sampah anorganik',
          'Cacah bahan menjadi potongan kecil',
          'Tiriskan bahan yang terlalu basah',
          'Kelompokkan bahan basah dan kering di wadah terpisah',
        ],
        tips: [
          'Timbang bahan masuk agar bisa dicatat di Catatan Produksi.',
        ],
      ),
      GuideStep(
        title: 'Mencampurkan bahan sesuai metode',
        description:
            'Campur atau susun bahan mengikuti metode yang kamu pilih.',
        icon: Icons.layers_rounded,
        checklist: [
          'Susun atau campur bahan sesuai petunjuk metode',
          'Sesuaikan perbandingan bahan basah dan kering menurut metode',
          'Tambahkan starter atau dekomposer jika metodenya memakai',
          'Tutup wadah atau tumpukan',
        ],
        tips: [
          'Tulis tanggal mulai pada wadah.',
          'Foto kondisi awal untuk dokumentasi.',
        ],
        warning:
            'Perbandingan bahan berbeda tiap metode. Ikuti sumber yang valid, bukan perkiraan.',
      ),
      GuideStep(
        title: 'Memantau kelembapan, suhu, aroma, dan penguraian',
        description:
            'Pantau kondisi secara berkala dan catat perubahannya.',
        icon: Icons.monitor_heart_rounded,
        checklist: [
          'Periksa kelembapan: media lembap tetapi tidak becek',
          'Perhatikan aroma dan catat perubahannya',
          'Amati suhu dan tanda penguraian bahan',
          'Catat hasil pengamatan di Catatan Produksi',
        ],
        tips: [
          'Pantau pada jam yang sama supaya perbandingannya adil.',
          'Foto berkala memudahkan kamu melihat perkembangan.',
        ],
        warning:
            'Bau menyengat atau media terlalu becek menandakan kondisi perlu disesuaikan. Tanyakan ke EcoBot atau ikuti panduan metodemu.',
      ),
      GuideStep(
        title: 'Melakukan perawatan sesuai metode',
        description:
            'Lakukan perawatan rutin agar proses berjalan baik.',
        icon: Icons.autorenew_rounded,
        checklist: [
          'Aduk atau balik sesuai jadwal metode',
          'Tambahkan bahan kering jika terlalu basah, atau sedikit air jika terlalu kering',
          'Jaga dari hama dan hewan pengganggu',
          'Lindungi dari hujan langsung',
        ],
        tips: [
          'Buat jadwal pengingat agar perawatan tidak terlewat.',
        ],
      ),
      GuideStep(
        title: 'Memeriksa kematangan kompos',
        description:
            'Pastikan kompos benar-benar matang sebelum dipakai atau dijual.',
        icon: Icons.fact_check_rounded,
        checklist: [
          'Periksa warna, tekstur, dan aroma',
          'Pastikan bahan asal sudah tidak dikenali',
          'Bandingkan dengan kriteria kematangan pada metode yang kamu pakai',
          'Jika ragu, diamkan lebih lama dan periksa lagi',
        ],
        tips: [
          'Minta pendapat pengelola bank sampah atau pembimbing jika belum yakin.',
        ],
        warning:
            'Kompos yang belum matang bisa merugikan tanaman jika dipakai terlalu cepat.',
      ),
      GuideStep(
        title: 'Mengemas dan mencatat hasil produksi',
        description:
            'Rapikan hasil dan catat data produksi untuk perbaikan berikutnya.',
        icon: Icons.inventory_rounded,
        checklist: [
          'Pisahkan bagian yang masih kasar',
          'Timbang hasil akhir',
          'Kemas dengan label tanggal dan jenis',
          'Catat berat hasil, biaya, dan catatan untuk produksi berikutnya',
        ],
        tips: [
          'Hasil yang sudah dikemas bisa dijual lewat Marketplace EcoHome.',
        ],
      ),
    ],
  );

  static const Guide maggot = Guide(
    id: 'maggot',
    title: 'Budidaya Maggot BSF',
    subtitle: 'Olah sisa makanan dengan larva BSF',
    description:
        'Belajar membudidayakan maggot BSF untuk mengolah sampah organik, dari mengenal siklus hidup sampai menyiapkan hasil untuk dijual.',
    difficulty: 'Sedang',
    duration: 'Beberapa minggu per siklus (tergantung kondisi)',
    icon: Icons.bug_report_rounded,
    tools: [
      'Wadah budidaya dengan ventilasi',
      'Bibit dari sumber tepercaya',
      'Sampah organik sebagai pakan',
      'Alat pemilah dan pemanen',
      'Timbangan dan buku catatan',
      'Sarung tangan dan penutup wadah',
    ],
    steps: [
      GuideStep(
        title: 'Mengenal siklus hidup BSF',
        description:
            'Pahami tahap perkembangan BSF supaya tahu apa yang perlu dilakukan di tiap tahap.',
        icon: Icons.cached_rounded,
        checklist: [
          'Pelajari tahapnya: telur, larva, prepupa, pupa, lalat dewasa',
          'Pahami peran tiap tahap dalam budidaya',
          'Tentukan tujuanmu: mengolah sampah, pakan, atau dijual',
        ],
        tips: [
          'Gambar siklus hidup yang ditempel di dekat wadah memudahkan pengamatan.',
        ],
      ),
      GuideStep(
        title: 'Menyiapkan lokasi dan wadah',
        description:
            'Lokasi dan wadah yang tepat mengurangi bau dan gangguan.',
        icon: Icons.home_work_rounded,
        checklist: [
          'Pilih lokasi teduh dan terlindung dari hujan',
          'Siapkan wadah dengan ventilasi sesuai skala',
          'Siapkan pengaman agar larva tidak keluar dan hewan lain tidak masuk',
          'Pastikan lokasi tidak mengganggu tetangga',
        ],
        tips: [
          'Mulai dari skala kecil sampai kamu paham ritmenya.',
        ],
      ),
      GuideStep(
        title: 'Memperoleh bibit dari sumber tepercaya',
        description:
            'Kualitas bibit sangat memengaruhi hasil budidaya.',
        icon: Icons.verified_rounded,
        checklist: [
          'Cari sumber bibit tepercaya (komunitas atau penyedia budidaya)',
          'Tanyakan umur bibit dan cara penanganannya',
          'Siapkan wadah penerimaan sebelum bibit datang',
          'Catat tanggal dan jumlah bibit',
        ],
        tips: [
          'Tanyakan juga panduan pakan awal dari penyedia bibit.',
        ],
      ),
      GuideStep(
        title: 'Menyiapkan pakan organik yang sesuai',
        description:
            'Pakan yang sesuai menjaga larva sehat dan bau terkendali.',
        icon: Icons.restaurant_rounded,
        checklist: [
          'Siapkan sampah organik sesuai anjuran metode',
          'Cacah atau haluskan jika diperlukan',
          'Hindari bahan non-organik, plastik, dan puntung rokok',
          'Catat jenis pakan yang diberikan',
        ],
        tips: [
          'Pakan yang lebih halus umumnya lebih mudah diolah larva.',
        ],
        warning:
            'Jenis pakan dan takarannya berbeda tiap metode. Ikuti sumber yang valid.',
      ),
      GuideStep(
        title: 'Memantau media dan perkembangan larva',
        description:
            'Pantau kondisi media dan pertumbuhan larva secara rutin.',
        icon: Icons.visibility_rounded,
        checklist: [
          'Amati aktivitas dan ukuran larva',
          'Periksa kelembapan media',
          'Perhatikan aroma dan catat perubahannya',
          'Catat hasil pengamatan di Catatan Produksi',
        ],
        tips: [
          'Menimbang sampel larva secara berkala membantu melihat pertumbuhan.',
        ],
        warning:
            'Bau menyengat atau larva berkurang aktif menandakan kondisi perlu dicek. Tanyakan ke EcoBot atau pengelola budidaya.',
      ),
      GuideStep(
        title: 'Merawat dan mengelola pakan',
        description:
            'Atur pemberian pakan dan jaga kebersihan wadah.',
        icon: Icons.cleaning_services_rounded,
        checklist: [
          'Beri pakan bertahap sesuai kemampuan larva',
          'Hindari menumpuk pakan berlebih',
          'Angkat sisa pakan yang tidak habis',
          'Jaga kebersihan wadah dan cuci tangan setelah menangani',
        ],
        tips: [
          'Catat jam dan jumlah pakan agar polanya mudah dievaluasi.',
        ],
      ),
      GuideStep(
        title: 'Memanen sesuai tujuan pemanfaatan',
        description:
            'Waktu dan cara panen menyesuaikan tujuan: segar, kering, atau bibit.',
        icon: Icons.agriculture_rounded,
        checklist: [
          'Tentukan tujuan panen: segar, kering, atau bibit',
          'Pisahkan larva dari media dengan cara sesuai metode',
          'Sisihkan sebagian untuk siklus berikutnya jika ingin berkelanjutan',
          'Timbang hasil panen',
        ],
        tips: [
          'Catat berat hasil panen untuk menghitung efisiensi.',
        ],
      ),
      GuideStep(
        title: 'Menangani residu dan menyiapkan hasil untuk dijual',
        description:
            'Manfaatkan sisa media dan kemas hasil dengan rapi.',
        icon: Icons.sell_rounded,
        checklist: [
          'Kumpulkan sisa media (kasgot) dan manfaatkan sesuai metode',
          'Kemas hasil dengan label tanggal',
          'Catat biaya dan hasil produksi',
          'Siapkan produk untuk dijual di Marketplace EcoHome',
        ],
        tips: [
          'Kasgot juga bisa dijual sebagai produk tambahan.',
        ],
      ),
    ],
  );

  static const List<Guide> all = [compost, maggot];
}