import 'package:flutter/material.dart';

class EdukasiImageViewer extends StatefulWidget {
  final String imagePath;
  final String title;

  const EdukasiImageViewer({
    super.key,
    required this.imagePath,
    required this.title,
  });

  @override
  State<EdukasiImageViewer> createState() => _EdukasiImageViewerState();
}

class _EdukasiImageViewerState extends State<EdukasiImageViewer> {
  final TransformationController _transformationController =
      TransformationController();
  TapDownDetails? _doubleTapDetails;

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails?.localPosition;
      if (position != null) {
        final translation = Matrix4.translationValues(
          -position.dx * 1.5,
          -position.dy * 1.5,
          0.0,
        );
        final scale = Matrix4.diagonal3Values(2.5, 2.5, 1.0);
        _transformationController.value = translation * scale;
      } else {
        _transformationController.value = Matrix4.diagonal3Values(
          2.5,
          2.5,
          1.0,
        );
      }
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19), // Ultra-premium dark background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out_map_rounded, color: Colors.white),
            tooltip: 'Reset Zoom',
            onPressed: () {
              setState(() {
                _transformationController.value = Matrix4.identity();
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: GestureDetector(
                  onDoubleTapDown: (details) => _doubleTapDetails = details,
                  onDoubleTap: _handleDoubleTap,
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 1.0,
                    maxScale: 4.0,
                    boundaryMargin: const EdgeInsets.all(20),
                    child: Hero(
                      tag: widget.imagePath,
                      child: Image.asset(
                        widget.imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image_rounded,
                                  color: Colors.grey.shade600,
                                  size: 64,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Gagal memuat gambar infografis',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Bottom bar with instructions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF161B26),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pinch_rounded,
                    color: Colors.teal.shade300,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Cubit untuk memperbesar • Ketuk dua kali untuk reset',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

