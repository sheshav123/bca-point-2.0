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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      color: Colors.grey[200],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('Tools:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            _buildToolButton(
              icon: Icons.highlight,
              type: AnnotationType.highlight,
              color: Colors.yellow.shade700,
            ),
            const SizedBox(width: 4),
            _buildToolButton(
              icon: Icons.format_underline,
              type: AnnotationType.underline,
              color: Colors.red,
            ),
            const SizedBox(width: 4),
            _buildToolButton(
              icon: Icons.draw,
              type: AnnotationType.drawing,
              color: Colors.blue,
            ),
            const SizedBox(width: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: _showClearAnnotationsDialog,
                tooltip: 'Clear All',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required AnnotationType type,
    required Color color,
  }) {
    final isSelected = _currentAnnotationType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _currentAnnotationType = type;
          _currentColor = color;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${type.name.toUpperCase()} mode activated'),
            duration: const Duration(seconds: 1),
            backgroundColor: color,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.3) : Colors.white,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade400,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 24, color: color),
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
  bool _isSaving = false;

  void _onPanStart(DragStartDetails details) {
    if (_currentAnnotationType == null) return;
    _currentDrawingPoints = [details.localPosition];
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_currentAnnotationType == null || _currentDrawingPoints.isEmpty) return;
    
    setState(() {
      _currentDrawingPoints.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) async {
    if (_currentDrawingPoints.isEmpty || _currentAnnotationType == null || _isSaving) return;

    _isSaving = true;
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final annotation = PdfAnnotation(
        id: '${authProvider.user!.uid}_${DateTime.now().millisecondsSinceEpoch}',
        materialId: widget.material.id,
        userId: authProvider.user!.uid,
        type: _currentAnnotationType!,
        pageNumber: _pdfController.pageNumber,
        points: List.from(_currentDrawingPoints),
        color: _currentColor,
        strokeWidth: _currentAnnotationType == AnnotationType.highlight ? 15.0 : 3.0,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await _annotationService.saveAnnotation(annotation);
      
      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_currentAnnotationType!.name.toUpperCase()} saved!'),
            duration: const Duration(milliseconds: 500),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving annotation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save annotation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _currentDrawingPoints = [];
        _isSaving = false;
      });
    }
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
      if (annotation.points.length < 2) continue;
      
      final paint = Paint()
        ..strokeWidth = annotation.strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      if (annotation.type == AnnotationType.highlight) {
        paint.color = annotation.color.withOpacity(0.4);
        paint.strokeWidth = 15.0;
      } else if (annotation.type == AnnotationType.underline) {
        paint.color = annotation.color;
        paint.strokeWidth = 3.0;
      } else {
        paint.color = annotation.color;
        paint.strokeWidth = 3.0;
      }

      // Draw path for better performance
      final path = Path();
      path.moveTo(annotation.points[0].dx, annotation.points[0].dy);
      
      for (int i = 1; i < annotation.points.length; i++) {
        path.lineTo(annotation.points[i].dx, annotation.points[i].dy);
      }
      
      canvas.drawPath(path, paint);
    }

    // Draw current drawing
    if (currentPoints.length >= 2 && currentType != null) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      if (currentType == AnnotationType.highlight) {
        paint.color = currentColor.withOpacity(0.4);
        paint.strokeWidth = 15.0;
      } else if (currentType == AnnotationType.underline) {
        paint.color = currentColor;
        paint.strokeWidth = 3.0;
      } else {
        paint.color = currentColor;
        paint.strokeWidth = 3.0;
      }

      // Draw path for better performance
      final path = Path();
      path.moveTo(currentPoints[0].dx, currentPoints[0].dy);
      
      for (int i = 1; i < currentPoints.length; i++) {
        path.lineTo(currentPoints[i].dx, currentPoints[i].dy);
      }
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(AnnotationPainter oldDelegate) {
    return oldDelegate.currentPoints.length != currentPoints.length ||
           oldDelegate.annotations.length != annotations.length;
  }
}
