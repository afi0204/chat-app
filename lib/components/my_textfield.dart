import 'package:flutter/material.dart';
import 'package:flutter_chat_app/theme/colors.dart'; // <-- Use your app name

class MyTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;

  const MyTextField({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.textSecondary),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.accent),
            borderRadius: BorderRadius.circular(12),
          ),
          fillColor: AppColors.primary.withOpacity(0.5),
          filled: true,
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
