import 'package:flutter/material.dart';
import 'package:trace_craft/core/constants/app_colors.dart';
import 'package:trace_craft/core/services/firestore_service.dart';
import 'package:trace_craft/features/gallery/domain/models/gallery_post.dart';
import 'package:trace_craft/features/gallery/presentation/widgets/gallery_card.dart';
import 'package:trace_craft/features/gallery/presentation/widgets/upload_artwork_sheet.dart';
import 'package:trace_craft/features/settings_drawer/presentation/screens/app_drawer.dart';

class CommunityGalleryScreen extends StatefulWidget {
  const CommunityGalleryScreen({super.key});

  @override
  State<CommunityGalleryScreen> createState() => _CommunityGalleryScreenState();
}

class _CommunityGalleryScreenState extends State<CommunityGalleryScreen> {
  String _selectedFilter = 'trending'; // 'trending', 'recent', 'top_rated'
  List<GalleryPost> _posts = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    final posts = await CommunityGalleryService.getPosts(
      filter: _selectedFilter,
      searchTag: _searchController.text.trim(),
    );
    if (mounted) {
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    }
  }

  void _onLike(GalleryPost post) async {
    final updated = await CommunityGalleryService.toggleLike(post.id, 'my_user_id');
    setState(() {
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) _posts[index] = updated;
    });
  }

  void _onRate(GalleryPost post, double rating) async {
    final updated = await CommunityGalleryService.rateArtwork(post.id, 'my_user_id', rating);
    setState(() {
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) _posts[index] = updated;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rated "${post.title}" $rating stars!'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Community Showcase'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_a_photo_rounded, color: Colors.white),
        label: const Text('Share Artwork', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: AppColors.surfaceDark,
            builder: (_) => const UploadArtworkSheet(),
          );
          if (mounted) {
            _loadPosts();
          }
        },
      ),
      body: Column(
        children: [
          // Filter Tabs (Trending, Recent, Top Rated)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('Trending 🔥', 'trending'),
                const SizedBox(width: 8),
                _buildFilterChip('Recent ⏱️', 'recent'),
                const SizedBox(width: 8),
                _buildFilterChip('Top Rated ⭐', 'top_rated'),
              ],
            ),
          ),

          // Posts Feed
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _posts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.palette_outlined, size: 52, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            const Text('No artworks in this category yet', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            const Text('Be the first to share your traced drawing!', style: TextStyle(color: AppColors.textSecondary)),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: () => UploadArtworkSheet.show(context),
                              icon: const Icon(Icons.upload_rounded),
                              label: const Text('Upload Drawing'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPosts,
                        color: AppColors.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _posts.length,
                          itemBuilder: (context, index) {
                            final post = _posts[index];
                            return GalleryCard(
                              post: post,
                              onLikeToggle: () => _onLike(post),
                              onRatingSubmit: (rating) => _onRate(post, rating),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (_selectedFilter != value) {
            setState(() => _selectedFilter = value);
            _loadPosts();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryLight : AppColors.glassBorder,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
