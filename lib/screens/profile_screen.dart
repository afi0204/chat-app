import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_chat_app/services/auth_service.dart';
import 'package:flutter_chat_app/services/storage_service.dart';
import 'package:flutter_chat_app/theme/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  bool _isLoading = false;

  Future<void> _pickAndUploadImage() async {
    setState(() => _isLoading = true);

    try {
      await _storageService.pickAndUploadProfileImage();
      // The StreamBuilder will automatically rebuild with the new photoURL
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('Failed to update profile picture: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        final User? currentUser = snapshot.data;

        return Scaffold(
          backgroundColor: AppColors.primary,
          appBar: AppBar(
            title: const Text("Profile"),
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
          ),
          body: Center(
            child: (currentUser == null)
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Profile Avatar
                      GestureDetector(
                        onTap: _isLoading ? null : _pickAndUploadImage,
                        child: _buildProfileAvatar(currentUser),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Tap picture to change",
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        currentUser.displayName ?? 'No display name',
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(currentUser.email ?? '',
                          style:
                              const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildProfileAvatar(User currentUser) {
    // Use a Stack to overlay the loading indicator
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: AppColors.accent,
          backgroundImage:
              currentUser.photoURL != null && currentUser.photoURL!.isNotEmpty
                  ? NetworkImage(currentUser.photoURL!)
                  : null,
          child: currentUser.photoURL == null || currentUser.photoURL!.isEmpty
              ? const Icon(Icons.person, size: 60, color: AppColors.primary)
              : null,
        ),
        if (_isLoading)
          const CircularProgressIndicator(color: AppColors.accent),
      ],
    );
  }
}
