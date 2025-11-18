import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/purchase_provider.dart';
import '../screens/login_screen.dart';
import '../screens/cache_management_screen.dart';
import '../screens/debug_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: user?.photoUrl != null
                  ? NetworkImage(user!.photoUrl!)
                  : null,
              child: user?.photoUrl == null
                  ? Text(
                      user?.name.substring(0, 1).toUpperCase() ?? 'U',
                      style: TextStyle(
                        fontSize: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : null,
            ),
            accountName: Text(
              user?.name ?? 'User',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(user?.email ?? ''),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            subtitle: user != null
                ? Text('${user.collegeName} • Sem ${user.semester}')
                : null,
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Profile'),
                  content: user != null
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProfileRow('Name', user.name),
                            _buildProfileRow('Email', user.email),
                            _buildProfileRow('College', user.collegeName),
                            _buildProfileRow('Semester', user.semester),
                          ],
                        )
                      : const Text('No profile data available'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          Consumer<PurchaseProvider>(
            builder: (context, purchaseProvider, _) {
              if (user?.adFree == true || purchaseProvider.isPurchased) {
                return ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: const Text('Ad-Free Active'),
                  subtitle: const Text('Rewarded ads removed'),
                  trailing: const Icon(Icons.verified, color: Colors.green),
                );
              }
              return ListTile(
                leading: const Icon(Icons.remove_circle_outline, color: Colors.orange),
                title: const Text('Remove Rewarded Ads'),
                subtitle: const Text('₹100 - Lifetime'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _showPurchaseDialog(context, authProvider, purchaseProvider);
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bug_report, color: Colors.orange),
            title: const Text('Debug Database'),
            subtitle: const Text('View Firestore data'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DebugScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Cache Management'),
            subtitle: const Text('Manage offline PDFs'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CacheManagementScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: 'BCA Point 2.0',
                applicationVersion: '2.0.0',
                applicationIcon: const Icon(Icons.school_rounded, size: 48),
                children: [
                  const Text('Your comprehensive study material companion.'),
                ],
              );
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              _showDeleteAccountDialog(context, authProvider);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await authProvider.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  
  void _showPurchaseDialog(BuildContext context, AuthProvider authProvider, PurchaseProvider purchaseProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Rewarded Ads'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Get ad-free experience for lifetime!'),
            const SizedBox(height: 16),
            const Text('✓ No more rewarded ads before PDFs', style: TextStyle(color: Colors.green)),
            const Text('✓ Instant access to all materials', style: TextStyle(color: Colors.green)),
            const Text('✓ One-time payment of ₹100', style: TextStyle(color: Colors.green)),
            const SizedBox(height: 8),
            const Text('Note: Banner ads will still be shown', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: purchaseProvider.isLoading
                ? null
                : () async {
                    final success = await purchaseProvider.purchaseAdFree(authProvider.user!.uid);
                    if (context.mounted) {
                      Navigator.pop(context);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Purchase successful! Enjoy ad-free experience.')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Purchase failed. Please try again.')),
                        );
                      }
                    }
                  },
            child: purchaseProvider.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Purchase ₹100'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteAccountDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete your account?'),
            SizedBox(height: 16),
            Text(
              'This action cannot be undone. All your data will be permanently deleted.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Show confirmation dialog
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Final Confirmation'),
                  content: const Text('Type "DELETE" to confirm account deletion'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Confirm', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              
              if (confirmed == true && context.mounted) {
                try {
                  await authProvider.deleteAccount();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Account deleted successfully')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting account: $e')),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}
