import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/product_model.dart'; // ✅ Import ProductModel
import '../../logic/cubits/add_product_cubit.dart';
import '../../logic/cubits/auth_cubit.dart';
import '../../logic/cubits/inventory_cubit.dart'; // ✅ Import InventoryCubit

class AddProductScreen extends StatefulWidget {
  final ProductModel? productToEdit; // ✅ Optional parameter for Edit Mode

  const AddProductScreen({super.key, this.productToEdit});

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

  // ✅ Helper to check mode
  bool get isEditing => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    // ✅ Pre-fill data if in Edit Mode
    if (isEditing) {
      final p = widget.productToEdit!;
      _nameController.text = p.name;
      _costController.text = p.costPrice.toString();
      _sellController.text = p.sellPrice.toString();
      _stockController.text = p.stock.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _sellController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  // 3. THE SUBMIT FUNCTION (Handles both Add and Edit)
  void _submitForm(BuildContext context, String token) {
    if (_formKey.currentState!.validate()) {
      if (isEditing) {
        // ✏️ EDIT MODE: Use InventoryCubit
        context.read<InventoryCubit>().updateProduct(
          token,
          widget.productToEdit!.id,
          name: _nameController.text,
          stock: int.parse(_stockController.text),
          sellPrice: double.parse(_sellController.text),
          costPrice: double.parse(_costController.text),
        );
        Navigator.pop(context); // Close immediately after trigger
      } else {
        // ➕ ADD MODE: Use AddProductCubit
        context.read<AddProductCubit>().createProduct(
          token: token,
          name: _nameController.text,
          costPrice: double.parse(_costController.text),
          sellPrice: double.parse(_sellController.text),
          stock: int.parse(_stockController.text),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final token = (authState is AuthSuccess) ? authState.user.token : '';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // ✅ Dynamic Title
        title: Text(isEditing ? "Edit Product" : "Create New Product"),
      ),

      // 4. THE LISTENER (Only needed for AddProduct logic feedback)
      body: BlocListener<AddProductCubit, AddProductState>(
        listener: (context, state) {
          if (state is AddProductSuccess) {
            // If we just added a product, refresh inventory and close
            context.read<InventoryCubit>().getProducts(token);
          } else if (state is AddProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
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
                // 6. THE BUTTON
                // We logic check here: If Editing, show simple button.
                // If Adding, show BlocBuilder to handle loading spinner.
                isEditing
                    ? ElevatedButton(
                        onPressed: () => _submitForm(context, token),
                        style: _buttonStyle(theme),
                        child: Text("Update Product", style: _textStyle(theme)),
                      )
                    : BlocBuilder<AddProductCubit, AddProductState>(
                        builder: (context, state) {
                          if (state is AddProductLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return ElevatedButton(
                            onPressed: () => _submitForm(context, token),
                            style: _buttonStyle(theme),
                            child: Text(
                              "Create Product",
                              style: _textStyle(theme),
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

  // 🎨 STYLING HELPERS
  ButtonStyle _buttonStyle(ThemeData theme) {
    return ElevatedButton.styleFrom(
      backgroundColor: theme.colorScheme.primary,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  TextStyle _textStyle(ThemeData theme) {
    return TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary);
  }

  // 🛠️ HELPER: Reusable Text Field Builder
  Widget _buildTextField({
    required BuildContext context,
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
        prefixIcon: Icon(
          icon,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
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
