import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/auth_provider.dart';
import '../providers/category_provider.dart';
import '../providers/ad_provider.dart';
import '../providers/purchase_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/app_drawer.dart';
import 'category_detail_screen.dart';
import 'debug_screen.dart';
import 'notifications_screen.dart';
import 'profile_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final purchaseProvider = Provider.of<PurchaseProvider>(context, listen: false);
      final isPremium = authProvider.userModel?.adFree == true || purchaseProvider.isPurchased;
      
      debugPrint('🔔 Loading notifications for isPremium: $isPremium');
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
      Provider.of<AdProvider>(context, listen: false).loadBannerAd();
      Provider.of<AdProvider>(context, listen: false).loadRewardedAd();
      Provider.of<NotificationProvider>(context, listen: false).loadNotifications(isPremium);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final adProvider = Provider.of<AdProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BCA Point 2.0'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, _) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                      );
                    },
                    tooltip: 'Notifications',
                  ),
                  if (notificationProvider.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          notificationProvider.unreadCount > 9
                              ? '9+'
                              : notificationProvider.unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // Debug button - uncomment for testing
          // IconButton(
          //   icon: const Icon(Icons.bug_report),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (_) => const DebugScreen()),
          //     );
          //   },
          //   tooltip: 'Debug Database',
          // ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => categoryProvider.loadCategories(),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          if (authProvider.userModel != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Consumer<PurchaseProvider>(
                          builder: (context, purchaseProvider, _) {
                            final isPremium = authProvider.userModel?.adFree == true || purchaseProvider.isPurchased;
                            return Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    authProvider.userModel!.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (isPremium) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Colors.amber, Colors.orange],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.workspace_premium, size: 14, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text(
                                          'PREMIUM',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${authProvider.userModel!.collegeName} • Semester ${authProvider.userModel!.semester}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
                      );
                    },
                    tooltip: 'Edit Profile',
                  ),
                ],
              ),
            ),
          Expanded(
            child: categoryProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : categoryProvider.categories.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_open,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No categories available',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: categoryProvider.categories.length,
                        itemBuilder: (context, index) {
                          final category = categoryProvider.categories[index];
                          final isPremium = category.isPremium;
                          final hasPremium = authProvider.userModel?.adFree == true ||
                              Provider.of<PurchaseProvider>(context, listen: false).isPurchased;
                          final isLocked = isPremium && !hasPremium;
                          
                          debugPrint('Category: ${category.title}, isPremium: $isPremium, hasPremium: $hasPremium, isLocked: $isLocked');
                          
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: CircleAvatar(
                                    backgroundColor: isLocked
                                        ? Colors.grey.withOpacity(0.2)
                                        : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    child: Icon(
                                      isLocked ? Icons.lock : Icons.folder,
                                      color: isLocked
                                          ? Colors.grey
                                          : Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          category.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: isLocked ? Colors.grey : null,
                                          ),
                                        ),
                                      ),
                                      if (isPremium)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Colors.amber, Colors.orange],
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.workspace_premium, size: 12, color: Colors.white),
                                              SizedBox(width: 4),
                                              Text(
                                                'PREMIUM',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  subtitle: category.description != null
                                      ? Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            category.description!,
                                            style: TextStyle(
                                              color: isLocked ? Colors.grey : null,
                                            ),
                                          ),
                                        )
                                      : null,
                                  trailing: Icon(
                                    isLocked ? Icons.lock : Icons.arrow_forward_ios,
                                    size: 16,
                                    color: isLocked ? Colors.grey : null,
                                  ),
                                  onTap: () {
                                    if (isLocked) {
                                      _showPremiumUpgradeDialog(context);
                                      return;
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CategoryDetailScreen(category: category),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          if (adProvider.isBannerAdLoaded && adProvider.bannerAd != null)
            Container(
              height: 50,
              alignment: Alignment.center,
              child: AdWidget(ad: adProvider.bannerAd!),
            ),
        ],
      ),
    );
  }

  void _showPremiumUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.lock, color: Colors.amber),
            const SizedBox(width: 8),
            const Text('Premium Content'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            const Text(
              'This category is exclusive to Premium members',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildBenefit(Icons.block, 'No rewarded ads'),
                  _buildBenefit(Icons.lock_open, 'All premium categories'),
                  _buildBenefit(Icons.flash_on, 'Instant access'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to purchase
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final purchaseProvider = Provider.of<PurchaseProvider>(context, listen: false);
              _showPurchaseFromDialog(context, authProvider, purchaseProvider);
            },
            icon: const Icon(Icons.workspace_premium),
            label: const Text('Upgrade ₹100'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.green),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  void _showPurchaseFromDialog(BuildContext context, AuthProvider authProvider, PurchaseProvider purchaseProvider) {
    // Reuse the purchase dialog from AppDrawer
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.workspace_premium, color: Colors.amber),
            const SizedBox(width: 8),
            const Text('Upgrade to Premium'),
          ],
        ),
        content: const Text('Upgrade to premium for ₹100 (one-time payment)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await purchaseProvider.purchaseAdFree(authProvider.user!.uid);
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎉 Welcome to Premium!'),
                      backgroundColor: Colors.amber,
                    ),
                  );
                }
              }
            },
            child: const Text('Upgrade ₹100'),
          ),
        ],
      ),
    );
  }
}
