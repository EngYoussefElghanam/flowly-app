import 'package:flowly/data/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubits/customer_details_cubit.dart';
import '../../logic/cubits/auth_cubit.dart';
import '../../data/repositories/customer_repository.dart';
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
    final token = (context.read<AuthCubit>().state as AuthSuccess).user.token;
    // 1. Capture the Theme

    return BlocProvider(
      create: (context) =>
          CustomerDetailsCubit(CustomerRepository())
            ..getCustomerDetails(customerId, token), // Keeping your method name
      child: Scaffold(
        // Background handled by Theme (Light Grey / Dark Grey)
        appBar: AppBar(
          title: Text(customerName),
          // Styles handled by Theme
        ),
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
      ),
    );
  }

  Widget _buildContent(BuildContext context, CustomerModel customer) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 1. Profile Card (Same as before)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
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
                  backgroundColor: theme.colorScheme.primary,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  customer.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  customer.phone,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _infoBadge(context, Icons.location_on, customer.city),
                    // ✅ NOW SHOWS REAL COUNT
                    _infoBadge(
                      context,
                      Icons.shopping_bag,
                      "${customer.orders.length} Orders",
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Order History",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 2. REAL ORDER LIST
          if (customer.orders.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
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
              shrinkWrap: true, // Vital for nesting in SingleChildScrollView
              physics:
                  const NeverScrollableScrollPhysics(), // Scroll the whole page, not just list
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
        Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _OrderHistoryItem extends StatelessWidget {
  final OrderModel order;
  const _OrderHistoryItem({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Status Color Logic
    Color statusColor = Colors.grey;
    if (order.status == 'NEW') statusColor = Colors.blue;
    if (order.status == 'COMPLETED') statusColor = Colors.green;
    if (order.status == 'CANCELLED') statusColor = Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.05),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: ID and Date
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Order #${order.id}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                order.date,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),

          // Right: Amount and Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "\$${order.totalAmount.toStringAsFixed(2)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
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
    );
  }
}
