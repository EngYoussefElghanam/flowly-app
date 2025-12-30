import 'package:flutter/material.dart';
import 'inventory_screen.dart'; // Import it

class EmployeeHomeView extends StatelessWidget {
  const EmployeeHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // For now, the Home View IS the Inventory Screen
    return const InventoryScreen();
  }
}
