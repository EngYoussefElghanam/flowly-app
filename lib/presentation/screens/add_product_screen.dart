import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubits/add_product_cubit.dart';
import '../../logic/cubits/auth_cubit.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // 1. THE CONTROLLERS
  final _nameController = TextEditingController();
  final _costController = TextEditingController();
  final _sellController = TextEditingController();
  final _stockController = TextEditingController();

  // 2. THE FORM KEY
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _sellController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  // 3. THE SUBMIT FUNCTION
  void _submitForm(BuildContext context, String token) {
    if (_formKey.currentState!.validate()) {
      context.read<AddProductCubit>().createProduct(
        token: token,
        name: _nameController.text,
        costPrice: double.parse(_costController.text),
        sellPrice: double.parse(_sellController.text),
        stock: int.parse(_stockController.text),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final token = (authState is AuthSuccess) ? authState.user.token : '';

    // 🎨 Get the theme
    final theme = Theme.of(context);

    return Scaffold(
      // Background color handled by AppTheme
      appBar: AppBar(
        title: const Text("Create New Product"),
        // Title color and Icon color handled by AppTheme automatically
      ),
      // 4. THE LISTENER
      body: BlocListener<AddProductCubit, AddProductState>(
        listener: (context, state) {
          if (state is AddProductSuccess) {
            Navigator.pop(context);
          } else if (state is AddProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor:
                    theme.colorScheme.error, // 🔴 Use Theme Error Color
              ),
            );
          }
        },
        // 5. THE FORM UI
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildTextField(
                  context: context,
                  controller: _nameController,
                  label: "Product Name",
                  hint: "e.g. Red Cotton Shirt",
                  icon: Icons.tag,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        context: context,
                        controller: _costController,
                        label: "Cost Price",
                        hint: "100",
                        icon: Icons.money_off,
                        isNumber: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        context: context,
                        controller: _sellController,
                        label: "Sell Price",
                        hint: "200",
                        icon: Icons.attach_money,
                        isNumber: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  context: context,
                  controller: _stockController,
                  label: "Stock Quantity",
                  hint: "50",
                  icon: Icons.inventory,
                  isNumber: true,
                ),
                const SizedBox(height: 32),

                // 6. THE BIG BUTTON
                BlocBuilder<AddProductCubit, AddProductState>(
                  builder: (context, state) {
                    if (state is AddProductLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ElevatedButton(
                      onPressed: () => _submitForm(context, token),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            theme.colorScheme.primary, // ⚫ Primary Color
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Create Product",
                        style: TextStyle(
                          fontSize: 16,
                          color: theme
                              .colorScheme
                              .onPrimary, // ⚪ White Text on Primary
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

  // 🛠️ HELPER: Reusable Text Field Builder
  Widget _buildTextField({
    required BuildContext context, // Pass context to access Theme
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isNumber = false,
  }) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        // Use 'onSurface' so icon is visible on both Light (Black/Grey) and Dark (White/Grey)
        prefixIcon: Icon(
          icon,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        // Use the centralized input fill color
        fillColor: theme.inputDecorationTheme.fillColor,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        if (isNumber && double.tryParse(value) == null) {
          return 'Must be a number';
        }
        return null;
      },
    );
  }
}
