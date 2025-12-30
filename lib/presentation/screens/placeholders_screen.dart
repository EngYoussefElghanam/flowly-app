import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubits/auth_cubit.dart';

// 1. POS (Point of Sale) Placeholder
class POSPlaceholder extends StatelessWidget {
  const POSPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Point of Sale")),
      body: const Center(child: Text("Create Order Screen Coming Soon")),
    );
  }
}

// 2. Customers Placeholder
class CustomersPlaceholder extends StatelessWidget {
  const CustomersPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Customers")),
      body: const Center(child: Text("CRM Screen Coming Soon")),
    );
  }
}

// 3. Settings/Menu Placeholder (With Logout!)
class SettingsPlaceholder extends StatelessWidget {
  const SettingsPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menu")),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () {
            // Trigger Logout logic here
            // For now, just print or clear state
            context.read<AuthCubit>().logout();
            // In real app, you'd navigate to LoginScreen
          },
          icon: const Icon(Icons.logout),
          label: const Text("Logout"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
      ),
    );
  }
}
