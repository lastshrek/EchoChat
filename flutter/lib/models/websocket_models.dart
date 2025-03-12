import 'package:flutter/foundation.dart';
import '../models/user.dart';

class ChatMessage {
  final int id;
  final String content;
  final String type;
  final String status;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int senderId;
  final int receiverId;
  final int chatId;
  final User sender;
  final User receiver;

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.status,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    required this.senderId,
    required this.receiverId,
    required this.chatId,
    required this.sender,
    required this.receiver,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['content'],
      type: json['type'],
      status: json['status'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      chatId: json['chatId'],
      sender: User.fromJson(json['sender']),
      receiver: User.fromJson(json['receiver']),
    );
  }
}

class FriendRequest {
  final int id;
  final int fromId;
  final int toId;
  final String status;
  final String? message;
  final String createdAt;
  final String updatedAt;
  final User from;
  final User to;

  FriendRequest({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.status,
    this.message,
    required this.createdAt,
    required this.updatedAt,
    required this.from,
    required this.to,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'],
      fromId: json['fromId'],
      toId: json['toId'],
      status: json['status'],
      message: json['message'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      from: User.fromJson(json['from']),
      to: User.fromJson(json['to']),
    );
  }
}
