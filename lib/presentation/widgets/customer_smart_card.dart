import 'package:flowly/logic/cubits/customer_stats_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomerSmartCard extends StatelessWidget {
  const CustomerSmartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<CustomerStatsCubit, CustomerStatsState>(
      builder: (context, state) {
        // 1. LOADING STATE ⏳
        if (state is CustomerStatsLoading || state is CustomerStatsInitial) {
          return Container(
            height: 100,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              // Adaptive Loading Color
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        // 2. ERROR STATE ⚠️
        if (state is CustomerStatsError) {
          return Container(
            height: 80,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Text(
                  "Could not load stats",
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
            ),
          );
        }

        // 3. LOADED STATE (THE SMART CARD) ✅
        if (state is CustomerStatsLoaded) {
          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              // 🎨 COLOR FIX:
              // Light Mode: Use Primary (Black)
              // Dark Mode: Use Dark Grey Gradient (instead of White) so text pops
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF323232),
                        const Color(0xFF121212),
                      ] // Dark Mode Gradient
                    : [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.8),
                      ], // Light Mode Gradient (Black)
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              // Shadow only in Light Mode (Shadows look bad on dark backgrounds)
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
              // Add a subtle border in Dark Mode for definition
              border: isDark
                  ? Border.all(color: Colors.white.withOpacity(0.1))
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // --- METRIC 1: TOTAL SPENT ---
                _buildStatItem(
                  context,
                  icon: Icons.attach_money,
                  label: "Total Spent",
                  value: "\$${state.totalSpent}",
                ),

                // Divider Line (White with opacity works on both Black and Dark Grey)
                Container(width: 1, height: 40, color: Colors.white24),

                // --- METRIC 2: ORDERS ---
                _buildStatItem(
                  context,
                  icon: Icons.shopping_bag_outlined,
                  label: "Orders",
                  value: "${state.totalOrders}",
                ),

                // Divider Line
                Container(width: 1, height: 40, color: Colors.white24),

                // --- METRIC 3: FAVORITE ---
                _buildStatItem(
                  context,
                  icon: Icons.favorite_border,
                  label: "Favorite",
                  value: state.favoriteItem.length > 8
                      ? "${state.favoriteItem.substring(0, 7)}..."
                      : state.favoriteItem,
                ),
              ],
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  // Helper widget to build each column
  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            // Always White (Because background is always Dark/Black now)
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
