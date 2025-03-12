enum WebSocketEvent {
  // 连接相关
  connect,
  disconnect,
  connectError,

  // 聊天相关
  newMessage,
  typing,
  stopTyping,

  // 好友相关
  friendRequest,
  friendRequestAccepted,
  friendRequestRejected,
  friendOnline,
  friendOffline,

  // 通知相关
  notification,

  // 消息发送状态
  messageSent,
  messageDelivered,
  messageRead,
  messageError,

  // 用户输入状态
  userTyping,
  userStopTyping,

  // 聊天室相关
  joinChat,
  leaveChat,
  joinedChat,
}

// 扩展方法，用于将枚举转换为字符串
extension WebSocketEventExtension on WebSocketEvent {
  String get value {
    switch (this) {
      case WebSocketEvent.connect:
        return 'connect';
      case WebSocketEvent.disconnect:
        return 'disconnect';
      case WebSocketEvent.connectError:
        return 'connect_error';
      case WebSocketEvent.newMessage:
        return 'message';
      case WebSocketEvent.typing:
        return 'typing';
      case WebSocketEvent.stopTyping:
        return 'stopTyping';
      case WebSocketEvent.friendRequest:
        return 'friend_request';
      case WebSocketEvent.friendRequestAccepted:
        return 'friend_request_accepted';
      case WebSocketEvent.friendRequestRejected:
        return 'friend_request_rejected';
      case WebSocketEvent.friendOnline:
        return 'friend_online';
      case WebSocketEvent.friendOffline:
        return 'friend_offline';
      case WebSocketEvent.notification:
        return 'notification';
      case WebSocketEvent.messageSent:
        return 'messageSent';
      case WebSocketEvent.messageDelivered:
        return 'messageDelivered';
      case WebSocketEvent.messageRead:
        return 'messageRead';
      case WebSocketEvent.messageError:
        return 'messageError';
      case WebSocketEvent.userTyping:
        return 'userTyping';
      case WebSocketEvent.userStopTyping:
        return 'userStopTyping';
      case WebSocketEvent.joinChat:
        return 'join';
      case WebSocketEvent.leaveChat:
        return 'leave';
      case WebSocketEvent.joinedChat:
        return 'joined';
    }
  }
}
