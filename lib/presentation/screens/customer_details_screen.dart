import 'package:flowly/data/models/order_model.dart';
import 'package:flowly/presentation/widgets/customer_smart_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Cubits
import '../../logic/cubits/customer_details_cubit.dart';
import '../../logic/cubits/customer_stats_cubit.dart';
import '../../logic/cubits/auth_cubit.dart';
import '../../core/routing/app_router.dart';
import '../../data/models/customer_model.dart';

class CustomerDetailsScreen extends StatelessWidget {
  final int customerId;
  final String customerName;

  const CustomerDetailsScreen({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  Widget build(BuildContext context) {
    // 🛡️ SAFE SESSION CHECK
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthSuccess) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(customerName)),
      body: BlocBuilder<CustomerDetailsCubit, CustomerDetailsState>(
        builder: (context, state) {
          if (state is CustomerDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CustomerDetailsError) {
            return Center(child: Text(state.message));
          } else if (state is CustomerDetailsSuccess) {
            return _buildContent(context, state.customer);
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, CustomerModel customer) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // --- 1. PROFILE CARD ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              // ✨ DARK MODE FIX: Lighter border instead of shadow for visibility
              border: isDark
                  ? Border.all(color: Colors.white.withOpacity(0.1))
                  : null,
              boxShadow: isDark
                  ? [] // No shadow in dark mode (looks cleaner)
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  // ✨ DARK MODE FIX: Use 'inversePrimary' or specific color so icon pops
                  backgroundColor: isDark
                      ? Colors.grey[800]
                      : theme.colorScheme.primary,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    // ✨ DARK MODE FIX: Icon color adapts
                    color: isDark ? Colors.white : theme.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  customer.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  customer.phone,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _infoBadge(context, Icons.location_on, customer.city),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // --- 2. SMART ANALYTICS CARD ---
          // ⚠️ NOTE: If this looks white-on-white, you need to update
          // the CustomerSmartCard widget file to handle Dark Mode gradients!
          const CustomerSmartCard(),

          const SizedBox(height: 24),

          // --- 3. ORDER HISTORY HEADER ---
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Order History",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // --- 4. ORDER LIST ---
          if (customer.orders.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: isDark ? Border.all(color: Colors.white10) : null,
              ),
              child: Center(
                child: Text(
                  "No orders yet.",
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: customer.orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final order = customer.orders[index];
                return _OrderHistoryItem(order: order);
              },
            ),
        ],
      ),
    );
  }

  Widget _infoBadge(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// --- SUB-WIDGET: HISTORY ITEM ---
class _OrderHistoryItem extends StatelessWidget {
  final OrderModel order;
  const _OrderHistoryItem({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ✨ DARK MODE FIX: Brighter colors for Dark Mode so they glow
    Color statusColor = Colors.grey;
    if (order.status == 'NEW')
      statusColor = isDark ? Colors.blueAccent : Colors.blue;
    if (order.status == 'COMPLETED')
      statusColor = isDark ? Colors.greenAccent : Colors.green;
    if (order.status == 'CANCELLED')
      statusColor = isDark ? Colors.redAccent : Colors.red;

    return InkWell(
      onTap: () =>
          Navigator.pushNamed(
            context,
            Routes.orderDetails,
            arguments: OrderDetailsArgs(orderId: order.id),
          ).then((_) {
            // Refresh Logic...
            if (context.mounted) {
              // ... (Same refresh logic as before) ...
              final authState = context.read<AuthCubit>().state;
              if (authState is AuthSuccess) {
                final token = authState.user.token;
                final detailsCubit = context.read<CustomerDetailsCubit>();
                if (detailsCubit.state is CustomerDetailsSuccess) {
                  final currentId =
                      (detailsCubit.state as CustomerDetailsSuccess)
                          .customer
                          .id;
                  detailsCubit.getCustomerDetails(currentId, token);
                  context.read<CustomerStatsCubit>().loadStats(
                    currentId,
                    token,
                  );
                }
              }
            }
          }),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          // ✨ DARK MODE FIX: Stronger, visible border in dark mode
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Order #${order.id}",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.date,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "\$${order.totalAmount.toStringAsFixed(2)}",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    // ✨ DARK MODE FIX: Use secondary color (Blue) instead of Primary (White)
                    color: isDark
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    // ✨ DARK MODE FIX: Lower opacity for background to avoid glare
                    color: statusColor.withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
