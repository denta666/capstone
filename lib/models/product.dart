import 'package:flutter/material.dart';

class ProductCategory {
  const ProductCategory({required this.name, required this.icon});

  final String name;
  final IconData icon;
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    required this.rating,
    required this.reviews,
    required this.stock,
    required this.seller,
    required this.location,
    required this.description,
    required this.icon,
    this.imagePath,
    this.ownerEmail,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String category;
  final int price; // rupiah
  final String unit;
  final double rating;
  final int reviews;
  final int stock;
  final String seller;
  final String location;
  final String description;
  final IconData icon;

  /// Path aset lokal (opsional). Kalau null, tampil placeholder.
  final String? imagePath;

  /// Email akun penjual pemilik produk. Null = produk contoh tanpa pemilik.
  final String? ownerEmail;

  /// Produk nonaktif tidak tampil di marketplace.
  final bool isActive;

  /// Tampil di marketplace: aktif dan masih ada stok.
  bool get isListed => isActive && stock > 0;

  Product copyWith({
    String? name,
    String? category,
    int? price,
    String? unit,
    int? stock,
    String? seller,
    String? location,
    String? description,
    IconData? icon,
    String? ownerEmail,
    bool? isActive,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      rating: rating,
      reviews: reviews,
      stock: stock ?? this.stock,
      seller: seller ?? this.seller,
      location: location ?? this.location,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      imagePath: imagePath,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      isActive: isActive ?? this.isActive,
    );
  }
}