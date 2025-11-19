import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/category_model.dart';
import '../providers/category_provider.dart';
import '../providers/ad_provider.dart';
import 'subcategory_detail_screen.dart';

class CategoryDetailScreen extends StatefulWidget {
  final CategoryModel category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
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
        title: Text(widget.category.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: categoryProvider.getSubcategoriesByParent('category', widget.category.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
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
                          'No subcategories available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final subcategories = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: subcategories.length,
                  itemBuilder: (context, index) {
                    final subcategory = subcategories[index];
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
                            Icons.topic,
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
