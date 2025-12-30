import 'package:flowly/presentation/screens/customer_details_screen.dart';
import 'package:flowly/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubits/customer_cubit.dart';
import '../../logic/cubits/auth_cubit.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/models/customer_model.dart';
import 'add_customer_screen.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Get Token
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthSuccess) {
      return const LoginScreen();
    }

    final token = authState.user.token;
    final user = authState.user;
    final theme = Theme.of(context); // 🎨 Capture Theme

    // 2. Provide the Cubit
    return BlocProvider(
      // Note: Ensure your Cubit method is named 'loadCustomers' or 'getCustomers' (match your file)
      create: (context) =>
          CustomerCubit(CustomerRepository())..getCustomers(token),
      child: Builder(
        builder: (context) {
          return Scaffold(
            // Background is now handled by AppTheme (Light Grey vs Dark Grey)
            appBar: AppBar(
              toolbarHeight: 80,
              elevation: 0,
              backgroundColor: Colors.transparent,
              // Keep the Gradient as a "Brand Header" (Looks good in both modes)
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0F2027),
                      Color(0xFF203A43),
                      Color(0xFF2C5364),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              centerTitle: false,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome back,",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.logout,
                    color: theme.colorScheme.error,
                  ), // Use Theme Error color
                  onPressed: () => context.read<AuthCubit>().logout(),
                ),
              ],
            ),
            body: Column(
              children: [
                // THE LIST
                Expanded(
                  child: BlocBuilder<CustomerCubit, CustomerState>(
                    builder: (context, state) {
                      if (state is CustomerLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is CustomerError) {
                        return Center(child: Text(state.message));
                      } else if (state is CustomerSuccess) {
                        if (state.customers.isEmpty) {
                          return Center(
                            child: Text(
                              "No customers yet.",
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: state.customers.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _CustomerItem(
                              customer: state.customers[index],
                            );
                          },
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),

                // THE ADD BUTTON
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddCustomerScreen(),
                          ),
                        ).then((_) {
                          context.read<CustomerCubit>().getCustomers(token);
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          color: theme
                              .colorScheme
                              .primary, // ⚫ Matches Theme Primary
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_add,
                              color: theme.colorScheme.onPrimary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Add New Client",
                              style: TextStyle(
                                color:
                                    theme.colorScheme.onPrimary, // ⚪ White text
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// 🎨 COMPONENT: Customer Card
class _CustomerItem extends StatelessWidget {
  final CustomerModel customer;
  const _CustomerItem({required this.customer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // ⬜ White in Light, Dark Grey in Dark
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Subtle shadow
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.secondary.withOpacity(
            0.1,
          ), // 🔵 Light Blue tint
          child: Icon(
            Icons.person,
            color: theme.colorScheme.secondary,
          ), // 🔵 Blue Icon
        ),
        title: Text(
          customer.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
          // Text color automatically adapts to Theme
        ),
        subtitle: Text(
          "${customer.phone}\n${customer.city}",
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ), // Grey text
        ),
        isThreeLine: true,
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.3),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CustomerDetailsScreen(
                customerId: customer.id,
                customerName: customer.name,
              ),
            ),
          );
        },
      ),
    );
  }
}
