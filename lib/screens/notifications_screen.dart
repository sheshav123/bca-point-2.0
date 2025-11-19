import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/purchase_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final purchaseProvider = Provider.of<PurchaseProvider>(context, listen: false);
      final isPremium = authProvider.userModel?.adFree == true || purchaseProvider.isPurchased;
      
      Provider.of<NotificationProvider>(context, listen: false)
          .loadNotifications(isPremium);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final purchaseProvider = Provider.of<PurchaseProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final isPremium = authProvider.userModel?.adFree == true || purchaseProvider.isPurchased;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notificationProvider.unreadCount > 0)
            IconButton(
              onPressed: () => notificationProvider.markAllAsRead(),
              icon: const Icon(Icons.done_all),
              tooltip: 'Mark all as read',
            ),
        ],
      ),
      body: notificationProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notificationProvider.notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => notificationProvider.loadNotifications(isPremium),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notificationProvider.notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notificationProvider.notifications[index];
                      return Card(
                        elevation: notification.read ? 0 : 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        color: notification.read ? Colors.grey[50] : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: notification.read ? Colors.grey[200]! : Colors.blue[100]!,
                            width: notification.read ? 1 : 2,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: notification.read
                                ? Colors.grey[200]
                                : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            child: Text(
                              notification.icon,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: TextStyle(
                                    fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (!notification.read)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                notification.message,
                                style: TextStyle(
                                  color: notification.read ? Colors.grey : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                timeago.format(notification.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            if (!notification.read) {
                              notificationProvider.markAsRead(notification.id);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
