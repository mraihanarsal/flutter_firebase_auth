import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/features/dashboard/data/models/product_model.dart';
import 'package:flutter_firebase_auth/features/dashboard/presentation/providers/product_provider.dart';
import 'package:flutter_firebase_auth/services/notification_service.dart';
import 'package:provider/provider.dart';

class ProductFormPage extends StatefulWidget {
  final ProductModel? product;

  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  String _category = 'Mobil PC';

  final List<String> _categories = [
    'Mobil PC',
    'Mobil SUV',
    'Motor Matic',
    'Motor Bebek',
    'Motor Sport',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameCtrl.text = widget.product!.name;
      _descCtrl.text = widget.product!.description;
      _priceCtrl.text = widget.product!.price.toString();
      _imageCtrl.text = widget.product!.imageUrl;
      if (_categories.contains(widget.product!.category)) {
        _category = widget.product!.category;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': _nameCtrl.text,
      'description': _descCtrl.text,
      'price': double.tryParse(_priceCtrl.text) ?? 0.0,
      'image_url': _imageCtrl.text,
      'category': _category,
    };

    final provider = context.read<ProductProvider>();
    bool success;

    if (widget.product == null) {
      success = await provider.addProduct(data);
      if (success) {
        NotificationService().showLocalNotification(
          title: 'Produk Ditambahkan',
          body: '${_nameCtrl.text} berhasil ditambahkan ke katalog',
        );
      }
    } else {
      success = await provider.updateProduct(widget.product!.id, data);
      if (success) {
        NotificationService().showLocalNotification(
          title: 'Produk Diperbarui',
          body: '${_nameCtrl.text} berhasil diperbarui',
        );
      }
    }

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Terjadi kesalahan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ProductProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Tambah Produk' : 'Edit Produk'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Produk',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(
                  labelText: 'Harga (Rp)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageCtrl,
                decoration: const InputDecoration(
                  labelText: 'URL Gambar',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF1565C0),
                ),
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.product == null ? 'Simpan' : 'Perbarui',
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
