import 'package:flutter_firebase_auth/core/constants/api_constants.dart';
import 'package:flutter_firebase_auth/core/services/dio_client.dart';
import 'package:flutter_firebase_auth/features/dashboard/data/models/product_model.dart';
import 'package:flutter_firebase_auth/features/dashboard/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  @override
  Future<List<ProductModel>> getProducts({int page = 1, int limit = 10, String? category}) async {
    final response = await DioClient.instance.get(
      ApiConstants.products,
      queryParameters: {'page': page, 'limit': limit, 'category': category},
    );

    final List<dynamic> data = response.data['data'];
    return data.map((e) => ProductModel.fromJson(e)).toList();
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    final response = await DioClient.instance.get('${ApiConstants.products}/$id');
    return ProductModel.fromJson(response.data['data']);
  }

  @override
  Future<ProductModel> addProduct(Map<String, dynamic> data) async {
    final response = await DioClient.instance.post(ApiConstants.products, data: data);
    return ProductModel.fromJson(response.data['data']);
  }

  @override
  Future<ProductModel> updateProduct(int id, Map<String, dynamic> data) async {
    final response = await DioClient.instance.put('${ApiConstants.products}/$id', data: data);
    return ProductModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteProduct(int id) async {
    await DioClient.instance.delete('${ApiConstants.products}/$id');
  }
}
