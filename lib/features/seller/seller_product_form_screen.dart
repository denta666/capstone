import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/dummy_data.dart';
import '../../data/product_repository.dart';
import '../../models/product.dart';
import '../account/auth_controller.dart';

class SellerProductFormScreen extends StatefulWidget {
  const SellerProductFormScreen({super.key, this.product});

  final Product? product;

  @override
  State<SellerProductFormScreen> createState() => _SellerProductFormScreenState();
}

class _SellerProductFormScreenState extends State<SellerProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _unit;
  late final TextEditingController _stock;
  late final TextEditingController _location;
  late final TextEditingController _description;
  late String _category;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _name = TextEditingController(text: product?.name ?? '');
    _price = TextEditingController(text: product?.price.toString() ?? '');
    _unit = TextEditingController(text: product?.unit ?? '');
    _stock = TextEditingController(text: product?.stock.toString() ?? '');
    _location = TextEditingController(text: product?.location ?? '');
    _description = TextEditingController(text: product?.description ?? '');
    _category = product?.category ?? DummyData.categories.first.name;
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _unit.dispose();
    _stock.dispose();
    _location.dispose();
    _description.dispose();
    super.dispose();
  }

  String? _required(String? value) => value == null || value.trim().isEmpty ? 'Wajib diisi' : null;

  String? _positiveInt(String? value) {
    final number = int.tryParse(value ?? '');
    return number == null || number < 0 ? 'Masukkan angka yang valid' : null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final old = widget.product;
    final email = AuthController.instance.current?.email ?? '';
    final user = AuthController.instance.current;
    final category = DummyData.categories.firstWhere((item) => item.name == _category);
    final product = Product(
      id: old?.id ?? ProductRepository.instance.newId(),
      name: _name.text.trim(),
      category: _category,
      price: int.parse(_price.text),
      unit: _unit.text.trim(),
      rating: old?.rating ?? 0,
      reviews: old?.reviews ?? 0,
      stock: int.parse(_stock.text),
      seller: old?.seller ?? user?.name ?? 'Penjual',
      location: _location.text.trim(),
      description: _description.text.trim(),
      icon: category.icon,
      imagePath: old?.imagePath,
      ownerEmail: old?.ownerEmail ?? email,
      isActive: old?.isActive ?? true,
    );
    if (old == null) {
      ProductRepository.instance.add(product);
    } else {
      ProductRepository.instance.update(product);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.product != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Ubah Produk' : 'Tambah Produk')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Nama produk'), validator: _required),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Kategori'),
              items: [for (final item in DummyData.categories) DropdownMenuItem(value: item.name, child: Text(item.name))],
              onChanged: (value) => setState(() => _category = value!),
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga (Rp)'), validator: _positiveInt),
            const SizedBox(height: 12),
            TextFormField(controller: _unit, decoration: const InputDecoration(labelText: 'Satuan'), validator: _required),
            const SizedBox(height: 12),
            TextFormField(controller: _stock, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stok'), validator: _positiveInt),
            const SizedBox(height: 12),
            TextFormField(controller: _location, decoration: const InputDecoration(labelText: 'Lokasi'), validator: _required),
            const SizedBox(height: 12),
            TextFormField(controller: _description, minLines: 3, maxLines: 5, decoration: const InputDecoration(labelText: 'Deskripsi'), validator: _required),
            const SizedBox(height: 22),
            PrimaryButton(label: editing ? 'Simpan Perubahan' : 'Tambah Produk', icon: Icons.save_outlined, onPressed: _save),
            const SizedBox(height: 10),
            const Text('Produk yang aktif dan memiliki stok akan ditampilkan di marketplace.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}