import 'package:flutter/material.dart';
import 'package:flutter_chat_app/theme/colors.dart'; // <-- Use your app name

class UserTile extends StatelessWidget {
  final String displayName;
  final String? photoURL; // Make photoURL optional
  final void Function()? onTap;

  const UserTile({
    super.key,
    required this.displayName,
    this.photoURL,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.receiverBubble.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.accent.withOpacity(0.8),
              backgroundImage: photoURL != null && photoURL!.isNotEmpty
                  ? NetworkImage(photoURL!)
                  : null,
              child: photoURL == null || photoURL!.isEmpty
                  ? const Icon(Icons.person, color: AppColors.primary)
                  : null,
            ),
            const SizedBox(width: 20),
            Text(displayName,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
