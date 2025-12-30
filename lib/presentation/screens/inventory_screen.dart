import 'package:flowly/presentation/screens/add_product_screen.dart';
import 'package:flowly/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubits/inventory_cubit.dart';
import '../../logic/cubits/add_product_cubit.dart';
import '../../logic/cubits/auth_cubit.dart';
import '../../data/repositories/product_repository.dart';
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
    final theme = Theme.of(context); // 🎨 Capture Theme

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              InventoryCubit(ProductRepository())..getProducts(token),
        ),
        BlocProvider(create: (_) => AddProductCubit(ProductRepository())),
      ],
      child: Builder(
        builder: (innerContext) {
          return Scaffold(
            // Background handled by Theme
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
                  // Use Theme Error color
                  icon: Icon(Icons.logout, color: theme.colorScheme.error),
                  onPressed: () => context.read<AuthCubit>().logout(),
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: BlocBuilder<InventoryCubit, InventoryState>(
                    builder: (context, state) {
                      if (state is InventoryLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is InventoryError) {
                        return Center(
                          child: Text(
                            state.message,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        );
                      } else if (state is InventorySuccess) {
                        if (state.products.isEmpty) {
                          return Center(
                            child: Text(
                              "No products yet",
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: state.products.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _ProductItem(product: state.products[index]);
                          },
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _StickyAddButton(
                      onTap: () {
                        Navigator.push(
                          innerContext,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider(
                              create: (context) =>
                                  AddProductCubit(ProductRepository()),
                              child: const AddProductScreen(),
                            ),
                          ),
                        ).then((_) {
                          innerContext.read<InventoryCubit>().getProducts(
                            token,
                          );
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
          color: theme.colorScheme.primary, // ⚫ Black (Light) / ⚪ White (Dark)
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
                color: theme
                    .colorScheme
                    .onPrimary, // ⚪ White (Light) / ⚫ Black (Dark)
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

// 🎨 COMPONENT 2: The Product Item
class _ProductItem extends StatelessWidget {
  final ProductModel product;
  const _ProductItem({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isLowStock = product.stock < 5;

    return Container(
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surface, // ⬜ White (Light) / ⬛ Dark Grey (Dark)
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          // Use Theme colors for backgrounds
          backgroundColor: isLowStock
              ? theme.colorScheme.error.withOpacity(0.1)
              : theme.colorScheme.secondary.withOpacity(0.1),
          child: Icon(
            Icons.inventory_2,
            // Use Theme colors for Icons
            color: isLowStock
                ? theme.colorScheme.error
                : theme.colorScheme.secondary,
          ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
          // Auto-adapts to theme text color
        ),
        subtitle: Text(
          "Buy: \$${product.costPrice} | Sell: \$${product.sellPrice}",
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${product.stock}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isLowStock
                    ? theme.colorScheme.error
                    : Colors.green, // Green is universal enough
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
      ),
    );
  }
}
