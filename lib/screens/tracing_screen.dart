import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:trace_craft/models/session_model.dart';
import 'package:trace_craft/services/ad_service.dart';
import 'package:trace_craft/services/camera_service.dart';
import 'package:trace_craft/services/database_service.dart';
import 'package:trace_craft/services/edge_detection_service.dart';
import 'package:trace_craft/widgets/glass_card_widget.dart';
import 'package:trace_craft/widgets/grid_overlay_widget.dart';

class TracingScreen extends ConsumerStatefulWidget {
  final String? imagePathOrUrl;
  final String title;
  final Session? initialSession;
  final bool initialEdgeDetection;

  const TracingScreen({
    super.key,
    this.imagePathOrUrl,
    this.title = 'Camera Lucida Tracing',
    this.initialSession,
    this.initialEdgeDetection = false,
  });

  @override
  ConsumerState<TracingScreen> createState() => _TracingScreenState();
}

class _TracingScreenState extends ConsumerState<TracingScreen> with WidgetsBindingObserver {
  // Camera state
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _cameraPermissionDenied = false;
  bool _isTorchOn = false;

  // Session & Overlay State
  late String _sessionId;
  late String _imagePathOrUrl;
  late TransformationController _transformController;
  late double _opacity;
  bool _isLocked = false;
  bool _isOverlayVisible = true;
  bool _isFlippedH = false;
  bool _isFlippedV = false;
  final DateTime _createdAt = DateTime.now();

  // Edge detection / Line-art state
  bool _isEdgeDetectionEnabled = false;
  bool _isLineArtUnlocked = false;
  double _edgeThreshold = 0.5;
  String? _cachedLineArtPath;
  bool _isProcessingEdge = false;

  // Grid overlay state
  bool _isGridEnabled = false;
  int _gridDivisions = 3;

  // Debouncer for Hive persistence
  Timer? _debounceTimer;

  static const String _defaultSampleImage =
      'https://images.pexels.com/photos/1858175/pexels-photo-1858175.jpeg?auto=compress&cs=tinysrgb&w=800';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Keep screen awake while tracing
    WakelockPlus.enable();

    // Enable sticky immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Load or initialize Session state
    _initSessionState();

    // Initialize Camera Feed
    _initCamera();

    // Pre-generate edge line art if requested initially
    if (_isEdgeDetectionEnabled) {
      _generateLineArt();
    }
  }

  void _initSessionState() {
    if (widget.initialSession != null) {
      final s = widget.initialSession!;
      _sessionId = s.id;
      _imagePathOrUrl = s.sourceImagePath;
      _opacity = s.opacity;
      _isLocked = s.isLocked;
      _isFlippedH = s.isFlippedHorizontal;
      _isFlippedV = s.isFlippedVertical;
      _isEdgeDetectionEnabled = s.isEdgeDetectionEnabled;
      _edgeThreshold = s.edgeThreshold;
      _isGridEnabled = s.isGridEnabled;
      _gridDivisions = s.gridDivision;
      _transformController = TransformationController(_listToMatrix4(s.matrix4Values));
    } else {
      _sessionId = const Uuid().v4();
      _imagePathOrUrl = widget.imagePathOrUrl ?? _defaultSampleImage;
      final settings = DatabaseService.getUserSettings();
      _opacity = settings.defaultOpacity;
      _gridDivisions = settings.defaultGridDivisions;
      _isEdgeDetectionEnabled = widget.initialEdgeDetection;
      _transformController = TransformationController(Matrix4.identity());
    }

    // Listen to transform changes for debounced persistence
    _transformController.addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _transformController.removeListener(_onTransformChanged);
    _transformController.dispose();
    _cameraController?.dispose();
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

  /// Initialize hardware camera
  Future<void> _initCamera() async {
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        final status = await Permission.camera.status;
        if (!status.isGranted) {
          final requested = await Permission.camera.request();
          if (!requested.isGranted) {
            if (mounted) setState(() => _cameraPermissionDenied = true);
            return;
          }
        }
      }

      await CameraService.initCameras();
      CameraDescription? camera = CameraService.getBackCamera();
      if (camera == null && CameraService.availableCamerasList.isNotEmpty) {
        camera = CameraService.availableCamerasList.first;
      }

      if (camera != null) {
        final controller = CameraController(
          camera,
          ResolutionPreset.high,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );

        await controller.initialize();
        if (mounted) {
          setState(() {
            _cameraController = controller;
            _isCameraInitialized = true;
            _cameraPermissionDenied = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isCameraInitialized = false;
            _cameraPermissionDenied = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Camera init note: $e');
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
    }
  }

  /// Toggle torch / flashlight
  Future<void> _toggleTorch() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    try {
      if (_isTorchOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch);
      }
      setState(() => _isTorchOn = !_isTorchOn);
      HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Torch toggle error: $e');
    }
  }

  /// Generate or retrieve cached edge-detection line art
  Future<void> _generateLineArt() async {
    setState(() => _isProcessingEdge = true);

    final path = await EdgeDetectionService.convertToLineArt(
      sourcePathOrUrl: _imagePathOrUrl,
      threshold: _edgeThreshold,
      invert: true,
    );

    if (mounted) {
      setState(() {
        _cachedLineArtPath = path;
        _isProcessingEdge = false;
      });
      _debounceSaveSession();
    }
  }

  /// Toggle Edge-detection outline mode with Rewarded Ad unlock
  void _toggleEdgeDetection() {
    // If enabling and not yet unlocked in this session, show Rewarded Ad prompt
    if (!_isEdgeDetectionEnabled && !_isLineArtUnlocked) {
      _showRewardedLineArtModal();
      return;
    }

    setState(() {
      _isEdgeDetectionEnabled = !_isEdgeDetectionEnabled;
    });
    HapticFeedback.selectionClick();

    if (_isEdgeDetectionEnabled && _cachedLineArtPath == null) {
      _generateLineArt();
    } else {
      _debounceSaveSession();
    }
  }

  void _showRewardedLineArtModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181B24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00CEC9).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_fix_high_rounded, color: Color(0xFF00CEC9), size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'Unlock Line-Art Outline Mode',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Watch a short video ad to unlock real-time Sobel line-art filtering for this tracing session.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.play_circle_fill_rounded),
                label: const Text('Watch Ad & Unlock (Free)', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.pop(ctx);
                  AdService.showRewardedAd(
                    onUserEarnedReward: (reward) {
                      if (mounted) {
                        setState(() {
                          _isLineArtUnlocked = true;
                          _isEdgeDetectionEnabled = true;
                        });
                        if (_cachedLineArtPath == null) {
                          _generateLineArt();
                        } else {
                          _debounceSaveSession();
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✨ Line-Art mode unlocked for this session!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Toggle Grid overlay guide
  void _toggleGrid() {
    setState(() {
      _isGridEnabled = !_isGridEnabled;
    });
    HapticFeedback.selectionClick();
    _debounceSaveSession();
  }

  /// Flip Horizontal (Mirror reference)
  void _flipHorizontal() {
    setState(() {
      _isFlippedH = !_isFlippedH;
      final current = Matrix4.copy(_transformController.value);
      current.scaleByDouble(-1.0, 1.0, 1.0, 1.0);
      _transformController.value = current;
    });
    HapticFeedback.mediumImpact();
    _debounceSaveSession();
  }

  /// Flip Vertical
  void _flipVertical() {
    setState(() {
      _isFlippedV = !_isFlippedV;
      final current = Matrix4.copy(_transformController.value);
      current.scaleByDouble(1.0, -1.0, 1.0, 1.0);
      _transformController.value = current;
    });
    HapticFeedback.mediumImpact();
    _debounceSaveSession();
  }

  /// Reset scale and translation
  void _resetTransform() {
    setState(() {
      _isFlippedH = false;
      _isFlippedV = false;
      _transformController.value = Matrix4.identity();
    });
    HapticFeedback.mediumImpact();
    _debounceSaveSession();
  }

  /// Toggle Lock position
  void _toggleLock() {
    setState(() {
      _isLocked = !_isLocked;
    });
    HapticFeedback.heavyImpact();
    _debounceSaveSession();
  }

  /// Called whenever pinch-zoom, pan, or rotate occurs
  void _onTransformChanged() {
    if (!_isLocked) {
      _debounceSaveSession();
    }
  }

  /// Debounces saving the session to Hive (400ms)
  void _debounceSaveSession() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _saveSessionToHive();
    });
  }

  /// Persists current session state to Hive Box
  Future<void> _saveSessionToHive() async {
    final matrixList = _transformController.value.storage.toList();

    final session = Session(
      id: _sessionId,
      title: widget.title,
      sourceImagePath: _imagePathOrUrl,
      opacity: _opacity,
      matrix4Values: matrixList,
      isLocked: _isLocked,
      isFlippedHorizontal: _isFlippedH,
      isFlippedVertical: _isFlippedV,
      isEdgeDetectionEnabled: _isEdgeDetectionEnabled,
      edgeThreshold: _edgeThreshold,
      isGridEnabled: _isGridEnabled,
      gridDivision: _gridDivisions,
      createdAt: _createdAt,
      lastModifiedAt: DateTime.now(),
    );

    await DatabaseService.saveSession(session);
    debugPrint('Session $_sessionId persisted to Hive.');
  }

  /// Switch or import a new reference image directly from device's Photo Gallery
  Future<void> _importNewImageFromGallery() async {
    HapticFeedback.lightImpact();
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 95);
      if (picked != null && mounted) {
        setState(() {
          _imagePathOrUrl = picked.path;
          _cachedLineArtPath = null;
          _isEdgeDetectionEnabled = false;
        });
        _debounceSaveSession();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🖼️ New reference image loaded from gallery!'),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFF6C5CE7),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open photo gallery: $e')),
        );
      }
    }
  }

  /// Marks the drawing session as complete, updates streak & total completions in UserSettings
  Future<void> _finishDrawing() async {
    final matrixList = _transformController.value.storage.toList();
    final session = Session(
      id: _sessionId,
      title: widget.title,
      sourceImagePath: _imagePathOrUrl,
      opacity: _opacity,
      matrix4Values: matrixList,
      isLocked: _isLocked,
      isFlippedHorizontal: _isFlippedH,
      isFlippedVertical: _isFlippedV,
      isEdgeDetectionEnabled: _isEdgeDetectionEnabled,
      edgeThreshold: _edgeThreshold,
      isGridEnabled: _isGridEnabled,
      gridDivision: _gridDivisions,
      createdAt: _createdAt,
      lastModifiedAt: DateTime.now(),
      isCompleted: true,
    );

    await DatabaseService.saveSession(session);
    final updatedSettings = await DatabaseService.recordDrawingSession(isCompleted: true);
    HapticFeedback.heavyImpact();

    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF181B24),
          title: const Row(
            children: [
              Icon(Icons.emoji_events_rounded, color: Color(0xFFFFB300), size: 28),
              SizedBox(width: 8),
              Text('Drawing Completed!', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Congratulations on finishing "${widget.title}"!'),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF7675), size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Daily Streak: ${updatedSettings.currentStreakDays} Days',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.brush_rounded, color: Color(0xFF00CEC9), size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Total Drawings: ${updatedSettings.totalDrawingsCompleted}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Return to Projects'),
            ),
          ],
        ),
      );
    }
  }

  /// Helper: converts double list to Matrix4
  Matrix4 _listToMatrix4(List<double> values) {
    if (values.length != 16) return Matrix4.identity();
    return Matrix4.fromList(values);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. LAYER 1: FIXED LIVE CAMERA PREVIEW (Stationary Base)
          if (_isCameraInitialized && _cameraController != null)
            CameraPreview(_cameraController!)
          else
            _buildCameraFallback(),

          // 2. LAYER 2: PROPORTIONAL GRID OVERLAY GUIDE (Independent Layer)
          if (_isGridEnabled)
            Positioned.fill(
              child: IgnorePointer(
                child: GridOverlayWidget(
                  divisions: _gridDivisions,
                  gridColor: const Color(0x9900CEC9),
                ),
              ),
            ),

          // 3. LAYER 3: OVERLAY REFERENCE IMAGE / CACHED LINE-ART (Interactive Layer)
          if (_isOverlayVisible)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: _isLocked,
                child: InteractiveViewer(
                  transformationController: _transformController,
                  minScale: 0.1,
                  maxScale: 12.0,
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

          // 4. TOP APP BAR & STATUS PILL
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              children: [
                // Back Button
                CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                    onPressed: () {
                      _saveSessionToHive();
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Title & Active Layer Indicators
                Expanded(
                  child: GlassCardWidget(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    borderRadius: 20,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.draw_rounded, color: Color(0xFF00CEC9), size: 18),
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
                        if (_isLocked) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB300),
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
                      ],
                    ),
                  ),
                ),
                // Import Image from Photo Gallery
                IconButton(
                  icon: const Icon(Icons.add_photo_alternate_rounded, color: Colors.white, size: 24),
                  tooltip: 'Import Photo from Gallery',
                  onPressed: _importNewImageFromGallery,
                ),
                // Finish / Complete Drawing Button
                IconButton(
                  icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF00CEC9), size: 28),
                  tooltip: 'Finish Drawing',
                  onPressed: _finishDrawing,
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),

          // 5. RIGHT FLOATING CONTROL PANEL (Lock, Torch, Line-Art, Grid, Mirror/Flip, Reset)
          Positioned(
            right: 16,
            top: MediaQuery.of(context).padding.top + 70,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Lock Position Tool Button
                GlassCardWidget(
                  borderRadius: 30,
                  padding: const EdgeInsets.all(4),
                  color: _isLocked ? const Color(0xFFFFB300).withValues(alpha: 0.3) : null,
                  child: IconButton(
                    icon: Icon(
                      _isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                      color: _isLocked ? const Color(0xFFFFB300) : Colors.white70,
                      size: 24,
                    ),
                    tooltip: _isLocked ? 'Unlock Overlay' : 'Lock Overlay Position',
                    onPressed: _toggleLock,
                  ),
                ),
                const SizedBox(height: 10),

                // Multi-Layer Control Strip
                GlassCardWidget(
                  borderRadius: 24,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Column(
                    children: [
                      // Torch / Flashlight
                      IconButton(
                        icon: Icon(
                          _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                          color: _isTorchOn ? const Color(0xFFFFB300) : Colors.white70,
                          size: 20,
                        ),
                        tooltip: 'Flashlight',
                        onPressed: _toggleTorch,
                      ),
                      const SizedBox(height: 6),

                      // Edge Detection / Line-Art Mode Toggle
                      IconButton(
                        icon: Icon(
                          Icons.auto_fix_high_rounded,
                          color: _isEdgeDetectionEnabled ? const Color(0xFF00CEC9) : Colors.white70,
                          size: 20,
                        ),
                        tooltip: 'Outline / Line-Art Mode',
                        onPressed: _toggleEdgeDetection,
                      ),
                      const SizedBox(height: 6),

                      // Grid Guide Toggle
                      IconButton(
                        icon: Icon(
                          Icons.grid_4x4_rounded,
                          color: _isGridEnabled ? const Color(0xFFFD79A8) : Colors.white70,
                          size: 20,
                        ),
                        tooltip: 'Proportion Grid Overlay',
                        onPressed: _toggleGrid,
                      ),
                      const SizedBox(height: 6),

                      // Mirror / Flip Horizontal
                      IconButton(
                        icon: const Icon(Icons.flip_rounded, color: Colors.white70, size: 20),
                        tooltip: 'Flip Horizontal (Mirror)',
                        onPressed: _flipHorizontal,
                      ),
                      const SizedBox(height: 6),

                      // Flip Vertical
                      IconButton(
                        icon: const Icon(Icons.swap_vert_rounded, color: Colors.white70, size: 20),
                        tooltip: 'Flip Vertical',
                        onPressed: _flipVertical,
                      ),
                      const SizedBox(height: 6),

                      // Reset Scale & Pan
                      IconButton(
                        icon: const Icon(Icons.restart_alt_rounded, color: Colors.white70, size: 20),
                        tooltip: 'Reset Transformation',
                        onPressed: _resetTransform,
                      ),
                      const SizedBox(height: 6),

                      // Save Project to Hive
                      IconButton(
                        icon: const Icon(Icons.bookmark_add_rounded, color: Color(0xFF6C5CE7), size: 20),
                        tooltip: 'Save Session State',
                        onPressed: () async {
                          await _saveSessionToHive();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Session saved to Hive.'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                          await AdService.incrementSaveAndShowInterstitial();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 6. BOTTOM FLOATING OPACITY CONTROLLER
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 12,
            left: 20,
            right: 20,
            child: GlassCardWidget(
              borderRadius: 24,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Eye Peek Button
                      IconButton(
                        icon: Icon(
                          _isOverlayVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                          color: _isOverlayVisible ? const Color(0xFF00CEC9) : Colors.white38,
                          size: 22,
                        ),
                        tooltip: _isOverlayVisible ? 'Hide reference' : 'Show reference',
                        onPressed: () {
                          setState(() => _isOverlayVisible = !_isOverlayVisible);
                          HapticFeedback.selectionClick();
                        },
                      ),

                      // Opacity Slider
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 5,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
                            activeTrackColor: const Color(0xFFA29BFE),
                            thumbColor: Colors.white,
                          ),
                          child: Slider(
                            value: _opacity.clamp(0.05, 0.95),
                            min: 0.05,
                            max: 0.95,
                            onChanged: (val) {
                              setState(() => _opacity = val);
                              _debounceSaveSession();
                            },
                          ),
                        ),
                      ),

                      // Percentage Badge
                      Container(
                        width: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Center(
                          child: Text(
                            '${(_opacity * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00CEC9),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Quick Presets
                  Padding(
                    padding: const EdgeInsets.only(top: 2, bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildPresetChip('25%', 0.25),
                        const SizedBox(width: 8),
                        _buildPresetChip('45% (Recommended)', 0.45),
                        const SizedBox(width: 8),
                        _buildPresetChip('70%', 0.70),
                        const SizedBox(width: 8),
                        _buildPresetChip('90%', 0.90),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 7. LINE ART COMPUTATION SPINNER
          if (_isProcessingEdge)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF00CEC9)),
                    SizedBox(height: 14),
                    Text(
                      'Generating Line-Art Outline...',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, double value) {
    final isSelected = (_opacity - value).abs() < 0.05;
    return InkWell(
      onTap: () {
        setState(() => _opacity = value);
        HapticFeedback.selectionClick();
        _debounceSaveSession();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C5CE7) : Colors.black45,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFA29BFE) : Colors.white24,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildReferenceImage() {
    // If Edge Detection Line-Art mode is active and processed
    if (_isEdgeDetectionEnabled && _cachedLineArtPath != null) {
      return Image.file(
        File(_cachedLineArtPath!),
        fit: BoxFit.contain,
      );
    }

    // Default photo reference
    if (_imagePathOrUrl.startsWith('http://') || _imagePathOrUrl.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: _imagePathOrUrl,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(color: Color(0xFFA29BFE)),
        ),
        errorWidget: (context, url, error) => const Center(
          child: Icon(Icons.broken_image_rounded, color: Colors.white54, size: 48),
        ),
      );
    } else {
      return Image.file(
        File(_imagePathOrUrl),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.image_not_supported_rounded, color: Colors.white54, size: 48),
        ),
      );
    }
  }

  Widget _buildCameraFallback() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF1EFE7), // Natural artist drawing paper tone
      ),
      child: Stack(
        children: [
          // Background desk texture and paper border
          Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAF7),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE2DDD0), width: 1.5),
              ),
              child: Center(
                child: Opacity(
                  opacity: 0.35,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _cameraPermissionDenied ? Icons.videocam_off_rounded : Icons.draw_outlined,
                        size: 48,
                        color: Colors.black45,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _cameraPermissionDenied
                            ? 'Camera Permission Denied'
                            : 'Drawing Paper Surface (Camera Preview)',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Mount phone on stand above real paper to trace onto your sketchbook.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Camera status pill / retry button
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 90,
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFF00CEC9), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      _cameraPermissionDenied ? 'Grant camera permission' : 'Paper Canvas Active',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: _initCamera,
                      child: const Row(
                        children: [
                          Icon(Icons.refresh_rounded, color: Color(0xFFA29BFE), size: 16),
                          SizedBox(width: 4),
                          Text('Retry Camera', style: TextStyle(color: Color(0xFFA29BFE), fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
