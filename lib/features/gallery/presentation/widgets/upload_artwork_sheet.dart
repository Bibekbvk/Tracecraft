import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:trace_craft/core/constants/app_colors.dart';
import 'package:trace_craft/core/services/firestore_service.dart';
import 'package:trace_craft/features/gallery/domain/models/gallery_post.dart';

class UploadArtworkSheet extends StatefulWidget {
  final String? referenceImageUrl;
  final String initialTitle;

  const UploadArtworkSheet({
    super.key,
    this.referenceImageUrl,
    this.initialTitle = '',
  });

  static void show(
    BuildContext context, {
    String? referenceImageUrl,
    String initialTitle = '',
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => UploadArtworkSheet(
        referenceImageUrl: referenceImageUrl,
        initialTitle: initialTitle,
      ),
    );
  }

  @override
  State<UploadArtworkSheet> createState() => _UploadArtworkSheetState();
}

class _UploadArtworkSheetState extends State<UploadArtworkSheet> {
  final ImagePicker _picker = ImagePicker();
  String? _pickedDrawingPath;
  late TextEditingController _titleController;
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final List<String> _tags = ['camera_lucida', 'tracing', 'sketch'];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    final file = await _picker.pickImage(source: ImageSource.camera);
    if (file != null) {
      setState(() => _pickedDrawingPath = file.path);
    }
  }

  Future<void> _pickGallery() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _pickedDrawingPath = file.path);
    }
  }

  void _addTag() {
    final text = _tagController.text.trim().replaceAll('#', '');
    if (text.isNotEmpty && !_tags.contains(text)) {
      setState(() {
        _tags.add(text);
        _tagController.clear();
      });
    }
  }

  Future<void> _publish() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an artwork title.')),
      );
      return;
    }

    setState(() => _isUploading = true);

    final newPost = GalleryPost(
      id: const Uuid().v4(),
      authorId: 'my_user_id',
      authorName: 'Creative Explorer',
      drawingImageUrl: _pickedDrawingPath ?? widget.referenceImageUrl ?? 'https://images.pexels.com/photos/1858175/pexels-photo-1858175.jpeg',
      referenceImageUrl: widget.referenceImageUrl,
      title: _titleController.text.trim(),
      description: _descController.text.trim().isNotEmpty
          ? _descController.text.trim()
          : 'Drawn using TraceCraft Camera Lucida AR assistant on physical paper.',
      tags: _tags,
      likesCount: 1,
      likedUserIds: ['my_user_id'],
      averageRating: 5.0,
      totalRatingsCount: 1,
      createdAt: DateTime.now(),
    );

    await CommunityGalleryService.createPost(newPost);

    if (mounted) {
      setState(() => _isUploading = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Artwork published to Community Gallery!'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.glassBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Share Drawing with Community',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Take a photo of your finished physical drawing to inspire other artists.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // Drawing Photo Picker Area
            InkWell(
              onTap: _takePhoto,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.glassBorder, width: 1.2),
                ),
                child: _pickedDrawingPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(_pickedDrawingPath!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 28),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Snap Photo of Finished Drawing',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          TextButton(
                            onPressed: _pickGallery,
                            child: const Text('or choose from Gallery', style: TextStyle(color: AppColors.accentCyan)),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Artwork Title',
                filled: true,
                fillColor: AppColors.surfaceDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 12),

            // Description
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Technique, medium, or notes (optional)',
                filled: true,
                fillColor: AppColors.surfaceDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 12),

            // Tags
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _tags
                  .map(
                    (tag) => Chip(
                      label: Text('#$tag', style: const TextStyle(fontSize: 11)),
                      backgroundColor: AppColors.surfaceElevated,
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => setState(() => _tags.remove(tag)),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    onSubmitted: (_) => _addTag(),
                    decoration: InputDecoration(
                      hintText: 'Add custom tag (e.g. pencil, anime)',
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  icon: const Icon(Icons.add_rounded),
                  onPressed: _addTag,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Publish Button
            FilledButton.icon(
              onPressed: _isUploading ? null : _publish,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.cloud_upload_rounded),
              label: Text(
                _isUploading ? 'Publishing Artwork...' : 'Publish to Community Gallery',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
