import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/features/chat/controller/chat_controller.dart';
import 'package:reddit/features/chat/widgets/message_bubble.dart';
import 'package:reddit/theme/pallete.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String uid;

  const ChatScreen({
    super.key,
    required this.uid,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {

  final chatController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    chatController.dispose();
  }

  void addMessage() {
    ref.watch(chatControllerProvider.notifier).shareMessage(
          context: context,
          text: chatController.text.trim(),
          receiverId: widget.uid,
        );
    chatController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: ref.watch(getContactProvider(widget.uid)).when(
                data: (data) => Text(data.name), 
                error: (error, stackTrace) => ErrorText(error: error.toString()),
                loading: () => const Loader(),
              ),
        leading: ref.watch(getContactProvider(widget.uid)).when(
                  data: (data) => Padding(
                          padding: const EdgeInsets.all(8.0).copyWith(right: 0),
                          child: CircleAvatar(
                          backgroundImage: NetworkImage(data.profilePic),
                        ),
                 ),
                  error: (error, stackTrace) => ErrorText(error: error.toString()),
                  loading: () => const Loader(),
                ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10,),
          Expanded(
            child: ref.watch(userMessagesProvider(widget.uid)).when(
                  data: (message) => Align(
                    alignment: Alignment.topCenter,
                    child: ListView.builder(
                      reverse: true,
                      shrinkWrap: true,
                      itemCount: message.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (widget.uid == message[index].receiverId) {
                          return Align(
                              alignment: Alignment.topRight,
                              child: UnconstrainedBox(
                                child: MessageBubble(
                                  text: message[index].text,
                                  color: Colors.blueAccent,
                                  textColor: Colors.white,
                                ),
                              ));
                        }
                        return Align(
                              alignment: Alignment.topLeft,
                              child: UnconstrainedBox(
                                child: MessageBubble(
                                  text: message[index].text,
                                  color: currentTheme == Pallete.darkModeAppTheme 
                                          ? Colors.grey.shade900
                                          : Colors.grey.shade200,
                                  textColor: currentTheme == Pallete.darkModeAppTheme
                                            ? Colors.white
                                            : Colors.black,
                                ),
                              ));
                      },
                    ),
                  ),
                  error: (error, stackTrace) =>
                      ErrorText(error: error.toString()),
                  loading: () => const Loader(),
                ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  maxLines: 5,
                  minLines: 1,
                  controller: chatController,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    filled: true,
                    border: InputBorder.none,
                    hintText: 'Message',
                  ),
                ),
              ),
              IconButton(
                onPressed: addMessage,
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ],
      ),
    );
    
  }
}