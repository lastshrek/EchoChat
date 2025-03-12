import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import '../utils/storage_util.dart';
import '../models/websocket_events.dart';
import '../models/websocket_models.dart';
import 'package:flutter/widgets.dart';

class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();
  static WebSocketManager get instance => _instance;

  IO.Socket? _socket;
  bool _isConnected = false;
  final String _wsUrl = 'http://192.168.50.84:3000'; // 改回原来的 IP

  // 连接状态流
  final _connectionStateController = StreamController<bool>.broadcast();
  Stream<bool> get connectionState => _connectionStateController.stream;

  // 添加一个变量来存储消息处理器
  Function(ChatMessage)? _messageHandler;

  WebSocketManager._internal();

  Future<void> connect() async {
    if (_isConnected) return;

    try {
      final token = await StorageUtil.getToken();
      if (token == null) {
        throw Exception('Token not found');
      }

      print('开始连接Socket.IO...');
      print('URL: $_wsUrl');
      print('Token: Bearer $token');

      _socket = IO.io(
          _wsUrl,
          IO.OptionBuilder()
              .setTransports(['websocket'])
              .setAuth({
                'token': 'Bearer $token',
              })
              .enableReconnection()
              .setReconnectionAttempts(5)
              .setReconnectionDelay(3000)
              .enableForceNew()
              .enableAutoConnect()
              .build());

      // 连接前监听所有事件
      _socket?.onConnecting((_) => print('正在连接...'));

      _socket?.onConnect((_) {
        print('Socket.IO连接成功!');
        _isConnected = true;
        _connectionStateController.add(true);

        // 在连接成功后设置消息监听器
        _setupMessageHandler();
      });

      _socket?.onConnectError((data) {
        print('连接错误: $data');
        print('认证信息: ${_socket?.auth}');
        _isConnected = false;
        _connectionStateController.add(false);
      });

      _socket?.onConnectTimeout((_) {
        print('连接超时!');
        _isConnected = false;
        _connectionStateController.add(false);
      });

      _socket?.onDisconnect((_) {
        print('Socket.IO连接断开');
        _isConnected = false;
        _connectionStateController.add(false);
      });

      _socket?.onError((error) {
        print('Socket.IO错误: $error');
        _isConnected = false;
        _connectionStateController.add(false);
      });

      _socket?.onAny((event, data) {
        print('调试 - 收到事件: $event');
        print('调试 - 数据: $data');
      });

      // 手动启动连接
      print('正在启动连接...');
      _socket?.connect();
      print('连接命令已发送');
    } catch (e) {
      print('发生异常: $e');
      _isConnected = false;
      _connectionStateController.add(false);
      rethrow;
    }
  }

  // 添加私有方法来设置消息监听器
  void _setupMessageHandler() {
    if (_messageHandler == null) return;

    print('正在设置消息监听器...');
    _socket?.on('message', (data) {
      print('收到消息事件');
      print('消息数据: $data');

      try {
        if (data is Map<String, dynamic>) {
          print('数据类型正确，开始解析');
          final messageData = data['data'] as Map<String, dynamic>;
          print('解析出消息数据: $messageData');

          final message = ChatMessage.fromJson(messageData);
          print('成功创建消息对象: ${message.content}');

          // 直接调用处理器，不使用 addPostFrameCallback
          _messageHandler?.call(message);
          print('消息处理器已调用');
        }
      } catch (e, stack) {
        print('消息处理错误: $e');
        print('错误堆栈: $stack');
      }
    });
    print('消息监听器设置完成');
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _isConnected = false;
    _connectionStateController.add(false);
  }

  bool get isConnected => _isConnected;

  void emit(String event, dynamic data) {
    if (!_isConnected) {
      throw Exception('Socket.IO未连接');
    }
    _socket?.emit(event, data);
  }

  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  void dispose() {
    disconnect();
    _connectionStateController.close();
  }

  // 修改 onMessage 方法
  void onMessage(Function(ChatMessage) handler) {
    print('注册消息处理器');
    _messageHandler = handler;

    // 如果已经连接，立即设置监听器
    if (_isConnected) {
      _setupMessageHandler();
    }
  }

  void onFriendRequest(Function(FriendRequest) handler) {
    _socket?.on(WebSocketEvent.friendRequest.value, (data) {
      final request = FriendRequest.fromJson(data['data']['request']);
      handler(request);
    });
  }

  void onFriendStatus(Function(int userId, bool isOnline) handler) {
    _socket?.on(WebSocketEvent.friendOnline.value, (data) {
      handler(data['userId'], true);
    });
    _socket?.on(WebSocketEvent.friendOffline.value, (data) {
      handler(data['userId'], false);
    });
  }

  void onTyping(Function(int userId, int chatId) handler) {
    _socket?.on(WebSocketEvent.userTyping.value, (data) {
      handler(data['data']['userId'], data['data']['chatId']);
    });
  }

  void onStopTyping(Function(int userId, int chatId) handler) {
    _socket?.on(WebSocketEvent.userStopTyping.value, (data) {
      handler(data['data']['userId'], data['data']['chatId']);
    });
  }

  // 发送消息方法
  void sendMessage(
    String content, {
    required int receiverId,
    required int chatId,
  }) {
    if (!_isConnected) {
      throw Exception('Socket.IO未连接');
    }
    print('发送消息到服务器: content=$content, receiverId=$receiverId, chatId=$chatId');
    _socket?.emit('message', {
      // 修改这里，使用 'message' 而不是 WebSocketEvent
      'chatId': chatId,
      'receiverId': receiverId,
      'type': 'TEXT',
      'content': content,
    });
  }

  // 发送输入状态
  void sendTyping(int chatId) {
    if (_isConnected) {
      _socket?.emit(WebSocketEvent.typing.value, {'chatId': chatId});
    }
  }

  void sendStopTyping(int chatId) {
    if (_isConnected) {
      _socket?.emit(WebSocketEvent.stopTyping.value, {'chatId': chatId});
    }
  }

  // 加入聊天室
  void joinChat(int chatId) {
    if (_isConnected) {
      _socket?.emit(WebSocketEvent.joinChat.value, {'chatId': chatId});
    }
  }

  // 离开聊天室
  void leaveChat(int chatId) {
    if (_isConnected) {
      _socket?.emit(WebSocketEvent.leaveChat.value, {'chatId': chatId});
    }
  }
}
