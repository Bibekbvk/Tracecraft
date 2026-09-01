import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:trace_craft/core/constants/app_constants.dart';
import 'package:trace_craft/core/constants/curated_sketches.dart';
import 'package:trace_craft/core/database/hive_boxes.dart';
import 'package:trace_craft/features/image_search/domain/models/search_image.dart';

class ImageSearchRepository {
  /// Fetches images across Pexels, Pixabay, and Curated Offline library
  Future<List<SearchImage>> fetchImages({
    String query = '',
    String category = 'All',
    int page = 1,
    int perPage = 24,
  }) async {
    final settings = HiveDatabase.getUserSettings();
    final pexelsKey = settings.customPexelsKey.isNotEmpty
        ? settings.customPexelsKey
        : AppConstants.defaultPexelsKey;

    final effectiveQuery = query.trim().isNotEmpty
        ? query.trim()
        : (category == 'All' ? 'drawing sketch art' : '$category sketch');

    List<SearchImage> results = [];

    // 1. Try Pexels API
    try {
      final pexelsUrl = Uri.parse(
        'https://api.pexels.com/v1/search?query=${Uri.encodeComponent(effectiveQuery)}&page=$page&per_page=$perPage',
      );
      final response = await http.get(
        pexelsUrl,
        headers: {'Authorization': pexelsKey},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final photos = (data['photos'] as List?) ?? [];
        results.addAll(photos.map((item) => SearchImage.fromPexelsJson(item, category)));
      }
    } catch (e) {
      debugPrint('Pexels API note: $e');
    }

    // 2. Try Pixabay API if results are few
    if (results.length < 10) {
      try {
        final pixabayKey = settings.customPixabayKey.isNotEmpty
            ? settings.customPixabayKey
            : AppConstants.defaultPixabayKey;
        final pixabayUrl = Uri.parse(
          'https://pixabay.com/api/?key=$pixabayKey&q=${Uri.encodeComponent(effectiveQuery)}&image_type=photo&per_page=$perPage&page=$page',
        );
        final response = await http.get(pixabayUrl).timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final hits = (data['hits'] as List?) ?? [];
          results.addAll(hits.map((item) => SearchImage.fromPixabayJson(item, category)));
        }
      } catch (e) {
        debugPrint('Pixabay API note: $e');
      }
    }

    // 3. Fallback / Augment with Curated Sketches for instant, guaranteed offline experience
    final curatedMatches = CuratedSketches.items.where((img) {
      if (category != 'All' && img.category.toLowerCase() != category.toLowerCase()) {
        return false;
      }
      if (query.trim().isNotEmpty) {
        final q = query.toLowerCase();
        final inTitle = img.title.toLowerCase().contains(q);
        final inTags = img.tags.any((t) => t.toLowerCase().contains(q));
        final inCat = img.category.toLowerCase().contains(q);
        return inTitle || inTags || inCat;
      }
      return true;
    }).toList();

    // Deduplicate by ID
    final combined = [...curatedMatches, ...results];
    final seen = <String>{};
    final uniqueResults = combined.where((item) => seen.add(item.id)).toList();

    return uniqueResults;
  }
}
