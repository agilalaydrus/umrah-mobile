import 'package:dio/dio.dart';
import 'package:umrah_app/core/network/api_client.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Product',
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
    );
  }
}

class CommerceRepository {
  final ApiClient _api;

  CommerceRepository(this._api);

  // 1. Get Catalog
  Future<List<Product>> getProducts() async {
    try {
      final response = await _api.get('/products');
      return (response.data as List).map((e) => Product.fromJson(e)).toList();
    } on DioException catch (e) {
      throw "Failed to load products: ${e.message}";
    }
  }

  // 2. Create Order
  Future<String> createOrder(String productId) async {
    try {
      final response = await _api.post('/orders', data: {
        'product_id': productId,
      });
      return response.data['id']; // Returns the Order ID
    } on DioException catch (e) {
      throw "Failed to create order: ${e.message}";
    }
  }

  // 3. Upload Payment Proof (Mock implementation for now)
  Future<void> uploadProof(String orderId, String filePath) async {
    try {
      // In a real app, you would use FormData here
      // FormData formData = FormData.fromMap({
      //   "image": await MultipartFile.fromFile(filePath),
      // });
      // await _api.post('/orders/$orderId/proof', data: formData);
      
      // For MVP/Demo without file picker logic yet:
      await Future.delayed(const Duration(seconds: 1)); // Simulate upload
    } on DioException catch (e) {
      throw "Failed to upload proof: ${e.message}";
    }
  }
}