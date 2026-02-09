import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubits/dashboard_cubit.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Capture Theme
    final theme = Theme.of(context);

    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DashboardError) {
          return Center(
            child: Text(
              state.message,
              // 2. Use Theme Error Color
              style: TextStyle(color: theme.colorScheme.error),
            ),
          );
        } else if (state is DashboardSuccess) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // 3. Title adapts to Light/Dark mode automatically
                Text(
                  "Overview",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                    children: [
                      _StatCard(
                        title: "Revenue",
                        value:
                            "\$${state.stats.totalRevenue.toStringAsFixed(2)}",
                        icon: Icons.attach_money,
                        color: const Color(0xFF00C853), // Green
                      ),
                      _StatCard(
                        title: "Orders",
                        value: "${state.stats.totalOrders}",
                        icon: Icons.shopping_bag_outlined,
                        color: const Color(0xFF2979FF), // Blue
                      ),
                      _StatCard(
                        title: "Profit",
                        value:
                            "\$${state.stats.totalProfit.toStringAsFixed(2)}",
                        icon: Icons.trending_up,
                        color: const Color(0xFFAA00FF), // Purple
                      ),
                      _StatCard(
                        title: "Avg. Value",
                        value:
                            "\$${state.stats.averageOrderValue.toStringAsFixed(2)}",
                        icon: Icons.pie_chart_outline,
                        color: const Color(0xFFFF9100), // Orange
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
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
