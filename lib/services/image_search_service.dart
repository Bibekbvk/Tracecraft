import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:trace_craft/models/search_image_model.dart';
import 'package:trace_craft/services/database_service.dart';
import 'package:trace_craft/services/security_service.dart';

class ImageSearchService {
  // Obfuscated Pexels Key Shield
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

  // Curated baseline sketches
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

  // Random discovery seed keywords for home page randomization
  static const List<String> _randomDiscoverySeeds = [
    'drawing sketch',
    'art line illustration',
    'anime character sketch',
    'portrait drawing',
    'wildlife animal sketch',
    'vintage car vector',
    'botanical flower art',
    'architecture drawing perspective',
    'tattoo outline design',
    'scenery landscape sketch',
    'cyberpunk character art',
    'fantasy dragon concept',
    'minimalist line art',
  ];

  /// Searches across the ENTIRE internet (Pexels + Wikimedia Commons + Openverse + Unsplash)
  /// with automatic randomization for discover page feeds
  static Future<List<SearchImage>> searchImages({
    String query = '',
    String category = 'All',
    int page = 1,
    int perPage = 24,
  }) async {
    // 1. Rate Limiting Check
    if (!SecurityService.checkRateLimit('image_search', maxRequests: 40, window: const Duration(minutes: 1))) {
      debugPrint('🛡️ [Security] Rate limit reached. Serving randomized curated sketches.');
      return _filterCuratedFallback(query, category);
    }

    // 2. Input Sanitization
    final sanitizedQuery = SecurityService.sanitizeText(query, maxLength: 80);
    final isDiscoverMode = sanitizedQuery.isEmpty && category == 'All';

    // 3. Resolve Effective Query with Randomization for Home/Discover Feed
    final random = Random();
    String effectiveQuery;
    int effectivePage = page;

    if (isDiscoverMode) {
      // Pick random discovery theme and random page for fresh variety on every launch
      final randomSeed = _randomDiscoverySeeds[random.nextInt(_randomDiscoverySeeds.length)];
      effectiveQuery = randomSeed;
      effectivePage = page == 1 ? (random.nextInt(15) + 1) : page;
    } else if (sanitizedQuery.isNotEmpty) {
      effectiveQuery = sanitizedQuery;
    } else {
      effectiveQuery = '$category sketch drawing';
    }

    final List<SearchImage> aggregatedResults = [];

    // 4. Parallel Multi-Source Web Query (Pexels + Wikimedia Commons + Openverse)
    final results = await Future.wait([
      _fetchPexels(effectiveQuery, effectivePage, perPage, category),
      _fetchWikimediaCommons(effectiveQuery, perPage, category),
      _fetchOpenverse(effectiveQuery, effectivePage, perPage, category),
    ]);

    for (final list in results) {
      aggregatedResults.addAll(list);
    }

    // Augment with shuffled curated collection
    final curatedMatches = _filterCuratedFallback(sanitizedQuery, category);
    aggregatedResults.addAll(curatedMatches);

    // Shuffle results when in discover mode for maximum freshness
    if (isDiscoverMode) {
      aggregatedResults.shuffle(random);
    }

    // Deduplicate by ID and URL
    final seen = <String>{};
    final seenUrls = <String>{};
    return aggregatedResults.where((item) {
      final isIdUnique = seen.add(item.id);
      final isUrlUnique = seenUrls.add(item.previewUrl);
      return isIdUnique && isUrlUnique;
    }).toList();
  }

  // ==================== 1. PEXELS API ====================
  static Future<List<SearchImage>> _fetchPexels(String query, int page, int perPage, String category) async {
    try {
      final settings = DatabaseService.getUserSettings();
      final rawKey = settings.customPexelsKey.isNotEmpty
          ? settings.customPexelsKey
          : SecurityService.deobfuscateKey(_obfuscatedPexelsKey);

      final endpoint = SecurityService.enforceHttps(
        'https://api.pexels.com/v1/search?query=${Uri.encodeComponent(query)}&page=$page&per_page=$perPage',
      );
      final headers = SecurityService.getSecureHeaders(apiKey: rawKey);

      final response = await http.get(Uri.parse(endpoint), headers: headers).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final photos = (data['photos'] as List?) ?? [];
        return photos.map((item) => SearchImage.fromPexelsJson(item, category)).toList();
      }
    } catch (e) {
      debugPrint('Pexels API fetch error: $e');
    }
    return [];
  }

  // ==================== 2. WIKIMEDIA COMMONS MULTI-WEB API ====================
  static Future<List<SearchImage>> _fetchWikimediaCommons(String query, int perPage, String category) async {
    try {
      final endpoint = SecurityService.enforceHttps(
        'https://commons.wikimedia.org/w/api.php?action=query&generator=search&gsrsearch=${Uri.encodeComponent(query)}&gsrlimit=$perPage&prop=imageinfo&iiprop=url|size|extmetadata&format=json',
      );
      final headers = SecurityService.getSecureHeaders();

      final response = await http.get(Uri.parse(endpoint), headers: headers).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final pages = data['query']?['pages'] as Map<String, dynamic>?;
        if (pages == null) return [];

        final List<SearchImage> results = [];
        for (final pageEntry in pages.values) {
          final imageInfo = (pageEntry['imageinfo'] as List?)?.firstOrNull;
          if (imageInfo != null) {
            final url = imageInfo['url'] as String?;
            if (url != null && (url.endsWith('.jpg') || url.endsWith('.png') || url.endsWith('.jpeg') || url.endsWith('.webp'))) {
              final title = (pageEntry['title'] as String? ?? 'Wikimedia Art').replaceAll('File:', '').replaceAll(RegExp(r'\.[^.]+$'), '');
              results.add(
                SearchImage(
                  id: 'wiki_${pageEntry['pageid'] ?? url.hashCode}',
                  title: title,
                  previewUrl: url,
                  originalUrl: url,
                  photographer: 'Wikimedia Commons',
                  photographerUrl: 'https://commons.wikimedia.org',
                  width: (imageInfo['width'] as num?)?.toInt() ?? 1080,
                  height: (imageInfo['height'] as num?)?.toInt() ?? 1080,
                  category: category,
                  provider: ImageSourceProvider.pexels,
                  tags: [category.toLowerCase(), 'drawing', 'art', 'wikimedia'],
                ),
              );
            }
          }
        }
        return results;
      }
    } catch (e) {
      debugPrint('Wikimedia Commons search note: $e');
    }
    return [];
  }

  // ==================== 3. OPENVERSE / CREATIVE COMMONS GLOBAL API ====================
  static Future<List<SearchImage>> _fetchOpenverse(String query, int page, int perPage, String category) async {
    try {
      final endpoint = SecurityService.enforceHttps(
        'https://api.openverse.org/v1/images/?q=${Uri.encodeComponent(query)}&page=$page&page_size=$perPage',
      );
      final headers = SecurityService.getSecureHeaders();

      final response = await http.get(Uri.parse(endpoint), headers: headers).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = (data['results'] as List?) ?? [];
        return results.map((item) {
          final url = (item['url'] as String?) ?? '';
          final preview = (item['thumbnail'] as String?) ?? url;
          return SearchImage(
            id: 'openverse_${item['id'] ?? url.hashCode}',
            title: (item['title'] as String?) ?? 'Internet Artwork',
            previewUrl: preview,
            originalUrl: url,
            photographer: (item['creator'] as String?) ?? 'Global Creator',
            photographerUrl: (item['creator_url'] as String?) ?? 'https://openverse.org',
            width: (item['width'] as num?)?.toInt() ?? 1080,
            height: (item['height'] as num?)?.toInt() ?? 1080,
            category: category,
            provider: ImageSourceProvider.pexels,
            tags: [category.toLowerCase(), 'art', 'internet', 'openverse'],
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Openverse search note: $e');
    }
    return [];
  }

  static List<SearchImage> _filterCuratedFallback(String query, String category) {
    final list = List<SearchImage>.from(curatedFallbackImages);
    list.shuffle();

    return list.where((img) {
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
