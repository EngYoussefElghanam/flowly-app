import 'package:flowly/logic/cubits/auth_cubit.dart';
import 'package:flowly/logic/cubits/staff_cubit.dart'; // Import StaffCubit
import 'package:flowly/core/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Enum to control the screen's behavior
enum VerificationMode { ownerSignup, addStaff }

class VerificationScreen extends StatefulWidget {
  final String email;
  final VerificationMode mode; // New Parameter

  const VerificationScreen({
    super.key,
    required this.email,
    this.mode = VerificationMode.ownerSignup, // Default to normal signup
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _verify() {
    if (_formKey.currentState!.validate()) {
      final code = _codeController.text.trim();

      // 🔀 BRANCH LOGIC
      if (widget.mode == VerificationMode.ownerSignup) {
        // 1. Owner Flow (No Token needed yet)
        context.read<AuthCubit>().verifySignUp(widget.email, code);
      } else {
        // 2. Add Staff Flow (Needs Token)
        final authState = context.read<AuthCubit>().state;

        if (authState is AuthSuccess) {
          // Verify & Refresh list using the owner's token
          // Ensure your UserModel has a getter for token or use authState.user.token!
          final token = authState.user.token;
          context.read<StaffCubit>().verifyStaff(widget.email, code, token);
        } else {
          // Security fallback: If they lost session, send to login
          Navigator.of(context).pushReplacementNamed(Routes.login);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Wrapper to listen to EITHER AuthCubit OR StaffCubit
    // Since BlocListener can't easily listen to two different types conditionally,
    // we nest them. Inner listens to Staff, Outer listens to Auth.
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Email")),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (widget.mode == VerificationMode.ownerSignup) {
            if (state is AuthError) {
              _showError(state.message);
            } else if (state is AuthSuccess) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          }
        },
        child: BlocListener<StaffCubit, StaffState>(
          listener: (context, state) {
            if (widget.mode == VerificationMode.addStaff) {
              if (state is StaffError) {
                _showError(state.message);
              } else if (state is StaffSuccess) {
                // Success for Staff: Just go back to Dashboard/Staff List
                Navigator.pop(context); // Close Verification
                Navigator.pop(context, true); // Close Add Staff Form
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Staff added successfully!")),
                );
              }
            }
          },
          child: _buildContent(theme), // Extract UI to keep code clean
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildContent(ThemeData theme) {
    // Determine loading state based on mode
    final authLoading = context.watch<AuthCubit>().state is AuthLoading;
    final staffLoading = context.watch<StaffCubit>().state is StaffLoading;
    final isLoading = authLoading || staffLoading;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.mark_email_unread_outlined,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              "Check Inbox",
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Code sent to:\n${widget.email}",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),

            // Input
            TextFormField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: "000000",
                counterText: "",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (v) => (v?.length != 6) ? "Enter 6 digits" : null,
            ),
            const SizedBox(height: 32),

            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _verify,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: const Text(
                  "VERIFY",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
