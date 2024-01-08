import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/features/chat/controller/chat_controller.dart';
import 'package:reddit/models/chat_contact.dart';
import 'package:routemaster/routemaster.dart';

class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  void navigateToChatScreen(BuildContext context, ChatContact contact) {
    Routemaster.of(context).push('/chat-screen/${contact.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return ref.watch(userContactsProvider).when(
            data: (contacts) {
            return ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (BuildContext context, int index) {
                final contact = contacts[index];
                return ListTile(
                  onTap: () {
                      navigateToChatScreen(context, contact);
                  },
                  title: Text(contact.name),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(contact.profilePic),
                  ),
                );
              },
            );
            }, 
            error: (error, stackTrace) => ErrorText(error: error.toString()), 
            loading: () => const Loader(),
          );
  }
}