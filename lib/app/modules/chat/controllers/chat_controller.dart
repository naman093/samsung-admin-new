import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/common/core/utils/result.dart';
import 'package:samsung_admin_main_new/app/models/user_model.dart';

import '../../../repository/chat_repo.dart';
import '../../../models/chat_model.dart';

class ChatController extends GetxController {
  final RxList<UserModel> users = <UserModel>[].obs;
  final Rxn<UserModel> selectedUser = Rxn<UserModel>();
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoadingMessages = false.obs;
  final TextEditingController messageController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final Rx<String> searchQuery = ''.obs;
  final ScrollController messagesScrollController = ScrollController();

  final chatRepo = Get.find<ChatRepo>();

  final RxnString currentConversationId = RxnString();

  Timer? _pollingTimer;

  /// Users filtered by current search query (by fullName and phoneNumber).
  List<UserModel> get filteredUsers {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return users;
    return users
        .where(
          (u) =>
              (u.fullName?.toLowerCase().contains(q) ?? false) ||
              (u.phoneNumber.replaceAll(RegExp(r'\D'), '').contains(q)),
        )
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    getAllUsers();
  }

  @override
  void onClose() {
    searchController.dispose();
    messageController.dispose();
    messagesScrollController.dispose();
    _stopPollingMessages();
    super.onClose();
  }

  void selectUser(UserModel user) async {
    selectedUser.value = user;
    messages.clear();
    isLoadingMessages.value = true;

    final result = await chatRepo.getOrCreateConversation(user.id);
    if (result.isSuccess) {
      final conversation = result.dataOrNull;
      currentConversationId.value = conversation?.id;
      if (conversation != null) {
        await fetchMessages(conversation.id);
        _startPollingMessages(conversation.id);
      }
    } else {
      debugPrint('Error creating conversation: ${result.errorOrNull}');
      isLoadingMessages.value = false;
    }
  }

  Future<void> sendMessage() async {
    final content = messageController.text.trim();
    if (content.isEmpty ||
        selectedUser.value == null ||
        currentConversationId.value == null)
      return;

    final currentUserId = chatRepo.currentUserId;
    if (currentUserId == null) return;

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final newMessage = MessageModel(
      id: tempId,
      conversationId: currentConversationId.value!,
      senderId: currentUserId,
      content: content,
      media: [],
      metadata: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    messages.add(newMessage);
    messageController.clear();

    // Always scroll to bottom when the current user sends a message.
    await _scrollToBottom(force: true);

    final result = await chatRepo.sendMessage(newMessage);
    if (result.isSuccess && result.dataOrNull != null) {
      final created = result.dataOrNull!;
      final idx = messages.indexWhere((m) => m.id == tempId);
      if (idx != -1) messages[idx] = created;
    }
  }

  Future<void> fetchMessages(
    String conversationId, {
    bool showLoader = true,
  }) async {
    if (showLoader) {
      isLoadingMessages.value = true;
    }
    try {
      final result = await chatRepo.getMessages(conversationId);
      if (result.isSuccess) {
        messages.value = result.dataOrNull ?? [];
        await _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error fetching messages: $e');
    } finally {
      if (showLoader) {
        isLoadingMessages.value = false;
      }
    }
  }

  bool get _isNearBottom {
    if (!messagesScrollController.hasClients) return true;
    final position = messagesScrollController.position;
    // Consider user "at bottom" if within 100px of the end.
    return (position.maxScrollExtent - position.pixels) <= 100;
  }

  Future<void> _scrollToBottom({bool force = false}) async {
    if (!messagesScrollController.hasClients) return;
    if (!force && !_isNearBottom) return;

    // Give the list a moment to layout before scrolling.
    await Future.delayed(const Duration(milliseconds: 50));
    if (!messagesScrollController.hasClients) return;

    try {
      await messagesScrollController.animateTo(
        messagesScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } catch (_) {
      // Ignore if scroll position is not ready.
    }
  }

  void _startPollingMessages(String conversationId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      // Only poll for the active conversation and avoid overlapping calls.
      if (currentConversationId.value != conversationId ||
          isLoadingMessages.value) {
        return;
      }
      await fetchMessages(conversationId, showLoader: false);
    });
  }

  void _stopPollingMessages() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> getAllUsers() async {
    try {
      final result = await chatRepo.getAllUsers();
      if (result.isSuccess) {
        debugPrint('🔥 Users fetched successfully: ${result.dataOrNull}');
        users.value = result.dataOrNull ?? [];
        // Open first chat by default when user visits the screen
        if (users.isNotEmpty && selectedUser.value == null) {
          selectUser(users.first);
        }
      } else {
        debugPrint(
          '🔥 Exception occurred in getting users: ${result.errorOrNull}',
        );
      }
    } catch (err) {
      debugPrint('🔥 Exception occurred in getting users: $err');
    } finally {}
  }
}
