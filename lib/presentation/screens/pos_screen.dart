import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubits/inventory_cubit.dart';
import '../../logic/cubits/cart_cubit.dart';
import '../../logic/cubits/auth_cubit.dart';
import '../../data/repositories/product_repository.dart';
import '../widgets/pos_product_item.dart';
import 'checkout_sheet.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  // Simple search state
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.read<AuthCubit>().state;
    // Safety check for token
    final token = (authState is AuthSuccess) ? authState.user.token : '';

    return BlocProvider(
      // Fetch fresh inventory when opening POS
      create: (context) =>
          InventoryCubit(ProductRepository())..getProducts(token),
      child: Scaffold(
        appBar: AppBar(title: const Text("Point of Sale"), elevation: 0),
        body: Column(
          children: [
            // 1. SEARCH BAR
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search products...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
                onChanged: (val) =>
                    setState(() => _searchQuery = val.toLowerCase()),
              ),
            ),

            // 2. PRODUCT GRID (Now Refreshable)
            Expanded(
              child: BlocBuilder<InventoryCubit, InventoryState>(
                builder: (context, state) {
                  if (state is InventoryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is InventoryError) {
                    // 🔴 Error State (Refreshable)
                    return RefreshIndicator(
                      onRefresh: () async {
                        await context.read<InventoryCubit>().getProducts(token);
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3,
                          ),
                          Center(child: Text("Error: ${state.message}")),
                        ],
                      ),
                    );
                  } else if (state is InventorySuccess) {
                    // Filter logic
                    final products = state.products
                        .where(
                          (p) => p.name.toLowerCase().contains(_searchQuery),
                        )
                        .toList();

                    // 🟡 Empty State (Refreshable)
                    if (products.isEmpty) {
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
                            const Center(child: Text("No products found")),
                          ],
                        ),
                      );
                    }

                    // 🟢 Success Grid (Refreshable)
                    return RefreshIndicator(
                      color: theme.primaryColor,
                      backgroundColor: theme.colorScheme.surface,
                      onRefresh: () async {
                        await context.read<InventoryCubit>().getProducts(token);
                      },
                      child: GridView.builder(
                        // AlwaysScrollableScrollPhysics is required for Pull-to-Refresh
                        // to work even if the list is short!
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return PosProductItem(
                            product: products[index],
                            onTap: () {
                              context.read<CartCubit>().addToCart(
                                products[index],
                              );
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Added ${products[index].name}",
                                  ),
                                  duration: const Duration(milliseconds: 600),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),

            // 3. CART SUMMARY BAR
            BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                if (state.items.isEmpty) return const SizedBox.shrink();

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(blurRadius: 10, color: Colors.black12),
                    ],
                  ),
                  child: SafeArea(
                    child: ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const CheckoutSheet(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: theme.primaryColor,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${state.totalItems} Items",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                          const Text("View Cart & Pay"),
                          Text(
                            "\$${state.totalAmount.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
