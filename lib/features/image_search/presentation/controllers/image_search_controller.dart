import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trace_craft/features/image_search/data/pexels_pixabay_repository.dart';
import 'package:trace_craft/features/image_search/domain/models/search_image.dart';

final imageSearchRepositoryProvider = Provider<ImageSearchRepository>((ref) {
  return ImageSearchRepository();
});

class ImageSearchState {
  final List<SearchImage> images;
  final bool isLoading;
  final String selectedCategory;
  final String searchQuery;
  final String? errorMessage;

  ImageSearchState({
    this.images = const [],
    this.isLoading = false,
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.errorMessage,
  });

  ImageSearchState copyWith({
    List<SearchImage>? images,
    bool? isLoading,
    String? selectedCategory,
    String? searchQuery,
    String? errorMessage,
  }) {
    return ImageSearchState(
      images: images ?? this.images,
      isLoading: isLoading ?? this.isLoading,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }
}

final imageSearchControllerProvider =
    StateNotifierProvider<ImageSearchController, ImageSearchState>((ref) {
  final repo = ref.watch(imageSearchRepositoryProvider);
  return ImageSearchController(repo);
});

class ImageSearchController extends StateNotifier<ImageSearchState> {
  final ImageSearchRepository _repository;

  ImageSearchController(this._repository) : super(ImageSearchState()) {
    fetchImages();
  }

  Future<void> fetchImages({String? category, String? query}) async {
    final cat = category ?? state.selectedCategory;
    final q = query ?? state.searchQuery;

    state = state.copyWith(isLoading: true, selectedCategory: cat, searchQuery: q, errorMessage: null);

    try {
      final results = await _repository.fetchImages(
        category: cat,
        query: q,
      );
      state = state.copyWith(images: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to load images: $e');
    }
  }

  void setCategory(String category) {
    if (state.selectedCategory == category) return;
    fetchImages(category: category, query: '');
  }

  void search(String query) {
    fetchImages(query: query);
  }
}
