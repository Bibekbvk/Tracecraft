import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trace_craft/models/gallery_post_model.dart';
import 'package:trace_craft/services/firestore_service.dart';

final galleryProvider = StateNotifierProvider<GalleryNotifier, List<GalleryPost>>((ref) {
  return GalleryNotifier();
});

class GalleryNotifier extends StateNotifier<List<GalleryPost>> {
  GalleryNotifier() : super([]) {
    loadPosts();
  }

  Future<void> loadPosts({String filter = 'trending'}) async {
    final posts = await FirestoreService.fetchPosts(filter: filter);
    state = posts;
  }

  Future<void> addPost(GalleryPost post) async {
    await FirestoreService.createPost(post);
    state = [post, ...state];
  }
}
