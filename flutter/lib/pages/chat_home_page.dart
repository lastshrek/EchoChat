import 'package:flutter/material.dart';
import '../models/user.dart';
import '../network/websocket_manager.dart';
import '../utils/storage_util.dart';
import '../models/websocket_models.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatHomePage extends StatefulWidget {
  final User user;

  const ChatHomePage({
    super.key,
    required this.user,
  });

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initWebSocket();
    _setupMessageListener();

    // 添加一条测试消息
    setState(() {
      _messages.add(ChatMessage(
        id: 0,
        content: '测试消息',
        type: 'TEXT',
        status: 'SENT',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        senderId: widget.user.id,
        receiverId: 7,
        chatId: 9,
        sender: widget.user,
        receiver: User(
          id: 7,
          username: 'test',
          avatar: 'https://api.dicebear.com/9.x/pixel-art-neutral/svg?seed=test',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ));
    });
  }

  Future<void> _initWebSocket() async {
    try {
      await WebSocketManager.instance.connect();
    } catch (e) {
      print('WebSocket连接失败: $e');
    }
  }

  void _setupMessageListener() {
    print('开始设置消息监听器');
    WebSocketManager.instance.onMessage((message) {
      print('收到新消息回调: ${message.content}');
      print('当前消息列表长度: ${_messages.length}');
      print('当前线程: ${WidgetsBinding.instance.schedulerPhase}');

      if (mounted) {
        print('组件仍然挂载，准备更新状态');
        setState(() {
          print('开始更新状态');
          _messages.insert(0, message);
          print('状态更新完成，新消息列表长度: ${_messages.length}');
        });
      } else {
        print('组件已卸载，不更新状态');
      }
    });
    print('消息监听器设置完成');
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    print('发送消息: $content');
    WebSocketManager.instance.sendMessage(
      content,
      receiverId: 7,
      chatId: 9,
    );

    // 清除输入框
    _messageController.clear();

    // 可以选择立即显示发送的消息
    setState(() {
      _messages.insert(
          0,
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch, // 临时ID
            content: content,
            type: 'TEXT',
            status: 'SENT',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            senderId: widget.user.id,
            receiverId: 7,
            chatId: 9,
            sender: widget.user,
            receiver: User(
              id: 7,
              username: 'test',
              avatar: 'https://api.dicebear.com/9.x/pixel-art-neutral/svg?seed=test',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ));
    });
  }

  Future<void> _handleLogout() async {
    // 断开 WebSocket 连接
    WebSocketManager.instance.disconnect();

    // 使用新的清除方法
    await StorageUtil.clearUserData();

    // 返回登录页面
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('构建页面，消息列表长度: ${_messages.length}');
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.user.username}的聊天'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // 添加退出按钮
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              // 显示确认对话框
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('确认退出'),
                  content: const Text('确定要退出登录吗？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _handleLogout();
                      },
                      child: const Text(
                        '确定',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // WebSocket 连接状态指示器
          StreamBuilder<bool>(
            stream: WebSocketManager.instance.connectionState,
            builder: (context, snapshot) {
              final isConnected = snapshot.data ?? false;
              return Container(
                padding: const EdgeInsets.all(8),
                color: isConnected ? Colors.green : Colors.red,
                child: Center(
                  child: Text(
                    isConnected ? '已连接到服务器' : '未连接到服务器',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          ),
          // 消息列表
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.senderId == widget.user.id;

                print('渲染消息: ${message.content}, 发送者: ${message.sender.username}');

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isMe) ...[
                        // 对方头像
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: SvgPicture.network(
                            message.sender.avatar,
                            placeholderBuilder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Padding(
                                padding: const EdgeInsets.only(left: 4, bottom: 4),
                                child: Text(
                                  message.sender.username,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.blue[100] : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                                  bottomRight: Radius.circular(isMe ? 4 : 16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    message.content,
                                    style: TextStyle(
                                      color: isMe ? Colors.black87 : Colors.black,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    message.createdAt.toString().substring(11, 16),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isMe)
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: SvgPicture.network(
                            message.sender.avatar,
                            placeholderBuilder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          // 输入框
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: '输入消息...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    WebSocketManager.instance.disconnect();
    super.dispose();
  }
}
