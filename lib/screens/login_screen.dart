import 'package:flutter/material.dart';
import 'package:flutter_chat_app/services/auth_service.dart'; // <-- Use your app name
import 'package:flutter_chat_app/components/my_textfield.dart'; // <-- Use your app name
import 'package:flutter_chat_app/theme/colors.dart'; // <-- Use your app name

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final void Function()? onTap;

  LoginScreen({super.key, required this.onTap});

  void login(BuildContext context) async {
    final authService = AuthService();
    try {
      await authService.signInWithEmailPassword(
        _emailController.text,
        _passwordController.text,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.message, size: 80, color: AppColors.accent),
              const SizedBox(height: 50),
              const Text("Welcome back, you've been missed!",
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
              const SizedBox(height: 25),
              MyTextField(
                  hintText: "Email",
                  obscureText: false,
                  controller: _emailController),
              const SizedBox(height: 10),
              MyTextField(
                  hintText: "Password",
                  obscureText: true,
                  controller: _passwordController),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () => login(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Login",
                    style: TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Not a member? ",
                      style: TextStyle(color: AppColors.textSecondary)),
                  GestureDetector(
                    onTap: onTap,
                    child: const Text("Register now",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
