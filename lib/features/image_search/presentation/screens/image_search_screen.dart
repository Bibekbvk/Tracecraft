import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trace_craft/core/constants/app_colors.dart';
import 'package:trace_craft/features/image_search/presentation/controllers/image_search_controller.dart';
import 'package:trace_craft/features/image_search/presentation/widgets/image_category_bar.dart';
import 'package:trace_craft/features/image_search/presentation/widgets/image_preview_sheet.dart';
import 'package:trace_craft/features/image_search/presentation/widgets/search_image_tile.dart';
import 'package:trace_craft/features/settings_drawer/presentation/screens/app_drawer.dart';
import 'package:trace_craft/features/tracing/presentation/screens/tracing_screen.dart';

class ImageSearchScreen extends ConsumerStatefulWidget {
  const ImageSearchScreen({super.key});

  @override
  ConsumerState<ImageSearchScreen> createState() => _ImageSearchScreenState();
}

class _ImageSearchScreenState extends ConsumerState<ImageSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickCustomImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TracingScreen(
            imagePathOrUrl: file.path,
            title: 'Custom Photo Tracing',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(imageSearchControllerProvider);
    final notifier = ref.read(imageSearchControllerProvider.notifier);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Discover & Search'),
        actions: [
          IconButton(
            tooltip: 'Import from Gallery',
            icon: const Icon(Icons.add_photo_alternate_rounded, color: AppColors.accentCyan),
            onPressed: _pickCustomImage,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (val) => notifier.search(val),
              decoration: InputDecoration(
                hintText: 'Search anime, portrait, animal, flowers...',
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryLight),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          notifier.search('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceDark,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.glassBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Categories Bar
          ImageCategoryBar(
            selectedCategory: state.selectedCategory,
            onCategorySelected: (cat) {
              _searchController.clear();
              notifier.setCategory(cat);
            },
          ),
          const SizedBox(height: 12),

          // Grid View
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 16),
                        Text('Curating reference sketches...', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : state.images.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.image_not_supported_outlined, size: 48, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            const Text('No reference images found', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            const Text('Try searching with different keywords', style: TextStyle(color: AppColors.textSecondary)),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: () => notifier.fetchImages(category: 'All', query: ''),
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Reset Category'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => notifier.fetchImages(),
                        color: AppColors.primary,
                        child: MasonryGridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: state.images.length,
                          itemBuilder: (context, index) {
                            final image = state.images[index];
                            final height = (index % 3 == 0) ? 240.0 : (index % 2 == 0 ? 190.0 : 210.0);
                            return SizedBox(
                              height: height,
                              child: SearchImageTile(
                                image: image,
                                onTap: () => ImagePreviewSheet.show(context, image),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
