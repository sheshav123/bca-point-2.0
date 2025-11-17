import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/subcategory_model.dart';
import '../providers/category_provider.dart';
import '../providers/ad_provider.dart';
import '../providers/auth_provider.dart';
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
      Provider.of<AdProvider>(context, listen: false).loadBannerAd();
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
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.red.withOpacity(0.1),
                                  child: const Icon(
                                    Icons.picture_as_pdf,
                                    color: Colors.red,
                                  ),
                                ),
                                title: Text(
                                  material.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: material.description != null
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(material.description!),
                                      )
                                    : null,
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () async {
                                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                  final isAdFree = authProvider.userModel?.adFree ?? false;
                                  final canShow = await adProvider.canShowRewardedAd(material.id, isAdFree: isAdFree);
                                  
                                  if (!context.mounted) return;

                                  if (canShow && adProvider.isRewardedAdLoaded) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Watch Ad'),
                                        content: const Text(
                                          'Please watch a short ad to access this study material.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              await adProvider.showRewardedAd(
                                                material.id,
                                                () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => PdfViewerScreen(material: material),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: const Text('Watch Ad'),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
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
}
