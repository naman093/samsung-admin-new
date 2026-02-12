import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/app_theme/app_colors.dart';
import 'package:samsung_admin_main_new/app/common/widgets/network_image_widget.dart';
import 'package:samsung_admin_main_new/app/modules/chat/controllers/chat_controller.dart';
import 'package:samsung_admin_main_new/app/models/user_model.dart';
import 'package:samsung_admin_main_new/app/models/chat_model.dart';

class ChatArea extends StatelessWidget {
  ChatArea({super.key});

  final ChatController _controller = Get.find<ChatController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedUser = _controller.selectedUser.value;

      if (selectedUser == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Select a user to start chatting',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          _buildHeader(selectedUser),
          Expanded(child: _buildMessageList()),
          _buildInputArea(),
        ],
      );
    });
  }

  Widget _buildHeader(UserModel user) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.only(
          // topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border(bottom: BorderSide(color: AppColors.backgroundColor)),
      ),
      child: Row(
        children: [
          NetworkImageWidget(
            imageUrl: user.profilePictureUrl ?? '',
            height: 40,
            width: 40,
            radius: 100,
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName ?? 'Unknown User',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              // if (user.isOnline)
              //   Text(
              //     'Online',
              //     style: TextStyle(color: Colors.green, fontSize: 12),
              //   ),
            ],
          ),
          Spacer(),
          // IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_controller.isLoadingMessages.value) {
      return Center(child: CircularProgressIndicator());
    }

    if (_controller.messages.isEmpty) {
      return Center(child: Text('No messages yet'));
    }

    return ListView.builder(
      controller: _controller.messagesScrollController,
      padding: EdgeInsets.all(16),
      itemCount: _controller.messages.length,
      itemBuilder: (context, index) {
        final message = _controller.messages[index];
        // Placeholder check for "is me". In real app, check against auth user ID.
        // For now, let's assume if senderId != selectedUser.id, it's me.
        final isMe = message.senderId != _controller.selectedUser.value?.id;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: _buildMessageBubble(message, isMe),
        );
      },
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    return Align(
      key: ValueKey(message.id),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: isMe
              ? Color(0xFFDCF8C6)
              : Colors.white, // WhatsApp-like colors
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: isMe ? Radius.circular(12) : Radius.circular(0),
            bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.content ?? '',
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ),
            SizedBox(height: 4),
            Text(
              _formatTime(message.createdAt),
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        border: Border(top: BorderSide(color: AppColors.cardColor)),
      ),
      child: Row(
        children: [
          // IconButton(icon: Icon(Icons.attach_file), onPressed: () {}),
          Expanded(
            child: TextField(
              controller: _controller.messageController,
              decoration: InputDecoration(
                hintText: 'Type a message',
                hintStyle: TextStyle(color: AppColors.greyColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.cardColor,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) => _controller.sendMessage(),
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Color(0xFF128C7E), // WhatsApp green
            radius: 24,
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _controller.sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
