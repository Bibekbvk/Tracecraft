import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:trace_craft/models/search_image_model.dart';
import 'package:trace_craft/services/database_service.dart';
import 'package:trace_craft/services/security_service.dart';

class ImageSearchService {
  // Obfuscated Pexels Key Shield (de-obfuscated dynamically at runtime)
  static final String _obfuscatedPexelsKey = SecurityService.obfuscateKey('iK98k5sP4xGgHlXo49gK8sM7aN2bV5cW');

  // Categories list
  static const List<String> categories = [
    'All',
    'Portraits',
    'Anime & Cartoons',
    'Animals & Wildlife',
    'Flowers & Botanical',
    'Landscapes & Nature',
    'Architecture',
    'Vehicles & Cars',
    'Tattoo & Line Art',
    'Easy for Beginners',
  ];

  // High quality curated sketches for immediate offline availability
  static final List<SearchImage> curatedFallbackImages = [
    SearchImage(
      id: 'curated_portrait_1',
      title: 'Minimalist Side Profile Portrait',
      previewUrl: 'https://images.pexels.com/photos/1858175/pexels-photo-1858175.jpeg?auto=compress&cs=tinysrgb&w=400',
      originalUrl: 'https://images.pexels.com/photos/1858175/pexels-photo-1858175.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
      photographer: 'Amina Filkins',
      photographerUrl: 'https://www.pexels.com/@amina-filkins/',
      width: 1080,
      height: 1350,
      category: 'Portraits',
      provider: ImageSourceProvider.pexels,
      tags: ['portrait', 'face', 'expressive', 'eyes'],
    ),
    SearchImage(
      id: 'curated_portrait_2',
      title: 'Dramatic High-Contrast Silhouette',
      previewUrl: 'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=400',
      originalUrl: 'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
      photographer: 'Pixabay',
      photographerUrl: 'https://www.pexels.com/@pixabay/',
      width: 1080,
      height: 1440,
      category: 'Portraits',
      provider: ImageSourceProvider.pexels,
      tags: ['man', 'lighting', 'contrast', 'proportions'],
    ),
    SearchImage(
      id: 'curated_animal_1',
      title: 'Majestic Roaring Lion',
      previewUrl: 'https://images.pexels.com/photos/247502/pexels-photo-247502.jpeg?auto=compress&cs=tinysrgb&w=400',
      originalUrl: 'https://images.pexels.com/photos/247502/pexels-photo-247502.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
      photographer: 'Pixabay Wildlife',
      photographerUrl: 'https://www.pexels.com/@pixabay/',
      width: 1200,
      height: 800,
      category: 'Animals & Wildlife',
      provider: ImageSourceProvider.pexels,
      tags: ['lion', 'wildlife', 'mane', 'animal'],
    ),
    SearchImage(
      id: 'curated_animal_2',
      title: 'Golden Retriever Puppy Face',
      previewUrl: 'https://images.pexels.com/photos/1108099/pexels-photo-1108099.jpeg?auto=compress&cs=tinysrgb&w=400',
      originalUrl: 'https://images.pexels.com/photos/1108099/pexels-photo-1108099.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
      photographer: 'Chewy',
      photographerUrl: 'https://www.pexels.com/@chewy/',
      width: 1080,
      height: 1080,
      category: 'Animals & Wildlife',
      provider: ImageSourceProvider.pexels,
      tags: ['dog', 'puppy', 'cute', 'pet'],
    ),
    SearchImage(
      id: 'curated_flower_1',
      title: 'Blooming Red Rose Petals',
      previewUrl: 'https://images.pexels.com/photos/56866/garden-rose-red-pink-56866.jpeg?auto=compress&cs=tinysrgb&w=400',
      originalUrl: 'https://images.pexels.com/photos/56866/garden-rose-red-pink-56866.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
      photographer: 'Pixabay Flora',
      photographerUrl: 'https://www.pexels.com/@pixabay/',
      width: 1080,
      height: 1080,
      category: 'Flowers & Botanical',
      provider: ImageSourceProvider.pexels,
      tags: ['rose', 'flower', 'botanical', 'petals'],
    ),
    SearchImage(
      id: 'curated_flower_2',
      title: 'Sunflower Head Symmetry',
      previewUrl: 'https://images.pexels.com/photos/46216/sunflower-flowers-bright-yellow-46216.jpeg?auto=compress&cs=tinysrgb&w=400',
      originalUrl: 'https://images.pexels.com/photos/46216/sunflower-flowers-bright-yellow-46216.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
      photographer: 'Pixabay Nature',
      photographerUrl: 'https://www.pexels.com/@pixabay/',
      width: 1080,
      height: 1080,
      category: 'Flowers & Botanical',
      provider: ImageSourceProvider.pexels,
      tags: ['sunflower', 'yellow', 'symmetry'],
    ),
    SearchImage(
      id: 'curated_arch_1',
      title: 'Eiffel Tower Perspective',
      previewUrl: 'https://images.pexels.com/photos/532826/pexels-photo-532826.jpeg?auto=compress&cs=tinysrgb&w=400',
      originalUrl: 'https://images.pexels.com/photos/532826/pexels-photo-532826.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
      photographer: 'Thorsten technoman',
      photographerUrl: 'https://www.pexels.com/@technoman/',
      width: 1080,
      height: 1600,
      category: 'Architecture',
      provider: ImageSourceProvider.pexels,
      tags: ['paris', 'tower', 'architecture', 'lines'],
    ),
    SearchImage(
      id: 'curated_vehicle_1',
      title: 'Vintage Classic Sports Car',
      previewUrl: 'https://images.pexels.com/photos/248687/pexels-photo-248687.jpeg?auto=compress&cs=tinysrgb&w=400',
      originalUrl: 'https://images.pexels.com/photos/248687/pexels-photo-248687.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
      photographer: 'Pixabay Auto',
      photographerUrl: 'https://www.pexels.com/@pixabay/',
      width: 1200,
      height: 800,
      category: 'Vehicles & Cars',
      provider: ImageSourceProvider.pexels,
      tags: ['car', 'vintage', 'automobile', 'proportions'],
    ),
    SearchImage(
      id: 'curated_easy_1',
      title: 'Coffee Cup Outline',
      previewUrl: 'https://images.pexels.com/photos/312418/pexels-photo-312418.jpeg?auto=compress&cs=tinysrgb&w=400',
      originalUrl: 'https://images.pexels.com/photos/312418/pexels-photo-312418.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
      photographer: 'Pixabay Still Life',
      photographerUrl: 'https://www.pexels.com/@pixabay/',
      width: 1080,
      height: 1080,
      category: 'Easy for Beginners',
      provider: ImageSourceProvider.pexels,
      tags: ['cup', 'coffee', 'basic shapes', 'beginner'],
    ),
  ];

  /// Searches reference images using Pexels API with rate limiting, MITM prevention, & secure headers
  static Future<List<SearchImage>> searchImages({
    String query = '',
    String category = 'All',
    int page = 1,
    int perPage = 20,
  }) async {
    // 1. Rate Limiting Check (Anti-DDoS / Anti-Abuse)
    if (!SecurityService.checkRateLimit('image_search', maxRequests: 30, window: const Duration(minutes: 1))) {
      debugPrint('🛡️ [Security] Image search rate limit triggered. Serving local curated results.');
      return _filterCuratedFallback(query, category);
    }

    // 2. Input Sanitization (Anti-XSS & Anti-Injection)
    final sanitizedQuery = SecurityService.sanitizeText(query, maxLength: 80);
    final settings = DatabaseService.getUserSettings();

    // 3. De-obfuscate API Key
    final rawKey = settings.customPexelsKey.isNotEmpty
        ? settings.customPexelsKey
        : SecurityService.deobfuscateKey(_obfuscatedPexelsKey);

    final effectiveQuery = sanitizedQuery.isNotEmpty
        ? sanitizedQuery
        : (category == 'All' ? 'drawing sketch art' : '$category sketch');

    List<SearchImage> results = [];

    // 4. Secure HTTPS Request with MITM Protection & Security Headers
    try {
      final endpoint = SecurityService.enforceHttps(
        'https://api.pexels.com/v1/search?query=${Uri.encodeComponent(effectiveQuery)}&page=$page&per_page=$perPage',
      );
      final pexelsUrl = Uri.parse(endpoint);

      final headers = SecurityService.getSecureHeaders(apiKey: rawKey);

      final response = await http.get(pexelsUrl, headers: headers).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final photos = (data['photos'] as List?) ?? [];
        results.addAll(photos.map((item) => SearchImage.fromPexelsJson(item, category)));
      }
    } catch (e) {
      debugPrint('ImageSearchService Pexels API secure request note: $e');
    }

    // Augment / fallback with curated collection
    final curatedMatches = _filterCuratedFallback(sanitizedQuery, category);

    // Combine & deduplicate
    final combined = [...results, ...curatedMatches];
    final seen = <String>{};
    return combined.where((item) => seen.add(item.id)).toList();
  }

  static List<SearchImage> _filterCuratedFallback(String query, String category) {
    return curatedFallbackImages.where((img) {
      if (category != 'All' && img.category.toLowerCase() != category.toLowerCase()) {
        return false;
      }
      if (query.trim().isNotEmpty) {
        final q = query.toLowerCase();
        return img.title.toLowerCase().contains(q) ||
            img.tags.any((t) => t.toLowerCase().contains(q)) ||
            img.category.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }
}
