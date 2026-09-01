import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:trace_craft/core/constants/app_colors.dart';
import 'package:trace_craft/core/database/hive_boxes.dart';
import 'package:trace_craft/core/services/camera_service.dart';
import 'package:trace_craft/core/services/edge_filter_service.dart';
import 'package:trace_craft/core/utils/matrix_converter.dart';
import 'package:trace_craft/core/utils/permissions_helper.dart';
import 'package:trace_craft/features/gallery/presentation/widgets/upload_artwork_sheet.dart';
import 'package:trace_craft/features/tracing/domain/models/tracing_session.dart';
import 'package:trace_craft/features/tracing/presentation/widgets/edge_tuning_sheet.dart';
import 'package:trace_craft/features/tracing/presentation/widgets/grid_overlay_painter.dart';
import 'package:trace_craft/features/tracing/presentation/widgets/opacity_control_bar.dart';
import 'package:trace_craft/features/tracing/presentation/widgets/tracing_control_panel.dart';

class TracingScreen extends ConsumerStatefulWidget {
  final String imagePathOrUrl;
  final String title;
  final TracingSession? existingSession;
  final bool initialEdgeDetection;

  const TracingScreen({
    super.key,
    required this.imagePathOrUrl,
    this.title = 'Tracing Project',
    this.existingSession,
    this.initialEdgeDetection = false,
  });

  @override
  ConsumerState<TracingScreen> createState() => _TracingScreenState();
}

class _TracingScreenState extends ConsumerState<TracingScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _cameraPermissionDenied = false;
  bool _isTorchOn = false;

  late TransformationController _transformController;
  late double _opacity;
  bool _isLocked = false;
  bool _isFlippedH = false;
  bool _isFlippedV = false;
  bool _isOverlayVisible = true;

  // Edge detection line-art state
  bool _isEdgeDetectionEnabled = false;
  double _edgeThreshold = 0.5;
  bool _edgeInverted = true;
  String? _processedEdgeImagePath;
  bool _isProcessingEdge = false;

  // Grid state
  bool _isGridEnabled = false;
  int _gridDivisions = 3;

  String _sessionId = const Uuid().v4();
  final DateTime _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize wakelock to prevent screen sleep while drawing
    WakelockPlus.enable();

    // Set immersive UI mode for maximum drawing area
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Load session or defaults
    if (widget.existingSession != null) {
      final s = widget.existingSession!;
      _sessionId = s.id;
      _opacity = s.opacity;
      _isLocked = s.isLocked;
      _isFlippedH = s.isFlippedHorizontal;
      _isFlippedV = s.isFlippedVertical;
      _isEdgeDetectionEnabled = s.isEdgeDetectionEnabled;
      _edgeThreshold = s.edgeThreshold;
      _isGridEnabled = s.isGridEnabled;
      _gridDivisions = s.gridDivision;
      _transformController = TransformationController(MatrixConverter.listToMatrix4(s.matrix4Values));
    } else {
      final settings = HiveDatabase.getUserSettings();
      _opacity = settings.defaultOpacity;
      _gridDivisions = settings.defaultGridDivisions;
      _isEdgeDetectionEnabled = widget.initialEdgeDetection;
      _transformController = TransformationController(Matrix4.identity());
    }

    _initCamera();

    if (_isEdgeDetectionEnabled) {
      _generateLineArt();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _cameraController?.dispose();
    _transformController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    final hasPermission = await PermissionsHelper.requestCameraPermission(context);
    if (!hasPermission) {
      if (mounted) setState(() => _cameraPermissionDenied = true);
      return;
    }

    await CameraManager.initializeCameras();
    final backCam = CameraManager.getBackCamera();

    if (backCam == null) {
      if (mounted) setState(() => _isCameraInitialized = false);
      return;
    }

    try {
      _cameraController = CameraController(
        backCam,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _cameraPermissionDenied = false;
        });
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
      if (mounted) setState(() => _isCameraInitialized = false);
    }
  }

  Future<void> _toggleTorch() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    try {
      if (_isTorchOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch);
      }
      setState(() => _isTorchOn = !_isTorchOn);
    } catch (e) {
      debugPrint('Torch error: $e');
    }
  }

  Future<void> _generateLineArt() async {
    setState(() => _isProcessingEdge = true);
    final path = await EdgeFilterService.generateLineArt(
      sourcePathOrUrl: widget.imagePathOrUrl,
      threshold: _edgeThreshold,
      invert: _edgeInverted,
    );
    if (mounted) {
      setState(() {
        _processedEdgeImagePath = path;
        _isProcessingEdge = false;
      });
    }
  }

  void _flipHorizontal() {
    setState(() {
      _isFlippedH = !_isFlippedH;
      final current = _transformController.value;
      _transformController.value = MatrixConverter.applyHorizontalFlip(current);
    });
  }

  void _flipVertical() {
    setState(() {
      _isFlippedV = !_isFlippedV;
      final current = _transformController.value;
      _transformController.value = MatrixConverter.applyVerticalFlip(current);
    });
  }

  void _resetTransform() {
    setState(() {
      _isFlippedH = false;
      _isFlippedV = false;
      _transformController.value = Matrix4.identity();
    });
  }

  Future<void> _saveSession({bool showToast = true}) async {
    final session = TracingSession(
      id: _sessionId,
      title: widget.title,
      sourceImagePath: widget.imagePathOrUrl,
      opacity: _opacity,
      matrix4Values: MatrixConverter.matrix4ToList(_transformController.value),
      isLocked: _isLocked,
      isFlippedHorizontal: _isFlippedH,
      isFlippedVertical: _isFlippedV,
      isEdgeDetectionEnabled: _isEdgeDetectionEnabled,
      edgeThreshold: _edgeThreshold,
      isGridEnabled: _isGridEnabled,
      gridDivision: _gridDivisions,
      createdAt: widget.existingSession?.createdAt ?? _startTime,
      lastModifiedAt: DateTime.now(),
      drawingTimeSeconds: (widget.existingSession?.drawingTimeSeconds ?? 0) +
          DateTime.now().difference(_startTime).inSeconds,
    );

    await HiveDatabase.sessionsBox.put(_sessionId, session);

    if (showToast && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Project "${widget.title}" saved! Resume anytime.'),
          backgroundColor: AppColors.accentGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _finishArtwork() async {
    await _saveSession(showToast: false);

    // Update streak record
    final streak = HiveDatabase.getStreakRecord();
    final updatedStreak = streak.copyWith(
      totalDrawingsCompleted: streak.totalDrawingsCompleted + 1,
      lastDrawnDate: DateTime.now(),
      currentStreakDays: streak.currentStreakDays + 1,
      maxStreakDays: (streak.currentStreakDays + 1) > streak.maxStreakDays
          ? streak.currentStreakDays + 1
          : streak.maxStreakDays,
    );
    await HiveDatabase.saveStreakRecord(updatedStreak);

    if (mounted) {
      UploadArtworkSheet.show(
        context,
        referenceImageUrl: widget.imagePathOrUrl,
        initialTitle: widget.title,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. LIVE CAMERA FEED
          if (_isCameraInitialized && _cameraController != null)
            CameraPreview(_cameraController!)
          else
            _buildCameraFallback(),

          // 2. PROPORTIONAL GRID OVERLAY
          if (_isGridEnabled)
            CustomPaint(
              size: Size.infinite,
              painter: GridOverlayPainter(
                divisions: _gridDivisions,
                gridColor: AppColors.defaultGridColor,
                showDiagonals: true,
              ),
            ),

          // 3. OVERLAY REFERENCE IMAGE (Interactive Transformation Layer)
          if (_isOverlayVisible)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: _isLocked,
                child: InteractiveViewer(
                  transformationController: _transformController,
                  minScale: 0.1,
                  maxScale: 10.0,
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  panEnabled: !_isLocked,
                  scaleEnabled: !_isLocked,
                  child: Opacity(
                    opacity: _opacity.clamp(0.01, 1.0),
                    child: _buildReferenceImage(),
                  ),
                ),
              ),
            ),

          // 4. TOP BAR (Back Button + Title + Status Pill)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.6),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                    onPressed: () {
                      _saveSession(showToast: false);
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.draw_rounded, color: AppColors.accentCyan, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (_isLocked)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentAmber,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'LOCKED',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 5. RIGHT FLOATING CONTROL PANEL
          Positioned(
            right: 16,
            top: MediaQuery.of(context).padding.top + 70,
            child: TracingControlPanel(
              isLocked: _isLocked,
              onToggleLock: () => setState(() => _isLocked = !_isLocked),
              isTorchOn: _isTorchOn,
              onToggleTorch: _toggleTorch,
              isEdgeDetectionEnabled: _isEdgeDetectionEnabled,
              onOpenEdgeTuning: () {
                EdgeTuningSheet.show(
                  context,
                  isEdgeEnabled: _isEdgeDetectionEnabled,
                  currentThreshold: _edgeThreshold,
                  isInverted: _edgeInverted,
                  onApply: (enabled, threshold, invert) {
                    setState(() {
                      _isEdgeDetectionEnabled = enabled;
                      _edgeThreshold = threshold;
                      _edgeInverted = invert;
                    });
                    if (enabled) _generateLineArt();
                  },
                );
              },
              isGridEnabled: _isGridEnabled,
              onToggleGrid: () => setState(() => _isGridEnabled = !_isGridEnabled),
              onFlipHorizontal: _flipHorizontal,
              onFlipVertical: _flipVertical,
              onResetTransform: _resetTransform,
              onSaveSession: () => _saveSession(showToast: true),
              onFinishArtwork: _finishArtwork,
            ),
          ),

          // 6. BOTTOM OPACITY CONTROL SLIDER
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 12,
            left: 20,
            right: 20,
            child: OpacityControlBar(
              opacity: _opacity,
              isVisible: _isOverlayVisible,
              onOpacityChanged: (val) => setState(() => _opacity = val),
              onToggleVisibility: () => setState(() => _isOverlayVisible = !_isOverlayVisible),
            ),
          ),

          // 7. LOADING OVERLAY FOR EDGE DETECTION
          if (_isProcessingEdge)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.accentCyan),
                    SizedBox(height: 14),
                    Text(
                      'Extracting Line-Art Outlines...',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReferenceImage() {
    // If line art is enabled and processed
    if (_isEdgeDetectionEnabled && _processedEdgeImagePath != null) {
      return Image.file(
        File(_processedEdgeImagePath!),
        fit: BoxFit.contain,
      );
    }

    if (widget.imagePathOrUrl.startsWith('http://') || widget.imagePathOrUrl.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: widget.imagePathOrUrl,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: AppColors.primaryLight)),
      );
    } else {
      return Image.file(
        File(widget.imagePathOrUrl),
        fit: BoxFit.contain,
      );
    }
  }

  Widget _buildCameraFallback() {
    return Container(
      color: const Color(0xFF1E2026),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_off_rounded, size: 56, color: AppColors.accentAmber),
              const SizedBox(height: 16),
              Text(
                _cameraPermissionDenied ? 'Camera Permission Denied' : 'Camera Feed Preview Mode',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                _cameraPermissionDenied
                    ? 'Please allow camera permission in settings to see real paper feed.'
                    : 'Mount your device over paper to begin camera lucida tracing.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              FilledButton.tonalIcon(
                onPressed: _initCamera,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry Camera'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
