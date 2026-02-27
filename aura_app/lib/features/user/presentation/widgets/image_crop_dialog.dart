import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ImageCropDialog extends StatefulWidget {
  final File imageFile;

  const ImageCropDialog({super.key, required this.imageFile});

  static Future<File?> show(BuildContext context, File imageFile) {
    return showGeneralDialog<File?>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (ctx, anim, _, child) =>
          FadeTransition(opacity: anim, child: child),
      pageBuilder: (ctx, _, __) => ImageCropDialog(imageFile: imageFile),
    );
  }

  @override
  State<ImageCropDialog> createState() => _ImageCropDialogState();
}

class _ImageCropDialogState extends State<ImageCropDialog> {
  ui.Image? _uiImage;
  bool _loading = true;
  bool _saving = false;

  double _scale = 1.0;
  double _baseScale = 1.0;
  Offset _offset = Offset.zero;

  int _rotateDeg = 0;
  bool _flipH = false;

  double _cropSize = 0;
  Size _viewSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final bytes = await widget.imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    if (mounted) {
      setState(() {
        _uiImage = frame.image;
        _loading = false;
      });
      _resetPanScale();
    }
  }

  void _resetPanScale() {
    if (_uiImage == null || _viewSize == Size.zero) return;
    final imgW = _rotateDeg == 90 || _rotateDeg == 270
        ? _uiImage!.height.toDouble()
        : _uiImage!.width.toDouble();
    final imgH = _rotateDeg == 90 || _rotateDeg == 270
        ? _uiImage!.width.toDouble()
        : _uiImage!.height.toDouble();
    final fitScale = max(_cropSize / imgW, _cropSize / imgH);
    _scale = fitScale;
    _offset = Offset.zero;
  }

  void _rotate(int delta) {
    setState(() {
      _rotateDeg = (_rotateDeg + delta + 360) % 360;
      _resetPanScale();
    });
  }

  void _flip() {
    setState(() => _flipH = !_flipH);
  }

  void _onScaleStart(ScaleStartDetails d) {
    _baseScale = _scale;
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    setState(() {
      _scale = (_baseScale * d.scale).clamp(0.3, 8.0);
      _offset = _offset + d.focalPointDelta;
      _clampOffset();
    });
  }

  void _clampOffset() {
    if (_uiImage == null || _viewSize == Size.zero) return;
    final bool isRotated90 = _rotateDeg == 90 || _rotateDeg == 270;
    final displayW =
        (isRotated90 ? _uiImage!.height : _uiImage!.width).toDouble() * _scale;
    final displayH =
        (isRotated90 ? _uiImage!.width : _uiImage!.height).toDouble() * _scale;
    final maxDx = max(0.0, (displayW - _cropSize) / 2);
    final maxDy = max(0.0, (displayH - _cropSize) / 2);
    _offset = Offset(
      _offset.dx.clamp(-maxDx, maxDx),
      _offset.dy.clamp(-maxDy, maxDy),
    );
  }

  Future<void> _crop() async {
    if (_uiImage == null || _viewSize == Size.zero) return;
    setState(() => _saving = true);

    final img = _uiImage!;
    final bool isRotated90 = _rotateDeg == 90 || _rotateDeg == 270;
    final displayW = (isRotated90 ? img.height : img.width).toDouble() * _scale;
    final displayH = (isRotated90 ? img.width : img.height).toDouble() * _scale;

    final imgLeft = (_viewSize.width - displayW) / 2 + _offset.dx;
    final imgTop = (_viewSize.height - displayH) / 2 + _offset.dy;
    final cropLeft = (_viewSize.width - _cropSize) / 2;
    final cropTop = (_viewSize.height - _cropSize) / 2;

    const outputSize = 512.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, outputSize, outputSize),
    );

    final paint = Paint()..filterQuality = FilterQuality.high;

    canvas.save();
    canvas.translate(outputSize / 2, outputSize / 2);

    if (_flipH) canvas.scale(-1, 1);
    if (_rotateDeg != 0) {
      canvas.rotate(_rotateDeg * pi / 180);
    }

    final srcFull = Rect.fromLTWH(
      0,
      0,
      img.width.toDouble(),
      img.height.toDouble(),
    );

    final relLeft = cropLeft - imgLeft;
    final relTop = cropTop - imgTop;
    final srcX = (relLeft / _scale).clamp(0.0, img.width.toDouble());
    final srcY = (relTop / _scale).clamp(0.0, img.height.toDouble());
    final srcSizeW = (_cropSize / _scale).clamp(0.0, img.width.toDouble());
    final srcSizeH = (_cropSize / _scale).clamp(0.0, img.height.toDouble());

    final double drawW;
    final double drawH;
    final Rect srcRect;

    if (isRotated90) {
      srcRect = Rect.fromLTWH(srcY, srcX, srcSizeH, srcSizeW);
      drawW = outputSize;
      drawH = outputSize;
    } else {
      srcRect = Rect.fromLTWH(srcX, srcY, srcSizeW, srcSizeH);
      drawW = outputSize;
      drawH = outputSize;
    }

    canvas.drawImageRect(
      img,
      srcRect.isEmpty ? srcFull : srcRect,
      Rect.fromLTWH(-drawW / 2, -drawH / 2, drawW, drawH),
      paint,
    );
    canvas.restore();

    final picture = recorder.endRecording();
    final outImage = await picture.toImage(
      outputSize.toInt(),
      outputSize.toInt(),
    );
    final byteData = await outImage.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null || !mounted) return;

    final outFile = File(
      '${Directory.systemTemp.path}/crop_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await outFile.writeAsBytes(byteData.buffer.asUint8List());
    if (mounted) Navigator.of(context).pop(outFile);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0A1A2F),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(null),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Crop Photo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _saving ? null : _crop,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Done',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white54,
                        strokeWidth: 2,
                      ),
                    )
                  : LayoutBuilder(
                      builder: (ctx, constraints) {
                        _viewSize = Size(
                          constraints.maxWidth,
                          constraints.maxHeight,
                        );
                        _cropSize =
                            min(constraints.maxWidth, constraints.maxHeight) *
                            0.78;
                        if (_scale == 1.0) _resetPanScale();

                        return GestureDetector(
                          onScaleStart: _onScaleStart,
                          onScaleUpdate: _onScaleUpdate,
                          child: CustomPaint(
                            size: _viewSize,
                            painter: _CropPainter(
                              image: _uiImage!,
                              scale: _scale,
                              offset: _offset,
                              cropSize: _cropSize,
                              viewSize: _viewSize,
                              rotateDeg: _rotateDeg,
                              flipH: _flipH,
                            ),
                          ),
                        );
                      },
                    ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildToolButton(
                    icon: Icons.rotate_left,
                    label: 'Rotate L',
                    onTap: () => _rotate(-90),
                  ),
                  _buildToolButton(
                    icon: Icons.rotate_right,
                    label: 'Rotate R',
                    onTap: () => _rotate(90),
                  ),
                  _buildToolButton(
                    icon: Icons.flip,
                    label: 'Flip',
                    onTap: _flip,
                    active: _flipH,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 4),
              child: Text(
                'Pinch to zoom · Drag to reposition',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? AppColors.accent.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.07),
              border: Border.all(
                color: active
                    ? AppColors.accent.withValues(alpha: 0.7)
                    : Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: Icon(
              icon,
              color: active ? AppColors.accent : Colors.white70,
              size: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: active ? AppColors.accent : Colors.white54,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _CropPainter extends CustomPainter {
  final ui.Image image;
  final double scale;
  final Offset offset;
  final double cropSize;
  final Size viewSize;
  final int rotateDeg;
  final bool flipH;

  _CropPainter({
    required this.image,
    required this.scale,
    required this.offset,
    required this.cropSize,
    required this.viewSize,
    required this.rotateDeg,
    required this.flipH,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bool isRotated90 = rotateDeg == 90 || rotateDeg == 270;
    final displayW =
        (isRotated90 ? image.height : image.width).toDouble() * scale;
    final displayH =
        (isRotated90 ? image.width : image.height).toDouble() * scale;

    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.save();
    canvas.translate(cx + offset.dx, cy + offset.dy);
    if (flipH) canvas.scale(-1, 1);
    if (rotateDeg != 0) {
      canvas.rotate(rotateDeg * 3.141592653589793 / 180);
    }

    final imgPaint = Paint()..filterQuality = FilterQuality.high;
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(
        -image.width.toDouble() * scale / 2,
        -image.height.toDouble() * scale / 2,
        image.width.toDouble() * scale,
        image.height.toDouble() * scale,
      ),
      imgPaint,
    );
    canvas.restore();

    final halfCrop = cropSize / 2;

    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    final overlayPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()
        ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: halfCrop)),
    );
    canvas.drawPath(overlayPath, overlayPaint);

    canvas.drawCircle(
      Offset(cx, cy),
      halfCrop,
      Paint()
        ..color = AppColors.accent.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    for (int i = 1; i < 3; i++) {
      final x = cx - halfCrop + (cropSize / 3) * i;
      canvas.drawLine(
        Offset(x, cy - halfCrop),
        Offset(x, cy + halfCrop),
        gridPaint,
      );
      final y = cy - halfCrop + (cropSize / 3) * i;
      canvas.drawLine(
        Offset(cx - halfCrop, y),
        Offset(cx + halfCrop, y),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CropPainter old) =>
      old.scale != scale ||
      old.offset != offset ||
      old.cropSize != cropSize ||
      old.rotateDeg != rotateDeg ||
      old.flipH != flipH;
}
