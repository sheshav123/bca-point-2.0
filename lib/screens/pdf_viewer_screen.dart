import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:provider/provider.dart';
import '../models/study_material_model.dart';
import '../services/secure_pdf_cache.dart';
import '../widgets/banner_ad_widget.dart';
import '../providers/auth_provider.dart';

class PdfViewerScreen extends StatefulWidget {
  final StudyMaterialModel material;

  const PdfViewerScreen({super.key, required this.material});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final SecurePdfCache _cache = SecurePdfCache();
  final PdfViewerController _pdfController = PdfViewerController();
  
  bool _isLoading = true;
  bool _isCached = false;
  double _downloadProgress = 0.0;
  Uint8List? _pdfData;
  String? _error;
  
  // Annotation mode (disabled for now)
  // AnnotationType? _currentAnnotationType;
  // Color _currentColor = Colors.yellow;
  // bool _isAnnotationMode = false;
  // List<PdfAnnotation> _annotations = [];
  // bool _annotationUnlocked = false;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Check if PDF is cached
      final isCached = await _cache.isCached(widget.material.pdfUrl);
      
      if (isCached) {
        // Try to load from cache
        debugPrint('📂 Loading PDF from cache...');
        final cachedData = await _cache.getCachedPdf(widget.material.pdfUrl);
        
        if (cachedData != null && cachedData.isNotEmpty) {
          debugPrint('✅ Loaded from cache: ${cachedData.length} bytes');
          setState(() {
            _pdfData = cachedData;
            _isCached = true;
            _isLoading = false;
          });
          return;
        } else {
          // Cache is corrupted, clear it and re-download
          debugPrint('⚠️ Cache corrupted or empty, clearing and re-downloading...');
          await _cache.clearPdf(widget.material.pdfUrl);
        }
      }

      // Download and cache
      debugPrint('⬇️ Downloading PDF...');
      await _cache.downloadAndCache(
        widget.material.pdfUrl,
        widget.material.id,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _downloadProgress = progress;
            });
          }
        },
      );

      // Load the newly cached data
      final cachedData = await _cache.getCachedPdf(widget.material.pdfUrl);
      
      if (cachedData != null && cachedData.isNotEmpty) {
        debugPrint('✅ PDF loaded successfully: ${cachedData.length} bytes');
        setState(() {
          _pdfData = cachedData;
          _isCached = true;
          _isLoading = false;
        });
      } else {
        debugPrint('❌ Failed to load PDF after download');
        setState(() {
          _error = 'Failed to load PDF. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading PDF: $e');
      setState(() {
        _error = 'Error loading PDF: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.material.title),
        actions: [
          if (_isCached)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.offline_bolt, color: Colors.green),
            ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📝 Annotation feature coming soon!'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            tooltip: 'Annotate (Coming Soon)',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.material.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (widget.material.description != null) ...[
                        const SizedBox(height: 8),
                        Text(widget.material.description!),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            _isCached ? Icons.check_circle : Icons.cloud_download,
                            size: 16,
                            color: _isCached ? Colors.green : Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isCached ? 'Cached for offline access' : 'Will be cached after viewing',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Note: PDFs are encrypted and cannot be shared to protect copyright.',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
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
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          const BannerAdWidget(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              _downloadProgress > 0
                  ? 'Downloading... ${(_downloadProgress * 100).toStringAsFixed(0)}%'
                  : 'Loading PDF...',
              style: const TextStyle(fontSize: 16),
            ),
            if (_downloadProgress > 0) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: LinearProgressIndicator(value: _downloadProgress),
              ),
            ],
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPdf,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_pdfData != null) {
      return SfPdfViewer.memory(
        _pdfData!,
        controller: _pdfController,
        enableDoubleTapZooming: true,
        enableTextSelection: true,
        canShowScrollHead: true,
        canShowScrollStatus: true,
      );
    }

    return const Center(child: Text('No PDF data available'));
  }

}

