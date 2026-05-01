import 'package:flutter_firebase_auth/features/dashboard/data/models/product_model.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getProducts({int page = 1, int limit = 10, String? category});
  Future<ProductModel> getProductById(int id);
  Future<ProductModel> addProduct(Map<String, dynamic> data);
  Future<ProductModel> updateProduct(int id, Map<String, dynamic> data);
  Future<void> deleteProduct(int id);
}
