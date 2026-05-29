/// fashion_store/lib/widgets/product_card.dart

import 'package:fashion_store/models/product_model.dart';
import 'package:fashion_store/screens/shop/product_details_screen.dart';
import 'package:fashion_store/utils/app_theme.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(product: product),
        ),
      ),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Product Image ──────────────────────────────────────────
            Expanded(
              child: _buildImage(),
            ),

            // ── Product Info ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Image.network(
        product.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        // Shown while the image downloads.
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: AppTheme.dividerColor,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primaryColor,
              ),
            ),
          );
        },
        // Shown when the URL is invalid or request fails.
        errorBuilder: (_, __, ___) => Container(
          color: AppTheme.dividerColor,
          child: const Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: AppTheme.textSecondaryColor,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}