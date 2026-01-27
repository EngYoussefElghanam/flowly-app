import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/models/cart_item_model.dart';
import '../../logic/cubits/auth_cubit.dart';
import '../../logic/cubits/order_details_cubit.dart';

class OrderDetailsScreen extends StatelessWidget {
  final int orderId;
  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    // 1. Get Token securely
    final authState = context.read<AuthCubit>().state;
    final token = (authState is AuthSuccess) ? authState.user.token : '';

    return BlocProvider(
      create: (context) =>
          OrderDetailsCubit(OrderRepository())..getDetails(token, orderId),
      child: Scaffold(
        appBar: AppBar(title: Text("Order #$orderId")),
        body: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
          builder: (context, state) {
            // A. LOADING (Initial Load only)
            if (state is OrderDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            // B. ERROR
            else if (state is OrderDetailsError) {
              return Center(child: Text("Error: ${state.message}"));
            }
            // C. SUCCESS (Content visible)
            else if (state is OrderDetailsSuccess) {
              // Note: Using 'orderDetails' to match your State class
              final order = state.orderDetails;
              final theme = Theme.of(context);
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- STATUS CARD ---
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Order Status",
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // ✨ LOGIC: Check the flag from the State
                            // If updating, show spinner. If not, show dropdown.
                            state.isUpdatingStatus
                                ? const Center(child: LinearProgressIndicator())
                                : DropdownButtonFormField<String>(
                                    initialValue: order.status,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                    items:
                                        [
                                              "NEW",
                                              "PACKED",
                                              "WITH_COURIER",
                                              "DELIVERED",
                                              "CANCELLED",
                                              "RETURNED",
                                            ]
                                            .map(
                                              (s) => DropdownMenuItem(
                                                value: s,
                                                child: Text(s),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (val) {
                                      if (val != null && val != order.status) {
                                        // Trigger Cubit
                                        context
                                            .read<OrderDetailsCubit>()
                                            .updateStatus(token, orderId, val);
                                      }
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Text("Order Items", style: theme.textTheme.titleLarge),
                    const SizedBox(height: 12),

                    // --- ITEMS LIST ---
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: order.items.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = order.items[index];
                        return _OrderItemTile(item: item);
                      },
                    ),

                    const Divider(thickness: 2, height: 40),

                    // --- TOTAL ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Amount",
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          "\$${order.totalAmount.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

// Helper Widget
class _OrderItemTile extends StatelessWidget {
  final CartItemModel item;
  const _OrderItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          "${item.quantity}x",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(item.product.name),
      trailing: Text(
        "\$${item.totalPrice.toStringAsFixed(2)}",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
