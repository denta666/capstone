import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../features/account/auth_controller.dart';
import 'dummy_data.dart';

class ProductRepository extends ChangeNotifier {
  ProductRepository._() {
    _products.addAll(DummyData.products);
  }

  static final ProductRepository instance = ProductRepository._();

  final List<Product> _products = [];

  List<Product> get visible =>
      _products.where((product) => product.isListed).toList(growable: false);

  List<Product> get featured => visible.take(6).toList(growable: false);

  List<Product> ownedBy(String email) => _products
      .where((product) => product.ownerEmail == email)
      .toList(growable: false);

  Product? byId(String id) {
    for (final product in _products) {
      if (product.id == id) return product;
    }
    return null;
  }

  void add(Product product) {
    _products.add(product);
    notifyListeners();
  }

  void update(Product product) {
    final index = _products.indexWhere((item) => item.id == product.id);
    if (index < 0) return;
    _products[index] = product;
    notifyListeners();
  }

  void remove(String id) {
    _products.removeWhere((product) => product.id == id);
    notifyListeners();
  }

  String newId() => 'p-${DateTime.now().microsecondsSinceEpoch}';

  String get currentSellerEmail =>
      AuthController.instance.current?.email ?? '';
}