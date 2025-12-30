import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';

class PosProductItem extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const PosProductItem({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOutOfStock = product.stock <= 0;

    return GestureDetector(
      onTap: isOutOfStock ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOutOfStock
                ? theme.colorScheme.error.withOpacity(0.3)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon / Image Placeholder
            CircleAvatar(
              radius: 25,
              backgroundColor: isOutOfStock
                  ? theme.colorScheme.error.withOpacity(0.1)
                  : theme.colorScheme.primary.withOpacity(0.05),
              child: Icon(
                isOutOfStock ? Icons.block : Icons.inventory_2_outlined,
                color: isOutOfStock
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            // Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                product.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Price & Stock
            Text(
              "\$${product.sellPrice}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
            Text(
              "${product.stock} left",
              style: TextStyle(
                fontSize: 10,
                color: isOutOfStock
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
