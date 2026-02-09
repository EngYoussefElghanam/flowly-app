import 'package:flowly/core/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubits/theme_cubit.dart';
import '../../logic/cubits/auth_cubit.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Still capture theme for colors
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Menu")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 2. Wrap the Card in BlocBuilder to listen to ThemeCubit directly
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              // Calculate logic based on the Cubit State, not just the system
              final isDark =
                  themeMode == ThemeMode.dark ||
                  (themeMode == ThemeMode.system &&
                      MediaQuery.platformBrightnessOf(context) ==
                          Brightness.dark);

              return Card(
                child: SwitchListTile(
                  title: const Text("Dark Mode"),
                  secondary: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: theme.colorScheme.primary,
                  ),
                  value: isDark,
                  onChanged: (bool value) {
                    // Trigger Logic
                    context.read<ThemeCubit>().toggleTheme(value);
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Account Settings"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.pushNamed(context, Routes.account),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            color: theme.colorScheme.errorContainer,
            child: ListTile(
              leading: Icon(Icons.logout, color: theme.colorScheme.onError),
              title: Text(
                "Logout",
                style: TextStyle(
                  color: theme.colorScheme.onError,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                context.read<AuthCubit>().logout();
              },
            ),
          ),
        ],
      ),
    );
  }
}
