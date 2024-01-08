import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/constants/firebase_constants.dart';
import 'package:reddit/core/failure.dart';
import 'package:reddit/core/providers/firebase_providers.dart';
import 'package:reddit/core/type_defs.dart';
import 'package:reddit/models/chat_contact.dart';
import 'package:reddit/models/message_model.dart';

final chatRepositoryProvider = Provider((ref) {
  return ChatRepository(firestore: ref.watch(firestoreProvider));
});

class ChatRepository {
  final FirebaseFirestore _firestore;
  ChatRepository({required FirebaseFirestore firestore}): _firestore = firestore;

  CollectionReference get _chats => _firestore.collection(FirebaseConstants.chatsCollection);
  CollectionReference get _contacts => _firestore.collection(FirebaseConstants.contactsCollection);

  FutureVoid addMessage(Message message) async {
    try {
      return right(_chats.doc(message.id).set(message.toMap())); 
    } on FirebaseException catch(e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid addContact(String contactId, String userId) async {
    try {
      return right(
        _contacts.doc(userId).update({
          'contacts': FieldValue.arrayUnion([contactId]),
        })); 
    } on FirebaseException catch(e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<ChatContact> getContact(String uid) {
    return _contacts.doc(uid).snapshots()
          .where((event) => (event.data() != null))
          .map((event) => ChatContact.fromMap(event.data() as Map<String, dynamic>));
  }

  Stream<List<Message>> getMessages(String senderId, String receiverId) {
   
    return _chats
        .where(Filter.or(
          Filter.and(
            Filter('senderId', isEqualTo: senderId),
            Filter('receiverId', isEqualTo: receiverId),
          ),
          Filter.and(
            Filter('senderId', isEqualTo: receiverId),
            Filter('receiverId', isEqualTo: senderId),
          ),
        ))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs
            .map(
              (e) => Message.fromMap(e.data() as Map<String, dynamic>),
            )
            .toList());
  }

  Stream<List<ChatContact>> getUserContacts(String userId) {
    return _contacts
        .where('contacts', arrayContains: userId)
        .snapshots()
        .map((event) {List<ChatContact> contacts = [];
          for (var doc in event.docs)
          {
            if (doc.data() != null) {
              contacts.add(ChatContact.fromMap(doc.data() as Map<String,dynamic>));
            }
          }
          return contacts;
        });
  }
}