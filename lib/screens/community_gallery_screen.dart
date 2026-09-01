import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:trace_craft/models/gallery_post_model.dart';
import 'package:trace_craft/screens/auth_screen.dart';
import 'package:trace_craft/services/firebase_auth_service.dart';
import 'package:trace_craft/services/firestore_service.dart';
import 'package:trace_craft/services/storage_service.dart';
import 'package:trace_craft/widgets/bottom_banner_ad_widget.dart';

class CommunityGalleryScreen extends ConsumerStatefulWidget {
  const CommunityGalleryScreen({super.key});

  @override
  ConsumerState<CommunityGalleryScreen> createState() => _CommunityGalleryScreenState();
}

class _CommunityGalleryScreenState extends ConsumerState<CommunityGalleryScreen> {
  String _currentFilter = 'trending';
  bool _isLoading = false;
  List<GalleryPost> _posts = [];
  String _currentUserId = '';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initUserAndLoadPosts();
  }

  Future<void> _initUserAndLoadPosts() async {
    setState(() => _isLoading = true);
    final uid = FirebaseAuthService.getCurrentUserId();
    final posts = await FirestoreService.fetchPosts(filter: _currentFilter);

    if (mounted) {
      setState(() {
        _currentUserId = uid;
        _posts = posts;
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshPosts() async {
    final posts = await FirestoreService.fetchPosts(filter: _currentFilter);
    if (mounted) {
      setState(() => _posts = posts);
    }
  }

  void _onFilterChanged(String filter) {
    if (_currentFilter == filter) return;
    setState(() {
      _currentFilter = filter;
      _isLoading = true;
    });
    FirestoreService.fetchPosts(filter: filter).then((posts) {
      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _toggleLike(GalleryPost post) async {
    HapticFeedback.lightImpact();
    final updated = await FirestoreService.toggleLike(post.id, _currentUserId);
    if (updated != null && mounted) {
      setState(() {
        final idx = _posts.indexWhere((p) => p.id == post.id);
        if (idx != -1) _posts[idx] = updated;
      });
    }
  }

  Future<void> _ratePost(GalleryPost post, double rating) async {
    HapticFeedback.mediumImpact();
    final updated = await FirestoreService.ratePost(post.id, _currentUserId, rating);
    if (updated != null && mounted) {
      setState(() {
        final idx = _posts.indexWhere((p) => p.id == post.id);
        if (idx != -1) _posts[idx] = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rated $rating stars on "${post.title}"!'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _showRatingModal(BuildContext context, GalleryPost post) {
    final userRating = post.userRatings[_currentUserId] ?? 5.0;
    double selectedRating = userRating;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181B24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 18),
            const Text(
              'Rate this Drawing',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'How accurate and creative is "${post.title}"?',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 20),
            RatingBar.builder(
              initialRating: selectedRating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 36,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(Icons.star_rounded, color: Color(0xFFFFB300)),
              onRatingUpdate: (rating) {
                selectedRating = rating;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _ratePost(post, selectedRating);
                },
                child: const Text('Submit Rating', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Open Upload Artwork Flow
  Future<void> _openUploadModal() async {
    // Restrict guest users from publishing to community showcase
    if (FirebaseAuthService.isGuest) {
      final shouldSignIn = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF181B24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.lock_person_rounded, color: Color(0xFF6C5CE7)),
              SizedBox(width: 10),
              Text('Account Required', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: const Text(
            'You are currently in Guest Mode. Guests can trace photos and save local projects, but creating or signing into an account is required to publish drawings to the Community Showcase.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Continue as Guest', style: TextStyle(color: Colors.white54)),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
              icon: const Icon(Icons.login_rounded, size: 16),
              label: const Text('Sign In / Register'),
              onPressed: () => Navigator.pop(ctx, true),
            ),
          ],
        ),
      );

      if (shouldSignIn == true && mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AuthScreen(isFromDrawer: true)),
        );
        setState(() {
          _currentUserId = FirebaseAuthService.getCurrentUserId();
        });
        if (FirebaseAuthService.isGuest) return;
      } else {
        return;
      }
    }

    if (!mounted) return;

    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF181B24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text(
              'Upload Finished Drawing',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded, color: Color(0xFF00CEC9)),
              title: const Text('Take Photo with Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: Color(0xFFA29BFE)),
              title: const Text('Choose from Photo Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null || !mounted) return;

    final imageFile = File(picked.path);
    _showPostDetailsDialog(imageFile);
  }

  void _showPostDetailsDialog(File imageFile) {
    final titleController = TextEditingController(text: 'My Tracing Artwork');
    final descController = TextEditingController();
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF181B24),
          title: const Text('Publish to Showcase', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    imageFile,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Artwork Title',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Caption (materials, paper, opacity used)',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                  ),
                ),
                if (isUploading) ...[
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7))),
                ],
              ],
            ),
          ),
          actions: isUploading
              ? []
              : [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
                    onPressed: () async {
                      setDialogState(() => isUploading = true);

                      // Upload to Firebase Storage
                      final imageUrl = await StorageService.uploadDrawing(imageFile, _currentUserId);

                      // Create Firestore Post
                      final post = GalleryPost(
                        id: const Uuid().v4(),
                        authorId: _currentUserId,
                        authorName: 'Artist #${_currentUserId.hashCode.abs() % 1000}',
                        drawingImageUrl: imageUrl,
                        title: titleController.text.trim().isNotEmpty
                            ? titleController.text.trim()
                            : 'Tracing Artwork',
                        description: descController.text.trim(),
                        tags: ['pencil', 'tracecraft'],
                        createdAt: DateTime.now(),
                      );

                      await FirestoreService.createPost(post);

                      if (!mounted) return;
                      if (dialogCtx.mounted) {
                        Navigator.pop(dialogCtx);
                      }
                      _refreshPosts();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Artwork published to community gallery!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text('Publish'),
                  ),
                ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181B24),
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            tooltip: 'Open Menu',
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Row(
          children: [
            Icon(Icons.groups_rounded, color: Color(0xFF00CEC9), size: 22),
            SizedBox(width: 8),
            Text(
              'Community Showcase',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. FILTER TABS (Trending vs Latest)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _buildFilterChip('Trending 🔥', 'trending'),
                const SizedBox(width: 10),
                _buildFilterChip('Latest ✨', 'latest'),
              ],
            ),
          ),

          // 2. POSTS FEED
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
                  )
                : _posts.isEmpty
                    ? const Center(
                        child: Text(
                          'No community artworks yet. Be the first to publish!',
                          style: TextStyle(color: Colors.white60),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshPosts,
                        color: const Color(0xFF6C5CE7),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          itemCount: _posts.length,
                          itemBuilder: (context, index) {
                            final post = _posts[index];
                            return _buildPostCard(post);
                          },
                        ),
                      ),
          ),

          // 3. BOTTOM ANCHORED BANNER AD
          const BottomBannerAdWidget(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6C5CE7),
        icon: const Icon(Icons.add_photo_alternate_rounded, color: Colors.white),
        label: const Text('Share Artwork', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        onPressed: _openUploadModal,
      ),
    );
  }

  Widget _buildFilterChip(String label, String filter) {
    final isSelected = _currentFilter == filter;
    return InkWell(
      onTap: () => _onFilterChanged(filter),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C5CE7) : const Color(0xFF181B24),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFA29BFE) : Colors.white12,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(GalleryPost post) {
    final isLiked = post.likedUserIds.contains(_currentUserId);
    final dateStr = DateFormat.yMMMd().format(post.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF181B24),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF6C5CE7).withValues(alpha: 0.3),
                  child: Text(
                    post.authorName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Color(0xFFA29BFE), fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                      ),
                      Text(
                        dateStr,
                        style: const TextStyle(fontSize: 11, color: Colors.white54),
                      ),
                    ],
                  ),
                ),

                // Star Rating Summary Badge (Tap to Rate)
                InkWell(
                  onTap: () => _showRatingModal(context, post),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFB300).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          post.averageRating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                        ),
                        Text(
                          ' (${post.totalRatingsCount})',
                          style: const TextStyle(fontSize: 10, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Artwork Image
          ClipRRect(
            child: AspectRatio(
              aspectRatio: 1.2,
              child: _buildArtworkImage(post.drawingImageUrl),
            ),
          ),

          // Title & Caption
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
                if (post.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    post.description,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ],
            ),
          ),

          // Like & Rate Action Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                // Like Button
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isLiked ? const Color(0xFFFF7675) : Colors.white60,
                    size: 22,
                  ),
                  onPressed: () => _toggleLike(post),
                ),
                Text(
                  '${post.likesCount} ${post.likesCount == 1 ? 'like' : 'likes'}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600),
                ),
                const Spacer(),

                // Rate Button
                TextButton.icon(
                  onPressed: () => _showRatingModal(context, post),
                  icon: const Icon(Icons.star_outline_rounded, color: Color(0xFFFFB300), size: 18),
                  label: const Text(
                    'Rate Drawing',
                    style: TextStyle(color: Color(0xFFFFB300), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtworkImage(String urlOrPath) {
    if (urlOrPath.startsWith('http://') || urlOrPath.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: urlOrPath,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: const Color(0xFF222634)),
        errorWidget: (context, url, error) => const Center(
          child: Icon(Icons.broken_image_rounded, color: Colors.white24, size: 48),
        ),
      );
    } else {
      return Image.file(
        File(urlOrPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.image_not_supported_rounded, color: Colors.white24, size: 48),
        ),
      );
    }
  }
}
