import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/providers/storage_repository_provider.dart';
import 'package:reddit/core/utils.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/chat/repository/chat_repository.dart';
import 'package:reddit/models/chat_contact.dart';
import 'package:reddit/models/message_model.dart';
import 'package:uuid/uuid.dart';

final chatControllerProvider = StateNotifierProvider<ChatController, bool>((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  final storageRepository = ref.watch(firebaseStorageProvider);
  return ChatController(
      chatRepository: chatRepository,
      ref: ref,
      storageRepository: storageRepository,
  );
});

final userMessagesProvider = StreamProvider.family((ref, String receiverId){
  return ref.watch(chatControllerProvider.notifier).getMessages(receiverId);
});

final userContactsProvider = StreamProvider((ref){
  final chatController = ref.watch(chatControllerProvider.notifier); 
  return chatController.getUserContacts();
});

final getContactProvider = StreamProvider.family((ref, String uid){
  return ref.watch(chatControllerProvider.notifier).getContact(uid);
});

class ChatController extends StateNotifier<bool> {
  final ChatRepository _chatRepository;
  final Ref _ref;

  ChatController({
    required ChatRepository chatRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _chatRepository = chatRepository,
        _ref = ref,
        super(false);

  Stream<ChatContact> getContact(String uid) {
    return _chatRepository.getContact(uid);
  }

  void shareMessage({
    required BuildContext context,
    required String text,
    required String receiverId,
  }) async {
    state = true;
    String messageId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    var contact = await _chatRepository.getContact(receiverId).first;

    if(!contact.contacts.contains(user.uid))
    {
      final res = await _chatRepository.addContact(user.uid, receiverId);
      res.fold(
        (l) => showSnackBar(context,'${l.message} b'),
        (r) => null,
      );
    }

    contact = await _chatRepository.getContact(user.uid).first;

    if(!contact.contacts.contains(receiverId))
    {
      final res = await _chatRepository.addContact(receiverId, user.uid);
      res.fold(
        (l) => showSnackBar(context,'${l.message} b'),
        (r) => null,
      );
    }

    final Message message = Message(
      id: messageId,
      senderId: user.uid,
      receiverId: receiverId,
      text: text,
      createdAt: DateTime.now(),
    );

    final res = await _chatRepository.addMessage(message);
    state = false;

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => null,
    );
  }

  Stream<List<Message>> getMessages(String receiverId) {
    final user = _ref.read(userProvider)!;
    return _chatRepository.getMessages(user.uid, receiverId);
  }

  Stream<List<ChatContact>> getUserContacts() {
    final user = _ref.read(userProvider)!;
    return _chatRepository.getUserContacts(user.uid);
  }
  
}