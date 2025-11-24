import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/subcategory_model.dart';
import '../providers/category_provider.dart';
import '../providers/ad_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/purchase_provider.dart';
import 'pdf_viewer_screen.dart';

class SubcategoryDetailScreen extends StatefulWidget {
  final SubcategoryModel subcategory;

  const SubcategoryDetailScreen({super.key, required this.subcategory});

  @override
  State<SubcategoryDetailScreen> createState() => _SubcategoryDetailScreenState();
}

class _SubcategoryDetailScreenState extends State<SubcategoryDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adProvider = Provider.of<AdProvider>(context, listen: false);
      // Force reload to ensure fresh ad
      adProvider.reloadBannerAd();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final adProvider = Provider.of<AdProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subcategory.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: categoryProvider.getSubcategoriesByParent('subcategory', widget.subcategory.id),
              builder: (context, subcatSnapshot) {
                return StreamBuilder(
                  stream: categoryProvider.getStudyMaterials(widget.subcategory.id),
                  builder: (context, materialSnapshot) {
                    if (subcatSnapshot.connectionState == ConnectionState.waiting ||
                        materialSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final nestedSubcategories = subcatSnapshot.data ?? [];
                    final materials = materialSnapshot.data ?? [];

                    if (nestedSubcategories.isEmpty && materials.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No content available',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Show nested subcategories first
                        if (nestedSubcategories.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Subcategories',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...nestedSubcategories.map((subcategory) {
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                                  child: Icon(
                                    Icons.folder,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                title: Text(
                                  subcategory.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: subcategory.description != null
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(subcategory.description!),
                                      )
                                    : null,
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SubcategoryDetailScreen(subcategory: subcategory),
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                          if (materials.isNotEmpty) const SizedBox(height: 16),
                        ],
                        // Show study materials
                        if (materials.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Study Materials',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...materials.map((material) {
                            // Determine icon and color based on content type
                            IconData materialIcon;
                            Color iconColor;
                            Color iconBgColor;
                            
                            if (material.hasPdf && material.hasImages) {
                              materialIcon = Icons.collections;
                              iconColor = Colors.purple;
                              iconBgColor = Colors.purple.withOpacity(0.1);
                            } else if (material.hasPdf) {
                              materialIcon = Icons.picture_as_pdf;
                              iconColor = Colors.red;
                              iconBgColor = Colors.red.withOpacity(0.1);
                            } else {
                              materialIcon = Icons.image;
                              iconColor = Colors.blue;
                              iconBgColor = Colors.blue.withOpacity(0.1);
                            }
                            
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: material.isAdFree 
                                    ? const BorderSide(color: Colors.green, width: 2)
                                    : BorderSide.none,
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: iconBgColor,
                                  child: Icon(
                                    materialIcon,
                                    color: iconColor,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        material.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    if (material.isAdFree)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.block, size: 12, color: Colors.white),
                                            SizedBox(width: 4),
                                            Text(
                                              'AD-FREE',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (material.imageUrls.isNotEmpty)
                                      Container(
                                        margin: const EdgeInsets.only(left: 4),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.image, size: 12, color: Colors.white),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${material.imageUrls.length}',
                                              style: const TextStyle(
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
                                subtitle: material.description != null
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(material.description!),
                                      )
                                    : null,
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () async {
                                  // If material has only images (no PDF), open image viewer directly
                                  if (!material.hasPdf && material.hasImages) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PdfViewerScreen(material: material),
                                      ),
                                    );
                                    return;
                                  }
                                  
                                  // If material is ad-free, skip REWARDED ads only (banner ads still show)
                                  if (material.isAdFree) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PdfViewerScreen(material: material),
                                      ),
                                    );
                                    return;
                                  }

                                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                  final purchaseProvider = Provider.of<PurchaseProvider>(context, listen: false);
                                  final isAdFree = authProvider.userModel?.adFree ?? false || purchaseProvider.isPurchased;
                                  final canShow = await adProvider.canShowRewardedAd(material.id, isAdFree: isAdFree);
                                  
                                  if (!context.mounted) return;

                                  // If canShow is true, user must watch ad (5+ minutes passed or first time)
                                  if (canShow && adProvider.isRewardedAdLoaded) {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (dialogContext) => AlertDialog(
                                        title: const Text('Watch Ad'),
                                        content: const Text(
                                          'Please watch the full ad to access this study material. The PDF will open automatically after the ad completes.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(dialogContext),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(dialogContext);
                                              _showPremiumUpgradeDialog(context, authProvider);
                                            },
                                            child: const Text(
                                              'Upgrade to Premium',
                                              style: TextStyle(color: Colors.amber),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              Navigator.pop(dialogContext);
                                              final watched = await adProvider.showRewardedAd(
                                                material.id,
                                                () {
                                                  if (context.mounted) {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) => PdfViewerScreen(material: material),
                                                      ),
                                                    );
                                                  }
                                                },
                                              );
                                              
                                              // If user didn't watch the ad, show a message
                                              if (!watched && context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Please watch the full ad to access the PDF'),
                                                    backgroundColor: Colors.orange,
                                                  ),
                                                );
                                              }
                                            },
                                            child: const Text('Watch Ad'),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    // canShow is false - either premium user or within 5 minutes
                                    // Allow direct access to PDF
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PdfViewerScreen(material: material),
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ],
                      ],
                    );
                  },
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

  void _showPremiumUpgradeDialog(BuildContext context, AuthProvider authProvider) {
    final purchaseProvider = Provider.of<PurchaseProvider>(context, listen: false);
    
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
                'Remove ads forever!',
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
}
