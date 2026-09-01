import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trace_craft/models/search_image_model.dart';
import 'package:trace_craft/services/image_search_service.dart';

class ImageSearchState {
  final List<SearchImage> images;
  final bool isLoading;
  final String category;
  final String query;

  ImageSearchState({
    this.images = const [],
    this.isLoading = false,
    this.category = 'All',
    this.query = '',
  });

  ImageSearchState copyWith({
    List<SearchImage>? images,
    bool? isLoading,
    String? category,
    String? query,
  }) {
    return ImageSearchState(
      images: images ?? this.images,
      isLoading: isLoading ?? this.isLoading,
      category: category ?? this.category,
      query: query ?? this.query,
    );
  }
}

final imageSearchProvider = StateNotifierProvider<ImageSearchNotifier, ImageSearchState>((ref) {
  return ImageSearchNotifier();
});

class ImageSearchNotifier extends StateNotifier<ImageSearchState> {
  ImageSearchNotifier() : super(ImageSearchState());

  Future<void> search({String? category, String? query}) async {
    state = state.copyWith(
      isLoading: true,
      category: category ?? state.category,
      query: query ?? state.query,
    );

    final results = await ImageSearchService.searchImages(
      category: state.category,
      query: state.query,
    );

    state = state.copyWith(images: results, isLoading: false);
  }
}
