import 'package:flutter/material.dart';
import '../models/product.dart';

/// Semua data di sini DUMMY untuk demo UI. Bukan data penjual sungguhan.
class DummyData {
  DummyData._();

  static const List<ProductCategory> categories = [
    ProductCategory(name: 'Kompos', icon: Icons.grass_rounded),
    ProductCategory(name: 'Maggot BSF', icon: Icons.bug_report_rounded),
    ProductCategory(name: 'Pupuk Organik', icon: Icons.local_florist_rounded),
    ProductCategory(name: 'Perlengkapan', icon: Icons.handyman_rounded),
  ];

  static const List<Product> products = [
    Product(
      id: 'p1',
      name: 'Kompos Organik Premium',
      category: 'Kompos',
      price: 45000,
      unit: 'karung 5 kg',
      rating: 4.8,
      reviews: 126,
      stock: 40,
      seller: 'Bank Sampah Hijau Lestari',
      location: 'Kab. Tegal',
      description:
          'Kompos matang dari sisa sayur dan daun, bertekstur remah dan tidak berbau menyengat. Data dummy untuk demo.',
      icon: Icons.grass_rounded,
    ),
    Product(
      id: 'p2',
      name: 'Maggot BSF Fresh',
      category: 'Maggot BSF',
      price: 28000,
      unit: 'kemasan 1 kg',
      rating: 4.7,
      reviews: 88,
      stock: 25,
      seller: 'Griya Maggot Mandiri',
      location: 'Kota Semarang',
      description:
          'Larva BSF segar untuk pakan ternak kecil, ikan, dan unggas. Data dummy untuk demo.',
      icon: Icons.bug_report_rounded,
    ),
    Product(
      id: 'p3',
      name: 'Maggot BSF Kering',
      category: 'Maggot BSF',
      price: 55000,
      unit: 'kemasan 500 g',
      rating: 4.6,
      reviews: 64,
      stock: 18,
      seller: 'Griya Maggot Mandiri',
      location: 'Kota Semarang',
      description:
          'Larva BSF yang sudah dikeringkan, tahan disimpan lebih lama. Data dummy untuk demo.',
      icon: Icons.bug_report_rounded,
    ),
    Product(
      id: 'p4',
      name: 'Pupuk Kompos Organik',
      category: 'Pupuk Organik',
      price: 70000,
      unit: 'karung 10 kg',
      rating: 4.9,
      reviews: 203,
      stock: 52,
      seller: 'Tani Lestari',
      location: 'Kota Bandung',
      description:
          'Pupuk kompos untuk tanaman sayur dan buah di pot maupun kebun. Data dummy untuk demo.',
      icon: Icons.local_florist_rounded,
    ),
    Product(
      id: 'p5',
      name: 'Pupuk Organik Cair (POC)',
      category: 'Pupuk Organik',
      price: 25000,
      unit: 'botol 1 L',
      rating: 4.5,
      reviews: 47,
      stock: 33,
      seller: 'Eco Garden',
      location: 'Kab. Brebes',
      description:
          'Pupuk cair dari fermentasi sisa organik, dipakai dengan pengenceran sesuai petunjuk. Data dummy untuk demo.',
      icon: Icons.water_drop_rounded,
    ),
    Product(
      id: 'p6',
      name: 'Kasgot (Sisa Maggot)',
      category: 'Pupuk Organik',
      price: 30000,
      unit: 'karung 5 kg',
      rating: 4.4,
      reviews: 29,
      stock: 60,
      seller: 'Griya Maggot Mandiri',
      location: 'Kota Semarang',
      description:
          'Sisa media budidaya maggot yang bisa dimanfaatkan sebagai pupuk. Data dummy untuk demo.',
      icon: Icons.spa_rounded,
    ),
    Product(
      id: 'p7',
      name: 'Komposter Ember 20 L',
      category: 'Perlengkapan',
      price: 85000,
      unit: 'per unit',
      rating: 4.7,
      reviews: 71,
      stock: 14,
      seller: 'Eco Garden',
      location: 'Kab. Brebes',
      description:
          'Ember komposter berpenutup untuk skala rumah tangga. Data dummy untuk demo.',
      icon: Icons.inventory_2_rounded,
    ),
    Product(
      id: 'p8',
      name: 'Starter Dekomposer',
      category: 'Perlengkapan',
      price: 18000,
      unit: 'botol 250 ml',
      rating: 4.3,
      reviews: 35,
      stock: 45,
      seller: 'Tani Lestari',
      location: 'Kota Bandung',
      description:
          'Starter pembantu penguraian bahan organik. Data dummy untuk demo.',
      icon: Icons.science_rounded,
    ),
  ];

  static List<Product> get featured => products.take(6).toList();
}