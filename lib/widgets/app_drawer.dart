import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../providers/purchase_provider.dart';
import '../screens/login_screen.dart';
import '../screens/cache_management_screen.dart';
import '../screens/debug_screen.dart';
import '../screens/profile_edit_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
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
            trailing: IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
                );
              },
              tooltip: 'Edit Profile',
            ),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 8),
                      Text('Profile'),
                    ],
                  ),
                  content: user != null
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProfileRow('Name', user.name),
                            _buildProfileRow('Email', user.email),
                            _buildProfileRow('College', user.collegeName),
                            _buildProfileRow('Semester', user.semester),
                            if (user.university != null)
                              _buildProfileRow('University', user.university!),
                            if (user.phone != null)
                              _buildProfileRow('Phone', user.phone!),
                          ],
                        )
                      : const Text('No profile data available'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
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
                  leading: const Icon(Icons.workspace_premium, color: Colors.amber),
                  title: const Row(
                    children: [
                      Text('Premium Active'),
                      SizedBox(width: 8),
                      Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                    ],
                  ),
                  subtitle: const Text('No ads • Premium categories'),
                  trailing: const Icon(Icons.verified, color: Colors.amber),
                );
              }
              return ListTile(
                leading: const Icon(Icons.workspace_premium, color: Colors.amber),
                title: const Text('Upgrade to Premium'),
                subtitle: const Text('₹100 - Lifetime'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _showPurchaseDialog(context, authProvider, purchaseProvider);
                },
              );
            },
          ),
          // Debug options - uncomment for testing
          // ListTile(
          //   leading: const Icon(Icons.refresh, color: Colors.green),
          //   title: const Text('Refresh Profile'),
          //   subtitle: const Text('Reload user data from server'),
          //   onTap: () async {
          //     Navigator.pop(context);
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(content: Text('Refreshing profile...')),
          //     );
          //     await authProvider.refreshUserData();
          //     if (context.mounted) {
          //       ScaffoldMessenger.of(context).showSnackBar(
          //         const SnackBar(
          //           content: Text('✅ Profile refreshed!'),
          //           backgroundColor: Colors.green,
          //         ),
          //       );
          //     }
          //   },
          // ),
          // ListTile(
          //   leading: const Icon(Icons.bug_report, color: Colors.orange),
          //   title: const Text('Debug Database'),
          //   subtitle: const Text('View Firestore data'),
          //   onTap: () {
          //     Navigator.pop(context);
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (_) => const DebugScreen()),
          //     );
          //   },
          // ),
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
            leading: const Icon(Icons.support_agent, color: Colors.blue),
            title: const Text('Support & Feedback'),
            subtitle: const Text('Request materials • Send feedback'),
            onTap: () {
              Navigator.pop(context);
              _showSupportDialog(context);
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
          ListTile(
            leading: const Icon(Icons.star, color: Colors.orange),
            title: const Text('Rate & Review'),
            subtitle: const Text('Share your experience on Play Store'),
            onTap: () async {
              Navigator.pop(context);
              final Uri playStoreUri = Uri.parse(
                'https://play.google.com/store/apps/details?id=com.tech.practice&pcampaignid=web_share',
              );
              
              try {
                if (await canLaunchUrl(playStoreUri)) {
                  await launchUrl(
                    playStoreUri,
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not open Play Store'),
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error opening Play Store'),
                    ),
                  );
                }
              }
            },
          ),
          const Divider(),
          // Cross-platform links
          if (kIsWeb)
            // Show "Download Android App" on web
            ListTile(
              leading: const Icon(Icons.android, color: Colors.green),
              title: const Text('Download Android App'),
              subtitle: const Text('Get the mobile app from Play Store'),
              trailing: const Icon(Icons.download, size: 20),
              onTap: () async {
                Navigator.pop(context);
                final Uri playStoreUri = Uri.parse(
                  'https://play.google.com/store/apps/details?id=com.tech.practice&pcampaignid=web_share',
                );
                
                try {
                  if (await canLaunchUrl(playStoreUri)) {
                    await launchUrl(
                      playStoreUri,
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not open Play Store'),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error opening Play Store'),
                      ),
                    );
                  }
                }
              },
            )
          else
            // Show "Visit Web Version" on mobile
            ListTile(
              leading: const Icon(Icons.language, color: Colors.blue),
              title: const Text('Visit Web Version'),
              subtitle: const Text('Access from any browser'),
              trailing: const Icon(Icons.open_in_new, size: 20),
              onTap: () async {
                Navigator.pop(context);
                final Uri webUri = Uri.parse(
                  'https://sheshav123.github.io/bca-point-2.0/',
                );
                
                try {
                  if (await canLaunchUrl(webUri)) {
                    await launchUrl(
                      webUri,
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not open web browser'),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error opening web version'),
                      ),
                    );
                  }
                }
              },
            ),
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
        title: const Row(
          children: [
            Icon(Icons.workspace_premium, color: Colors.amber),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Upgrade to Premium',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Unlock all premium features!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildFeature(Icons.block, 'No rewarded ads'),
              _buildFeature(Icons.lock_open, 'Access premium categories'),
              _buildFeature(Icons.flash_on, 'Instant PDF access'),
              _buildFeature(Icons.auto_awesome, 'Premium badge'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.workspace_premium, color: Colors.amber),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'One-time payment of ₹100',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                          const SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.workspace_premium, color: Colors.white),
                                SizedBox(width: 8),
                                Text('🎉 Welcome to Premium!'),
                              ],
                            ),
                            backgroundColor: Colors.amber,
                          ),
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
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.workspace_premium),
                      SizedBox(width: 8),
                      Text('Upgrade ₹100'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 12),
          Text(text),
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
              // Don't pop yet - keep context alive
              final firstDialogContext = context;
              
              // Show confirmation dialog with text input
              final textController = TextEditingController();
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Final Confirmation'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'This action cannot be undone!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Type "DELETE" to confirm:'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: textController,
                        decoration: const InputDecoration(
                          hintText: 'DELETE',
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        autofocus: true,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        if (textController.text.trim().toUpperCase() == 'DELETE') {
                          Navigator.pop(context, true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please type "DELETE" to confirm'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      },
                      child: const Text('Confirm', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              
              debugPrint('🔍 Dialog result: $confirmed');
              
              // Close the first dialog now
              Navigator.pop(firstDialogContext);
              
              if (confirmed != true) {
                debugPrint('❌ User cancelled deletion');
                return;
              }
              
              if (!context.mounted) {
                debugPrint('❌ Context not mounted');
                return;
              }
              
              debugPrint('✅ User confirmed deletion, proceeding...');
              
              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Deleting account...'),
                        ],
                      ),
                    ),
                  ),
                ),
              );
              
              try {
                await authProvider.deleteAccount();
                
                if (context.mounted) {
                  Navigator.pop(context); // Close loading dialog
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Account deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                debugPrint('❌ Error in dialog handler: $e');
                if (context.mounted) {
                  Navigator.pop(context); // Close loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Error deleting account: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 5),
                    ),
                  );
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

  void _showSupportDialog(BuildContext context) {
    const supportEmail = 'sheshavanand@gmail.com';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.support_agent, color: Colors.blue),
            SizedBox(width: 8),
            Text('Support & Feedback'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'We\'d love to hear from you!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text('Contact us to:'),
              const SizedBox(height: 12),
              _buildSupportOption(Icons.feedback, 'Send feedback or suggestions'),
              _buildSupportOption(Icons.book, 'Request for more study materials'),
              _buildSupportOption(Icons.upload_file, 'Share your study materials'),
              _buildSupportOption(Icons.bug_report, 'Report issues'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.email, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Email us at:',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            supportEmail,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      onPressed: () {
                        Clipboard.setData(const ClipboardData(text: supportEmail));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('📋 Email copied to clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      tooltip: 'Copy email',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final Uri emailUri = Uri(
                scheme: 'mailto',
                path: supportEmail,
                query: 'subject=BCA Point 2.0 - Feedback/Support',
              );
              
              if (await canLaunchUrl(emailUri)) {
                await launchUrl(emailUri);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not open email app. Email copied to clipboard.'),
                    ),
                  );
                  Clipboard.setData(const ClipboardData(text: supportEmail));
                }
              }
            },
            icon: const Icon(Icons.email),
            label: const Text('Send Email'),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOption(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
