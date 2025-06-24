import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_chat_app/models/message.dart';
import 'package:flutter_chat_app/components/chat_bubble.dart';
import 'package:flutter_chat_app/services/auth_service.dart';
import 'package:flutter_chat_app/services/chat_service.dart';
import 'package:flutter_chat_app/theme/colors.dart';

class ChatScreen extends StatefulWidget {
  final String receiverDisplayName;
  final String? receiverPhotoURL;
  final String receiverID;

  const ChatScreen({
    super.key,
    required this.receiverDisplayName,
    this.receiverPhotoURL,
    required this.receiverID,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final ScrollController _scrollController = ScrollController();

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverID, _messageController.text);
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.accent,
              backgroundImage: widget.receiverPhotoURL != null &&
                      widget.receiverPhotoURL!.isNotEmpty
                  ? NetworkImage(widget.receiverPhotoURL!)
                  : null,
              child: widget.receiverPhotoURL == null ||
                      widget.receiverPhotoURL!.isEmpty
                  ? const Icon(Icons.person, size: 18, color: AppColors.primary)
                  : null,
            ),
            const SizedBox(width: 10),
            // Use Flexible to prevent long names from causing a pixel overflow.
            Flexible(
              child: Text(widget.receiverDisplayName,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    final String? senderID = _authService.getCurrentUser()?.uid;
    // This case should ideally not be reached if your auth flow is correct.
    if (senderID == null) {
      return const Center(child: Text("User not logged in."));
    }
    return StreamBuilder(
      stream: _chatService.getMessages(senderID, widget.receiverID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong..."));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No messages yet. Say hi! 👋"),
          );
        }

        // auto scroll to bottom when new message comes
        _scrollToBottom();

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return _buildMessageItem(snapshot.data!.docs[index]);
          },
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    final message = Message.fromMap(doc.data() as Map<String, dynamic>);
    final String? currentUserID = _authService.getCurrentUser()?.uid;
    bool isCurrentUser = message.senderID == currentUserID;

    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    // Convert Firestore Timestamp to DateTime
    DateTime timestamp = message.timestamp.toDate();

    return Container(
      alignment: alignment,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ChatBubble(
        message: message.message,
        isCurrentUser: isCurrentUser,
        timestamp: timestamp,
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: "Type a message...",
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.receiverBubble.withOpacity(0.2),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: sendMessage,
            icon: const Icon(Icons.send, color: AppColors.textPrimary),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.accent,
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}
