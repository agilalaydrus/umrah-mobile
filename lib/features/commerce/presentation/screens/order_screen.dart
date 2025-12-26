import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/commerce_repository.dart';
import '../providers/commerce_provider.dart';

class OrderScreen extends ConsumerStatefulWidget {
  final Product product;

  const OrderScreen({super.key, required this.product});

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  bool _isLoading = false;

  Future<void> _processOrder() async {
    setState(() => _isLoading = true);

    try {
      final repo = ref.read(commerceRepositoryProvider);
      
      // 1. Create Order
      final orderId = await repo.createOrder(widget.product.id);
      
      // 2. Mock Payment Proof Upload
      await repo.uploadProof(orderId, "dummy_path.jpg");

      if (mounted) {
        // Show Success
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text("Order Successful"),
            content: const Text("Your payment proof has been uploaded. We will activate your package shortly."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx); // Close Dialog
                  Navigator.pop(context); // Back to Catalog
                },
                child: const Text("OK"),
              )
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout"), backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Summary
            Card(
              child: ListTile(
                leading: const Icon(Icons.shopping_cart, color: Colors.teal),
                title: Text(widget.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Price: Rp ${widget.product.price}"),
              ),
            ),
            const SizedBox(height: 30),

            // Payment Instructions
            const Text("Payment Instructions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Bank Transfer (BCA)"),
                  Text("123-456-7890", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  Text("A/N PT Umrah Connect Indonesia"),
                ],
              ),
            ),
            const Spacer(),

            // Pay Button
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _processOrder,
                icon: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : const Icon(Icons.upload_file, color: Colors.white),
                label: const Text("Upload Proof & Confirm", style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              ),
            )
          ],
        ),
      ),
    );
  }
}