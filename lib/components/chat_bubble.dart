import 'package:flutter/material.dart';
import 'package:flutter_chat_app/theme/colors.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final DateTime timestamp;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCurrentUser
                ? AppColors.senderBubble
                : AppColors.receiverBubble,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(message,
              style: const TextStyle(color: AppColors.textPrimary)),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('h:mm a').format(timestamp),
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
