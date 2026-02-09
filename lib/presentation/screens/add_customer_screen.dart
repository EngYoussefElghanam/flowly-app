import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubits/add_customer_cubit.dart';
import '../../logic/cubits/auth_cubit.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final token = (context.read<AuthCubit>().state as AuthSuccess).user.token;
    final theme = Theme.of(context); // 1. Catch the theme once for cleaner code

    return Scaffold(
      // Background color is handled automatically by AppTheme now!
      appBar: AppBar(
        title: const Text("Add Client"),
        // AppBar styles (colors/fonts) are now auto-inherited from AppTheme
      ),
      body: BlocListener<AddCustomerCubit, AddCustomerState>(
        listener: (context, state) {
          if (state is AddCustomerSuccess) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Client Added!"),
                backgroundColor: Colors.green, // Success is always green
              ),
            );
          } else if (state is AddCustomerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error, // 2. Use Theme Error
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildField(_nameController, "Client Name", Icons.person),
                const SizedBox(height: 16),
                _buildField(
                  _phoneController,
                  "Phone Number",
                  Icons.phone,
                  isNumber: true,
                ),
                const SizedBox(height: 16),
                _buildField(_cityController, "City", Icons.location_city),
                const SizedBox(height: 16),
                _buildField(_addressController, "Full Address", Icons.home),
                const SizedBox(height: 32),

                // SUBMIT BUTTON
                BlocBuilder<AddCustomerCubit, AddCustomerState>(
                  builder: (context, state) {
                    if (state is AddCustomerLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AddCustomerCubit>().addCustomer(
                            token: token,
                            name: _nameController.text,
                            phone: _phoneController.text,
                            city: _cityController.text,
                            address: _addressController.text,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            theme.colorScheme.primary, // 3. Theme Primary
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Save Client",
                        style: TextStyle(
                          fontSize: 16,
                          color: theme
                              .colorScheme
                              .onPrimary, // 4. Text matches button (White on Black)
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        // 5. FIXED: Use onSurface (Grey/Black) so icon is visible on light background
        prefixIcon: Icon(
          icon,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),

        // 6. Use Theme's input fill color (Light Grey in Light mode, Dark Grey in Dark mode)
        fillColor: theme.inputDecorationTheme.fillColor,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (val) => val!.isEmpty ? "Required" : null,
    );
  }
}
