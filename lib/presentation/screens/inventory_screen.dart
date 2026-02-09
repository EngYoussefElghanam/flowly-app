import 'package:flowly/core/routing/app_router.dart';
import 'package:flowly/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubits/inventory_cubit.dart';
import '../../logic/cubits/auth_cubit.dart';
import '../../data/models/product_model.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthSuccess) {
      return const LoginScreen();
    }

    final token = authState.user.token;
    final user = authState.user;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0F2027),
                Color(0xFF203A43),
                Color(0xFF2C5364),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome back,",
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: theme.colorScheme.error),
            onPressed: () => context.read<AuthCubit>().logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. THE LIST AREA
          Expanded(
            child: BlocBuilder<InventoryCubit, InventoryState>(
              builder: (context, state) {
                if (state is InventoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is InventoryError) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      await context.read<InventoryCubit>().getProducts(
                        token,
                      );
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                        ),
                        Center(
                          child: Text(
                            state.message,
                            style: TextStyle(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is InventorySuccess) {
                  if (state.products.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        await context.read<InventoryCubit>().getProducts(
                          token,
                        );
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3,
                          ),
                          Center(
                            child: Text(
                              "No products yet",
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // THE LIST
                  return RefreshIndicator(
                    color: theme.primaryColor,
                    backgroundColor: theme.colorScheme.surface,
                    onRefresh: () async {
                      await context.read<InventoryCubit>().getProducts(
                        token,
                      );
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: state.products.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _ProductItem(
                          product: state.products[index],
                        );
                      },
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),

          // 2. THE STICKY ADD BUTTON
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _StickyAddButton(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    Routes.productForm,
                    arguments: ProductFormArgs(
                      inventoryCubit: context.read<InventoryCubit>(),
                    ),
                  ).then((_) {
                    context.read<InventoryCubit>().getProducts(token);
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🎨 COMPONENT 1: The Sticky Bottom Button
class _StickyAddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _StickyAddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: theme.colorScheme.onPrimary,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              "Add New Product",
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🎨 COMPONENT 2: The Product Item (UPDATED WITH ACTIONS)
class _ProductItem extends StatelessWidget {
  final ProductModel product;
  const _ProductItem({required this.product});

  // 🗑️ Delete Confirmation Logic
  void _confirmDelete(BuildContext context, String token) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Product?"),
        content: Text(
          "Are you sure you want to delete '${product.name}'? \n\nIf it has sales history, it will be archived instead.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              // Call the Cubit to delete
              context.read<InventoryCubit>().deleteProduct(token, product.id);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.read<AuthCubit>().state;
    // Safely get token
    final token = (authState is AuthSuccess) ? authState.user.token : '';
    final bool isLowStock = product.stock < 5;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isLowStock
              ? theme.colorScheme.error.withOpacity(0.1)
              : theme.colorScheme.secondary.withOpacity(0.1),
          child: Icon(
            Icons.inventory_2,
            color: isLowStock
                ? theme.colorScheme.error
                : theme.colorScheme.secondary,
            size: 20,
          ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          "Buy: \$${product.costPrice.toStringAsFixed(0)} | Sell: \$${product.sellPrice.toStringAsFixed(0)}",
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        // ⚙️ UPDATED TRAILING SECTION
        trailing: Row(
          mainAxisSize: MainAxisSize.min, // Essential for trailing usage
          children: [
            // 1. Stock Info
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${product.stock}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isLowStock ? theme.colorScheme.error : Colors.green,
                  ),
                ),
                Text(
                  "Units",
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),

            // 2. Vertical Divider (Optional visual separation)
            Container(
              height: 24,
              width: 1,
              color: theme.dividerColor.withOpacity(0.5),
              margin: const EdgeInsets.symmetric(horizontal: 4),
            ),

            // 3. Edit Button (Pen)
            IconButton(
              icon: const Icon(Icons.edit, size: 22, color: Colors.blue),
              tooltip: "Edit Product",
              onPressed: () {
                // 🔐 We must pass the EXISTING InventoryCubit to the new screen
                // so the 'Update' function can refresh this list automatically.
                final inventoryCubit = context.read<InventoryCubit>();

                Navigator.pushNamed(
                  context,
                  Routes.productForm,
                  arguments: ProductFormArgs(
                    inventoryCubit: inventoryCubit,
                    product: product,
                  ),
                );
              },
            ),

            // 4. Delete Button (Trash)
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                size: 22,
                color: Colors.red,
              ),
              tooltip: "Delete Product",
              onPressed: () => _confirmDelete(context, token),
            ),
          ],
        ),
      ),
    );
  }
}
