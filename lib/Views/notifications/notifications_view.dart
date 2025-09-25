import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'data': data,
    };
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      data: data,
    );
  }
}

class NotificationService {
  static const String _notificationsKey = 'stored_notifications';
  
  static Future<void> saveNotification(NotificationModel notification) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getStoredNotifications();
    
    // Check if notification already exists (prevent duplicates)
    final exists = notifications.any((n) => n.id == notification.id);
    if (exists) {
      print('Notification already exists, skipping: ${notification.id}');
      return;
    }
    
    // Add new notification at the beginning
    notifications.insert(0, notification);
    
    // Keep only last 100 notifications to avoid storage issues
    if (notifications.length > 100) {
      notifications.removeRange(100, notifications.length);
    }
    
    final notificationsJson = notifications.map((n) => n.toJson()).toList();
    await prefs.setString(_notificationsKey, json.encode(notificationsJson));
    print('Notification saved: ${notification.id}');
  }
  
  static Future<List<NotificationModel>> getStoredNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsString = prefs.getString(_notificationsKey);
    
    if (notificationsString == null) return [];
    
    try {
      final List<dynamic> notificationsJson = json.decode(notificationsString);
      return notificationsJson
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error parsing stored notifications: $e');
      return [];
    }
  }
  
  static Future<void> markAsRead(String notificationId) async {
    final notifications = await getStoredNotifications();
    final updatedNotifications = notifications.map((notification) {
      if (notification.id == notificationId) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();
    
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = updatedNotifications.map((n) => n.toJson()).toList();
    await prefs.setString(_notificationsKey, json.encode(notificationsJson));
  }
  
  static Future<void> markAllAsRead() async {
    final notifications = await getStoredNotifications();
    final updatedNotifications = notifications
        .map((notification) => notification.copyWith(isRead: true))
        .toList();
    
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = updatedNotifications.map((n) => n.toJson()).toList();
    await prefs.setString(_notificationsKey, json.encode(notificationsJson));
  }
  
  static Future<void> clearAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationsKey);
  }
}

class NotificationsView extends StatefulWidget {
  const NotificationsView({Key? key}) : super(key: key);

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  List<NotificationModel> notifications = [];
  bool isLoading = true;
  String? fcmToken;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _getToken();
    await _setupFirebaseMessaging();
    await _loadStoredNotifications();
    setState(() => isLoading = false);
  }

  Future<void> _getToken() async {
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
      print("FCM Token: $fcmToken");
    } catch (e) {
      print("Error getting FCM token: $e");
    }
  }

  Future<void> _setupFirebaseMessaging() async {
    // Request permission for iOS
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle foreground messages ONLY
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.messageId}');
      _handleMessage(message, 'foreground');
    });

    // Handle background message taps ONLY (don't save again)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message opened app: ${message.messageId}');
      // Don't save again, just handle the tap action
      _loadStoredNotifications(); // Refresh the list
    });

    // Handle initial message if app was terminated (don't save again)
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print('Initial message: ${message.messageId}');
        // Don't save again, just refresh
        _loadStoredNotifications();
      }
    });
  }

  void _handleMessage(RemoteMessage message, String source) {
    print('Handling message from $source: ${message.messageId}');
    
    final notification = NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'No Title',
      body: message.notification?.body ?? 'No Body',
      timestamp: DateTime.now(),
      data: message.data,
    );

    // Save and refresh only once
    NotificationService.saveNotification(notification).then((_) {
      _loadStoredNotifications();
    });
  }

  Future<void> _loadStoredNotifications() async {
    final storedNotifications = await NotificationService.getStoredNotifications();
    if (mounted) {
      setState(() {
        notifications = storedNotifications;
      });
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (!notification.isRead) {
      await NotificationService.markAsRead(notification.id);
      await _loadStoredNotifications();
    }
  }

  Future<void> _markAllAsRead() async {
    await NotificationService.markAllAsRead();
    await _loadStoredNotifications();
    _showSnackBar('All notifications marked as read', Colors.green);
  }

  Future<void> _clearAllNotifications() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to clear all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await NotificationService.clearAllNotifications();
              await _loadStoredNotifications();
              _showSnackBar('All notifications cleared', Colors.orange);
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (notifications.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: _markAllAsRead,
              tooltip: 'Mark all as read',
            ),
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearAllNotifications,
              tooltip: 'Clear all',
            ),
          ],
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? _buildEmptyState()
              : _buildNotificationsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.notifications_none_outlined,
              size: 60,
              color: Colors.green[600],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Notifications Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll see your notifications here when they arrive',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _loadStoredNotifications,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    final unreadCount = notifications.where((n) => !n.isRead).length;
    
    return Column(
      children: [
        if (unreadCount > 0)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.fiber_new, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  '$unreadCount new notification${unreadCount > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadStoredNotifications,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationCard(notification);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notification.isRead ? 1 : 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _markAsRead(notification),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: notification.isRead ? Colors.white : Colors.green[50],
            border: Border.all(
              color: notification.isRead ? Colors.grey[200]! : Colors.green[200]!,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: notification.isRead ? Colors.grey[200] : Colors.green[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.notifications,
                      color: notification.isRead ? Colors.grey[600] : Colors.green[700],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                                  color: notification.isRead ? Colors.grey[800] : Colors.black,
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.green[600],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getTimeAgo(notification.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (notification.body.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  notification.body,
                  style: TextStyle(
                    fontSize: 14,
                    color: notification.isRead ? Colors.grey[700] : Colors.grey[800],
                    height: 1.4,
                  ),
                ),
              ],
              if (notification.data != null && notification.data!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Additional data: ${notification.data.toString()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}