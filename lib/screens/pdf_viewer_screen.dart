import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:provider/provider.dart';
import '../models/study_material_model.dart';
import '../models/pdf_annotation_model.dart';
import '../services/secure_pdf_cache.dart';
import '../services/annotation_service.dart';
import '../providers/auth_provider.dart';

class PdfViewerScreen extends StatefulWidget {
  final StudyMaterialModel material;

  const PdfViewerScreen({super.key, required this.material});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final SecurePdfCache _cache = SecurePdfCache();
  final AnnotationService _annotationService = AnnotationService();
  final PdfViewerController _pdfController = PdfViewerController();
  
  bool _isLoading = true;
  bool _isCached = false;
  double _downloadProgress = 0.0;
  Uint8List? _pdfData;
  String? _error;
  
  // Annotation mode
  AnnotationType? _currentAnnotationType;
  Color _currentColor = Colors.yellow;
  bool _isAnnotationMode = false;
  List<PdfAnnotation> _annotations = [];

  @override
  void initState() {
    super.initState();
    _loadPdf();
    _loadAnnotations();
  }

  void _loadAnnotations() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _annotationService
        .getAnnotations(widget.material.id, authProvider.user!.uid)
        .listen((annotations) {
      if (mounted) {
        setState(() {
          _annotations = annotations;
        });
      }
    });
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
        // Load from cache (instant)
        debugPrint('Loading PDF from cache...');
        final cachedData = await _cache.getCachedPdf(widget.material.pdfUrl);
        
        if (cachedData != null) {
          setState(() {
            _pdfData = cachedData;
            _isCached = true;
            _isLoading = false;
          });
          return;
        }
      }

      // Download and cache
      debugPrint('Downloading PDF...');
      await _cache.downloadAndCache(
        widget.material.pdfUrl,
        widget.material.id,
        onProgress: (progress) {
          setState(() {
            _downloadProgress = progress;
          });
        },
      );

      // Load the cached data
      final cachedData = await _cache.getCachedPdf(widget.material.pdfUrl);
      
      if (cachedData != null) {
        setState(() {
          _pdfData = cachedData;
          _isCached = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load PDF';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading PDF: $e');
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
            icon: Icon(_isAnnotationMode ? Icons.edit_off : Icons.edit),
            onPressed: () {
              setState(() {
                _isAnnotationMode = !_isAnnotationMode;
                if (!_isAnnotationMode) {
                  _currentAnnotationType = null;
                }
              });
            },
            tooltip: _isAnnotationMode ? 'Exit Annotation Mode' : 'Annotate',
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
          if (_isAnnotationMode) _buildAnnotationToolbar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildAnnotationToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: Colors.grey[200],
      child: Row(
        children: [
          const Text('Tools:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          _buildToolButton(
            icon: Icons.highlight,
            label: 'Highlight',
            type: AnnotationType.highlight,
            color: Colors.yellow,
          ),
          _buildToolButton(
            icon: Icons.format_underline,
            label: 'Underline',
            type: AnnotationType.underline,
            color: Colors.red,
          ),
          _buildToolButton(
            icon: Icons.draw,
            label: 'Draw',
            type: AnnotationType.drawing,
            color: Colors.blue,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: _showClearAnnotationsDialog,
            tooltip: 'Clear All',
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required AnnotationType type,
    required Color color,
  }) {
    final isSelected = _currentAnnotationType == type;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            _currentAnnotationType = type;
            _currentColor = color;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.3) : Colors.transparent,
            border: Border.all(
              color: isSelected ? color : Colors.grey,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showClearAnnotationsDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Annotations'),
        content: const Text('Remove all highlights, underlines, and drawings?'),
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
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await _annotationService.deleteAllAnnotations(
        widget.material.id,
        authProvider.user!.uid,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All annotations cleared')),
        );
      }
    }
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
      return Stack(
        children: [
          SfPdfViewer.memory(
            _pdfData!,
            controller: _pdfController,
            enableDoubleTapZooming: true,
            enableTextSelection: !_isAnnotationMode,
            canShowScrollHead: true,
            canShowScrollStatus: true,
          ),
          if (_isAnnotationMode && _currentAnnotationType != null)
            Positioned.fill(
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: CustomPaint(
                  painter: AnnotationPainter(
                    annotations: _annotations,
                    currentPoints: _currentDrawingPoints,
                    currentColor: _currentColor,
                    currentType: _currentAnnotationType,
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return const Center(child: Text('No PDF data available'));
  }

  List<Offset> _currentDrawingPoints = [];

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _currentDrawingPoints = [details.localPosition];
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentDrawingPoints.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) async {
    if (_currentDrawingPoints.isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final annotation = PdfAnnotation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      materialId: widget.material.id,
      userId: authProvider.user!.uid,
      type: _currentAnnotationType!,
      pageNumber: _pdfController.pageNumber,
      points: List.from(_currentDrawingPoints),
      color: _currentColor,
      strokeWidth: _currentAnnotationType == AnnotationType.highlight ? 10.0 : 2.0,
      createdAt: DateTime.now(),
    );

    await _annotationService.saveAnnotation(annotation);

    setState(() {
      _currentDrawingPoints = [];
    });
  }
}

class AnnotationPainter extends CustomPainter {
  final List<PdfAnnotation> annotations;
  final List<Offset> currentPoints;
  final Color currentColor;
  final AnnotationType? currentType;

  AnnotationPainter({
    required this.annotations,
    required this.currentPoints,
    required this.currentColor,
    this.currentType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw saved annotations
    for (var annotation in annotations) {
      final paint = Paint()
        ..color = annotation.color
        ..strokeWidth = annotation.strokeWidth
        ..style = annotation.type == AnnotationType.highlight
            ? PaintingStyle.stroke
            : PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      if (annotation.type == AnnotationType.highlight) {
        paint.color = annotation.color.withOpacity(0.3);
        paint.style = PaintingStyle.fill;
      }

      for (int i = 0; i < annotation.points.length - 1; i++) {
        canvas.drawLine(
          annotation.points[i],
          annotation.points[i + 1],
          paint,
        );
      }
    }

    // Draw current drawing
    if (currentPoints.isNotEmpty && currentType != null) {
      final paint = Paint()
        ..color = currentColor
        ..strokeWidth = currentType == AnnotationType.highlight ? 10.0 : 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      if (currentType == AnnotationType.highlight) {
        paint.color = currentColor.withOpacity(0.3);
      }

      for (int i = 0; i < currentPoints.length - 1; i++) {
        canvas.drawLine(
          currentPoints[i],
          currentPoints[i + 1],
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(AnnotationPainter oldDelegate) => true;
}
