import 'package:flutter/material.dart';
import 'package:flutter_chat_app/services/auth_service.dart';
import 'package:flutter_chat_app/models/user_model.dart';
import 'package:flutter_chat_app/services/chat_service.dart';
import 'package:flutter_chat_app/components/user_tile.dart';
import 'package:flutter_chat_app/screens/profile_screen.dart'; // Added for ProfileScreen navigation
import 'package:flutter_chat_app/screens/chat_screen.dart';
import 'package:flutter_chat_app/theme/colors.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        // We moved the logout button to the drawer, so actions can be empty
        actions: const [],
      ),
      // The drawer is where we will put the Profile and Logout buttons
      drawer: Drawer(
        backgroundColor: AppColors.primary,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const DrawerHeader(
                  child: Center(
                    child:
                        Icon(Icons.message, color: AppColors.accent, size: 60),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    title: const Text("H O M E",
                        style: TextStyle(color: AppColors.textPrimary)),
                    leading:
                        const Icon(Icons.home, color: AppColors.textPrimary),
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    title: const Text("P R O F I L E",
                        style: TextStyle(color: AppColors.textPrimary)),
                    leading:
                        const Icon(Icons.person, color: AppColors.textPrimary),
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProfileScreen()));
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0, bottom: 25.0),
              child: ListTile(
                title: const Text("L O G O U T",
                    style: TextStyle(color: AppColors.textPrimary)),
                leading: const Icon(Icons.logout, color: AppColors.textPrimary),
                onTap: () => _authService.signOut(),
              ),
            ),
          ],
        ),
      ),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<List<UserModel>>(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
              'Error: ${snapshot.error}'); // Keep original error message for debugging
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<UserModel> users = snapshot.data ?? [];

        return ListView(
          children: users
              .map<Widget>((user) => _buildUserListItem(user, context))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(UserModel user, BuildContext context) {
    return UserTile(
      // Removed redundant 'if' check as ChatService already filters
      displayName: user.displayName,
      photoURL: user.photoURL,
      onTap: () {
        // once tapped go to chat screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              receiverDisplayName: user.displayName,
              receiverID: user.uid,
              receiverPhotoURL: user.photoURL,
            ),
          ),
        );
      },
    );
  }
}
