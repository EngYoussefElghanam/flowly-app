import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubits/dashboard_cubit.dart';
import '../../logic/cubits/auth_cubit.dart'; // Import AuthCubit

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  // Helper method to handle the refresh logic
  Future<void> _refreshData(BuildContext context) async {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      // ✅ Call getStats with the token
      await context.read<DashboardCubit>().getStats(authState.user.token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 1. Wrap everything in a RefreshIndicator for Pull-to-Refresh
    return RefreshIndicator(
      onRefresh: () => _refreshData(context),
      color: theme.colorScheme.primary,
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          // If loading, show spinner (but allow refresh if it gets stuck)
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardError) {
            // 2. Make Error state scrollable so you can Pull-to-Refresh out of an error
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: TextStyle(color: theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _refreshData(context),
                        icon: const Icon(Icons.refresh),
                        label: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          if (state is DashboardSuccess) {
            // 3. Switch to ListView so the whole page scrolls
            return ListView(
              padding: const EdgeInsets.all(16),
              physics:
                  const AlwaysScrollableScrollPhysics(), // Ensures pull-to-refresh works even if content is short
              children: [
                const SizedBox(height: 10),

                // Header Row with Refresh Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Overview",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Manual Refresh Button
                    IconButton(
                      onPressed: () => _refreshData(context),
                      icon: Icon(
                        Icons.refresh,
                        color: theme.colorScheme.primary,
                      ),
                      tooltip: "Refresh Data",
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 4. GridView inside ListView
                // We use shrinkWrap + NeverScrollableScrollPhysics so the ListView handles the scrolling
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                  children: [
                    _StatCard(
                      title: "Revenue",
                      value: "\$${state.stats.totalRevenue.toStringAsFixed(2)}",
                      icon: Icons.attach_money,
                      color: const Color(0xFF00C853),
                    ),
                    _StatCard(
                      title: "Orders",
                      value: "${state.stats.totalOrders}",
                      icon: Icons.shopping_bag_outlined,
                      color: const Color(0xFF2979FF),
                    ),
                    _StatCard(
                      title: "Profit",
                      value: "\$${state.stats.totalProfit.toStringAsFixed(2)}",
                      icon: Icons.trending_up,
                      color: const Color(0xFFAA00FF),
                    ),
                    _StatCard(
                      title: "Avg. Value",
                      value:
                          "\$${state.stats.averageOrderValue.toStringAsFixed(2)}",
                      icon: Icons.pie_chart_outline,
                      color: const Color(0xFFFF9100),
                    ),
                  ],
                ),

                // Added bottom padding so the last items aren't stuck to the screen edge
                const SizedBox(height: 40),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// 🎨 COMPONENT: Stat Card
// Note: We keep Colors.white here because the card background
// is always colored, so white text provides the best contrast
// regardless of the App Theme.
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color.withOpacity(0.55)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.white.withOpacity(0.9),
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
