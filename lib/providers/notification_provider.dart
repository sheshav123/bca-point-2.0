import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;

  Stream<List<NotificationModel>> getNotificationsStream(bool isPremium) {
    return _firestore
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          final allNotifications = snapshot.docs
              .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
              .toList();
          
          // Filter based on user type
          return allNotifications.where((notification) {
            if (notification.audience == 'all') return true;
            if (notification.audience == 'premium' && isPremium) return true;
            if (notification.audience == 'free' && !isPremium) return true;
            return false;
          }).toList();
        });
  }

  Future<void> loadNotifications(bool isPremium) async {
    try {
      _isLoading = true;
      notifyListeners();

      debugPrint('🔔 Fetching notifications from Firestore...');
      final snapshot = await _firestore
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      debugPrint('🔔 Found ${snapshot.docs.length} notifications in Firestore');
      
      final allNotifications = snapshot.docs
          .map((doc) {
            debugPrint('🔔 Notification: ${doc.data()}');
            return NotificationModel.fromMap(doc.data(), doc.id);
          })
          .toList();
      
      // Filter based on user type
      _notifications = allNotifications.where((notification) {
        if (notification.audience == 'all') return true;
        if (notification.audience == 'premium' && isPremium) return true;
        if (notification.audience == 'free' && !isPremium) return true;
        return false;
      }).toList();

      _unreadCount = _notifications.where((n) => !n.read).length;
      
      debugPrint('🔔 Filtered to ${_notifications.length} notifications for user (isPremium: $isPremium)');
      debugPrint('🔔 Unread count: $_unreadCount');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ Error loading notifications: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});
      
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          type: _notifications[index].type,
          title: _notifications[index].title,
          message: _notifications[index].message,
          audience: _notifications[index].audience,
          createdAt: _notifications[index].createdAt,
          read: true,
        );
        _unreadCount = _notifications.where((n) => !n.read).length;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final batch = _firestore.batch();
      for (var notification in _notifications.where((n) => !n.read)) {
        batch.update(
          _firestore.collection('notifications').doc(notification.id),
          {'read': true},
        );
      }
      await batch.commit();
      
      _notifications = _notifications.map((n) => NotificationModel(
        id: n.id,
        type: n.type,
        title: n.title,
        message: n.message,
        audience: n.audience,
        createdAt: n.createdAt,
        read: true,
      )).toList();
      
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }
}
