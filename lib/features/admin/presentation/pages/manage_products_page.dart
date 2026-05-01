import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/core/routes/app_router.dart';
import 'package:flutter_firebase_auth/features/dashboard/data/models/product_model.dart';
import 'package:flutter_firebase_auth/features/dashboard/presentation/providers/product_provider.dart';
import 'package:provider/provider.dart';

class ManageProductsPage extends StatefulWidget {
  const ManageProductsPage({super.key});

  @override
  State<ManageProductsPage> createState() => _ManageProductsPageState();
}

class _ManageProductsPageState extends State<ManageProductsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  void _confirmDelete(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Apakah Anda yakin ingin menghapus ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<ProductProvider>().deleteProduct(product.id);
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Produk berhasil dihapus')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.read<ProductProvider>().error ?? 'Gagal menghapus produk')),
                  );
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProv = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.productForm);
            },
          )
        ],
      ),
      body: switch (productProv.status) {
        ProductStatus.initial || ProductStatus.loading => const Center(child: CircularProgressIndicator()),
        ProductStatus.error => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(productProv.error ?? 'Terjadi kesalahan'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => productProv.fetchProducts(),
                  child: const Text('Coba Lagi'),
                )
              ],
            ),
          ),
        ProductStatus.loaded => ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: productProv.products.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final product = productProv.products[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 50, color: Colors.grey),
                        )
                      : const Icon(Icons.image, size: 50, color: Colors.grey),
                ),
                title: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('Rp ${product.price} - ${product.category}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRouter.productForm,
                          arguments: product,
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(context, product),
                    ),
                  ],
                ),
              );
            },
          ),
      },
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.productForm);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
