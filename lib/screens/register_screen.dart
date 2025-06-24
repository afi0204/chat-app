import 'package:flutter/material.dart';
import 'package:flutter_chat_app/services/auth_service.dart';
import 'package:flutter_chat_app/components/my_textfield.dart';
import 'package:flutter_chat_app/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final void Function()? onTap;

  RegisterScreen({super.key, required this.onTap});

  // THIS IS THE CORRECTED FUNCTION
  void register(BuildContext context) async {
    // <-- Added 'async'
    final authService = AuthService();
    final displayName = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!")),
      );
      return;
    }

    try {
      // We now use 'await' and wrap the call in a 'try' block
      await authService.signUpWithEmailPassword(email, password, displayName);
    } on FirebaseAuthException catch (e) {
      // The 'catch' block now handles the specific exception
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email address is already in use.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak (6+ characters required).';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'api-key-not-valid':
          errorMessage =
              'API Key is not valid. Check your Firebase configuration.';
          break;
        default:
          errorMessage = 'An error occurred. Please try again.';
          print("FIREBASE AUTH ERROR: ${e.code}");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // The build method remains the same as what you have
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.message, size: 80, color: AppColors.accent),
                const SizedBox(height: 50),
                const Text("Let's create an account for you!",
                    style:
                        TextStyle(color: AppColors.textPrimary, fontSize: 16)),
                const SizedBox(height: 25),
                MyTextField(
                    hintText: "Display Name",
                    obscureText: false,
                    controller: _nameController),
                const SizedBox(height: 10),
                MyTextField(
                    hintText: "Email",
                    obscureText: false,
                    controller: _emailController),
                const SizedBox(height: 10),
                MyTextField(
                    hintText: "Password",
                    obscureText: true,
                    controller: _passwordController),
                const SizedBox(height: 10),
                MyTextField(
                    hintText: "Confirm Password",
                    obscureText: true,
                    controller: _confirmPasswordController),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () => register(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Register",
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? ",
                        style: TextStyle(color: AppColors.textSecondary)),
                    GestureDetector(
                      onTap: onTap,
                      child: const Text(
                        "Login now",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
