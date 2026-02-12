import 'package:flutter/widgets.dart';
import 'package:samsung_admin_main_new/app/common/core/utils/result.dart';
import 'package:samsung_admin_main_new/app/models/user_model.dart';
import 'package:samsung_admin_main_new/app/models/chat_model.dart';
import 'package:samsung_admin_main_new/app/models/conversation_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatRepo {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Current authenticated user id; null if not logged in.
  String? get currentUserId => supabase.auth.currentUser?.id;

  /// Fetch all non-admin users for starting chats.
  Future<Result<List<UserModel>>> getAllUsers() async {
    try {
      final response = await supabase
          .from('users')
          .select('*')
          .neq('role', 'admin')
          .or('deleted_at.is.null');

      final users = (response as List)
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return Success(users);
    } catch (err) {
      debugPrint('🔥 Exception occurred in getAllUsers: $err');
      return Failure(err.toString());
    }
  }

  /// Fetch a single user by id.
  Future<Result<UserModel>> getUserById(String userId) async {
    try {
      final response = await supabase
          .from('users')
          .select('*')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return Failure('User not found');

      return Success(UserModel.fromJson(Map<String, dynamic>.from(response)));
    } catch (err) {
      debugPrint('🔥 Exception occurred in getUserById: $err');
      return Failure(err.toString());
    }
  }

  /// Find existing 1-1 conversation between current user and [otherUserId], or create one.
  /// Uses tables: conversations, conversation_participants.
  Future<Result<ConversationModel>> getOrCreateConversation(
    String otherUserId,
  ) async {
    try {
      final uid = currentUserId;
      if (uid == null) return Failure('User not authenticated');

      // Find conversation where both users are participants (1-1, not deleted)
      final myParticipations = await supabase
          .from('conversation_participants')
          .select('conversation_id')
          .eq('user_id', uid)
          .or('deleted_at.is.null');

      final myList = myParticipations as List<dynamic>? ?? [];
      if (myList.isEmpty) return _createConversation(uid, otherUserId);

      for (final row in myList) {
        final conversationId = row['conversation_id'] as String?;
        if (conversationId == null) continue;

        final otherParticipant = await supabase
            .from('conversation_participants')
            .select('id')
            .eq('conversation_id', conversationId)
            .eq('user_id', otherUserId)
            .or('deleted_at.is.null')
            .maybeSingle();

        if (otherParticipant != null) {
          final convRow = await supabase
              .from('conversations')
              .select()
              .eq('id', conversationId)
              .or('deleted_at.is.null')
              .maybeSingle();
          if (convRow != null) {
            return Success(
              ConversationModel.fromJson(Map<String, dynamic>.from(convRow)),
            );
          }
        }
      }

      return _createConversation(uid, otherUserId);
    } catch (err) {
      debugPrint('🔥 Error in getOrCreateConversation: $err');
      return Failure(err.toString());
    }
  }

  Future<Result<ConversationModel>> _createConversation(
    String currentUserId,
    String otherUserId,
  ) async {
    final now = DateTime.now().toUtc().toIso8601String();

    final insertConv = await supabase
        .from('conversations')
        .insert({
          'is_group': false,
          'title': null,
          'created_by': currentUserId,
          'last_message_at': null,
          'created_at': now,
          'updated_at': now,
        })
        .select()
        .single();

    final conversation = ConversationModel.fromJson(
      Map<String, dynamic>.from(insertConv),
    );

    await supabase.from('conversation_participants').insert([
      {
        'conversation_id': conversation.id,
        'user_id': currentUserId,
        'joined_at': now,
      },
      {
        'conversation_id': conversation.id,
        'user_id': otherUserId,
        'joined_at': now,
      },
    ]);

    return Success(conversation);
  }

  /// Fetch messages for a conversation (table: conversation_messages).
  /// Excludes soft-deleted messages.
  Future<Result<List<MessageModel>>> getMessages(String conversationId) async {
    try {
      final response = await supabase
          .from('conversation_messages')
          .select('*')
          .eq('conversation_id', conversationId)
          .or('deleted_at.is.null')
          .order('created_at', ascending: true);

      final messages = (response as List)
          .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return Success(messages);
    } catch (err) {
      debugPrint('🔥 Exception in getMessages: $err');
      return Failure(err.toString());
    }
  }

  /// Send a message: insert into conversation_messages and update conversations.last_message_at.
  Future<Result<MessageModel>> sendMessage(MessageModel message) async {
    try {
      final row = await supabase
          .from('conversation_messages')
          .insert(message.toJsonForInsert())
          .select()
          .single();

      final created = MessageModel.fromJson(Map<String, dynamic>.from(row));

      final now = DateTime.now().toUtc().toIso8601String();
      await supabase
          .from('conversations')
          .update({'last_message_at': now, 'updated_at': now})
          .eq('id', message.conversationId);

      return Success(created);
    } catch (err) {
      debugPrint('🔥 Exception in sendMessage: $err');
      return Failure(err.toString());
    }
  }

  /// List conversations for the current user (for sidebar).
  Future<Result<List<ConversationModel>>> getMyConversations() async {
    try {
      final uid = currentUserId;
      if (uid == null) return Failure('User not authenticated');

      final participantRows = await supabase
          .from('conversation_participants')
          .select('conversation_id')
          .eq('user_id', uid)
          .or('deleted_at.is.null');

      final partList = participantRows as List<dynamic>? ?? [];
      if (partList.isEmpty) return Success([]);

      final ids = partList
          .map<String>((r) => r['conversation_id'] as String)
          .toSet()
          .toList();

      final convRows = await supabase
          .from('conversations')
          .select()
          .inFilter('id', ids)
          .or('deleted_at.is.null')
          .order('last_message_at', ascending: false);

      final list = (convRows as List)
          .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return Success(list);
    } catch (err) {
      debugPrint('🔥 Exception in getMyConversations: $err');
      return Failure(err.toString());
    }
  }
}
