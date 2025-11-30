import 'package:flutter/material.dart';
import 'package:innerbalance/core/services/zego_cloud_service.dart';
import 'package:innerbalance/core/theme/app_palette.dart';
import 'package:innerbalance/features/call/presentation/pages/call_page.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class ChatPage extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;

  const ChatPage({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();
  late final Stream<List<Map<String, dynamic>>> _messagesStream;
  final String _myUserId = Supabase.instance.client.auth.currentUser!.id;

  @override
  void initState() {
    super.initState();
    _messagesStream = Supabase.instance.client
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map((maps) => maps
            .where((map) =>
                (map['sender_id'] == _myUserId &&
                    map['receiver_id'] == widget.otherUserId) ||
                (map['sender_id'] == widget.otherUserId &&
                    map['receiver_id'] == _myUserId))
            .toList());
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();

    try {
      await Supabase.instance.client.from('messages').insert({
        'sender_id': _myUserId,
        'receiver_id': widget.otherUserId,
        'content': content,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: $e')),
        );
      }
    }
  }

  String _generateCallID(String userId1, String userId2) {
    // Sort IDs to ensure the same CallID for both participants
    final ids = [userId1, userId2]..sort();
    return ids.join('_');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              final callID = _generateCallID(_myUserId, widget.otherUserId);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CallPage(
                    callID: callID,
                    userID: _myUserId,
                    userName: 'User',
                    isVideoCall: false,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              final callID = _generateCallID(_myUserId, widget.otherUserId);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CallPage(
                    callID: callID,
                    userID: _myUserId,
                    userName: 'User',
                    isVideoCall: true,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;

                if (messages.isEmpty) {
                  return const Center(child: Text('Start the conversation!'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['sender_id'] == _myUserId;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isMe ? AppPalette.primary : Colors.grey[300],
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              message['content'],
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              timeago.format(
                                  DateTime.parse(message['created_at'])),
                              style: TextStyle(
                                fontSize: 10,
                                color: isMe
                                    ? Colors.white.withOpacity(0.7)
                                    : Colors.black.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: AppPalette.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
