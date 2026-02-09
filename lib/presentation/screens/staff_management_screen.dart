import 'package:flowly/logic/cubits/auth_cubit.dart';
import 'package:flowly/logic/cubits/staff_cubit.dart';
import 'package:flowly/core/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      context.read<StaffCubit>().getEmployees(authState.user.token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Staff"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, Routes.addStaff).then((result) {
            if (result == true) {
              _loadData();
            }
          }); // Refresh list when returning
        },
        label: const Text("Add New"),
        icon: const Icon(Icons.person_add),
      ),
      body: BlocConsumer<StaffCubit, StaffState>(
        listener: (context, state) {
          if (state is StaffError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is StaffLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StaffSuccess) {
            final employees = state.employees;

            if (employees.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    const Text("No staff members found."),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: employees.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final employee = employees[index];

                return Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainer,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withOpacity(
                        0.1,
                      ),
                      child: Text(
                        employee.name[0].toUpperCase(),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      employee.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(employee.email),
                        if (employee.phone != null)
                          Text(
                            employee.phone!,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _confirmDelete(
                        context,
                        employee.userId,
                        employee.name,
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink(); // Fallback for initial state
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, int employeeId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove Access?"),
        content: Text(
          "Are you sure you want to remove $name? They will no longer be able to log in.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final authState = context.read<AuthCubit>().state;
              if (authState is AuthSuccess) {
                context.read<StaffCubit>().deleteEmployee(
                  authState.user.token,
                  employeeId,
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Remove"),
          ),
        ],
      ),
    );
  }
}
