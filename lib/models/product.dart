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
}