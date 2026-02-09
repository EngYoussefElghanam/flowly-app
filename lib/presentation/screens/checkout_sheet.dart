import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Cubits
import '../../logic/cubits/cart_cubit.dart';
import '../../logic/cubits/customer_cubit.dart';
import '../../logic/cubits/checkout_cubit.dart';
import '../../logic/cubits/auth_cubit.dart';
// Models
import '../../data/models/cart_item_model.dart';

class CheckoutSheet extends StatefulWidget {
  const CheckoutSheet({super.key});

  @override
  State<CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<CheckoutSheet> {
  int _selectedCustomerId = -1;

  @override
  Widget build(BuildContext context) {
    // 🎨 CAPTURE THEME
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final authState = context.read<AuthCubit>().state;
    final token = (authState is AuthSuccess) ? authState.user.token : '';

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        // Use Surface color (White/DarkGrey)
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // --- HEADER ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Review Order",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface, // Text matches background
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: colorScheme.onSurface),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),

          // --- LIST OF ITEMS ---
          Expanded(
            child: BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                // Handle Empty State
                if (state.items.isEmpty) {
                  return Center(
                    child: Text(
                      "Cart is empty",
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: state.items.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 24,
                    color: colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                  itemBuilder: (context, index) {
                    return _CartItemRow(item: state.items[index]);
                  },
                );
              },
            ),
          ),

          // --- BOTTOM SECTION (Customer & Pay) ---
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              // Slightly different color to separate from list
              color: colorScheme.surfaceContainer,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. CUSTOMER DROPDOWN
                  BlocBuilder<CustomerCubit, CustomerState>(
                    builder: (context, state) {
                      if (state is CustomerLoading) {
                        return const LinearProgressIndicator();
                      } else if (state is CustomerSuccess) {
                        return DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            labelText: "Select Customer",
                            labelStyle: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.outline,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.outline,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.person,
                              color: colorScheme.primary,
                            ),
                            filled: true,
                            fillColor: colorScheme.surface,
                          ),
                          dropdownColor: colorScheme
                              .surfaceContainer, // Fixes dark mode menu bg
                          items: state.customers.map((c) {
                            return DropdownMenuItem(
                              value: c.id,
                              child: Text(
                                c.name,
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _selectedCustomerId = val ?? -1);
                          },
                        );
                      }
                      return Text(
                        "Failed to load customers.",
                        style: TextStyle(color: colorScheme.error),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // 2. CHECKOUT BUTTON
                  BlocConsumer<CheckoutCubit, CheckoutState>(
                    listener: (context, state) {
                      if (state is CheckoutSuccess) {
                        Navigator.pop(context);
                        context.read<CartCubit>().clearCart();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              "Order Created Successfully! 🎉",
                            ),
                            backgroundColor:
                                Colors.green, // Semantic Success Color
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else if (state is CheckoutError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor:
                                colorScheme.error, // Semantic Error Color
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    builder: (context, checkoutState) {
                      if (checkoutState is CheckoutLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final total =
                          context.watch<CartCubit>().state.totalAmount;

                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            backgroundColor:
                                colorScheme.primary, // Theme Primary
                            foregroundColor:
                                colorScheme.onPrimary, // Text on Primary
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                          onPressed: () {
                            final items =
                                context.read<CartCubit>().state.items;
                            context.read<CheckoutCubit>().submitOrder(
                              token,
                              _selectedCustomerId,
                              items,
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "PAY",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "\$${total.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimary.withOpacity(
                                    0.9,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- HELPER WIDGET FOR LIST ITEMS ---
class _CartItemRow extends StatelessWidget {
  final CartItemModel item;

  const _CartItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final cartCubit = context.read<CartCubit>();
    // 🎨 CAPTURE THEME
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        // Name & Price
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colorScheme.onSurface, // High emphasis text
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "\$${item.product.sellPrice} / unit",
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant, // Medium emphasis text
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        // Quantity Controls
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove, size: 18, color: colorScheme.primary),
                onPressed: () => cartCubit.decreaseQuantity(item.product.id),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              Text(
                "${item.quantity}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              IconButton(
                icon: Icon(Icons.add, size: 18, color: colorScheme.primary),
                onPressed: () => cartCubit.addToCart(item.product),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          ),
        ),

        // Total for this line
        SizedBox(
          width: 70,
          child: Text(
            "\$${item.totalPrice.toStringAsFixed(0)}",
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: colorScheme.primary, // Highlight the money
            ),
          ),
        ),
      ],
    );
  }
}
