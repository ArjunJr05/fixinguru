import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hey, are you available for work?",
      time: "10:00 AM",
      isMe: false,
      senderName: "Arjun",
      isRead: true,
    ),
    ChatMessage(
      text: "Yes, I am available! How can I assist you?",
      time: "10:02 AM",
      isMe: true,
      senderName: "Me",
      isRead: true,
    ),
    ChatMessage(
      text: "I need help with assembling some furniture.",
      time: "10:05 AM",
      isMe: false,
      senderName: "Arjun",
      isRead: true,
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _handleSendPressed() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: text,
            time: _getCurrentTime(),
            isMe: true,
            senderName: "Me",
            isRead: false,
          ),
        );
      });
      _messageController.clear();
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    String hour = now.hour.toString().padLeft(2, '0');
    String minute = now.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 360;
    final textScaleFactor = mediaQuery.textScaleFactor;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E1E1E),
        leadingWidth: 30,
        titleSpacing: 5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: isSmallScreen ? 40 : 45,
              height: isSmallScreen ? 40 : 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF00C853),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                backgroundImage: const AssetImage("assets/images/ganesh2.jpg"),
                radius: isSmallScreen ? 18 : 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Arjun",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Online",
                    style: TextStyle(
                      color: const Color(0xFF00C853),
                      fontSize: isSmallScreen ? 12 : 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: Colors.white),
            onPressed: () {},
            iconSize: isSmallScreen ? 22 : 24,
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: Colors.white),
            onPressed: () {},
            iconSize: isSmallScreen ? 22 : 24,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
            iconSize: isSmallScreen ? 22 : 24,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Date header
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Today",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: isSmallScreen ? 11 : 12,
                ),
              ),
            ),

            // Chat messages
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _messages.length,
                reverse: false,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final showAvatar = !message.isMe &&
                      (index == 0 || _messages[index - 1].isMe);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ChatBubble(
                      message: message,
                      showAvatar: showAvatar,
                      isSmallScreen: isSmallScreen,
                    ),
                  );
                },
              ),
            ),

            // Input field
            Container(
              margin: const EdgeInsets.all(8),
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF2C2C2C),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.emoji_emotions_outlined),
                    color: Colors.white.withOpacity(0.7),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minHeight: 36,
                      minWidth: 36,
                    ),
                    onPressed: () {},
                    iconSize: isSmallScreen ? 22 : 24,
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    color: Colors.white.withOpacity(0.7),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minHeight: 36,
                      minWidth: 36,
                    ),
                    onPressed: () {},
                    iconSize: isSmallScreen ? 22 : 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 5,
                      minLines: 1,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                      decoration: InputDecoration(
                        hintText: "Type a message",
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.only(bottom: 8),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _handleSendPressed,
                    child: Container(
                      width: isSmallScreen ? 38 : 42,
                      height: isSmallScreen ? 38 : 42,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00C853),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: isSmallScreen ? 18 : 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
                height: MediaQuery.of(context).viewInsets.bottom > 0 ? 0 : 8),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final String time;
  final bool isMe;
  final String senderName;
  final bool isRead;

  ChatMessage({
    required this.text,
    required this.time,
    required this.isMe,
    required this.senderName,
    required this.isRead,
  });
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showAvatar;
  final bool isSmallScreen;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.showAvatar,
    required this.isSmallScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!message.isMe && showAvatar)
          CircleAvatar(
            radius: isSmallScreen ? 14 : 16,
            backgroundImage: const AssetImage("assets/images/user1.png"),
          )
        else if (!message.isMe)
          SizedBox(width: isSmallScreen ? 28 : 32),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: message.isMe
                  ? const Color(0xFF00C853).withOpacity(0.9)
                  : const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft:
                    message.isMe ? Radius.circular(18) : Radius.circular(4),
                bottomRight:
                    message.isMe ? Radius.circular(4) : Radius.circular(18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                    color: message.isMe
                        ? Colors.white
                        : Colors.white.withOpacity(0.9),
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      message.time,
                      style: TextStyle(
                        color: message.isMe
                            ? Colors.white.withOpacity(0.8)
                            : Colors.white.withOpacity(0.5),
                        fontSize: isSmallScreen ? 10 : 11,
                      ),
                    ),
                    if (message.isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.isRead ? Icons.done_all : Icons.done,
                        size: isSmallScreen ? 14 : 16,
                        color: message.isRead
                            ? Colors.white
                            : Colors.white.withOpacity(0.8),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
