enum ImageSourceProvider { pexels, pixabay, localGallery, curated }

class SearchImage {
  final String id;
  final String title;
  final String previewUrl;
  final String originalUrl;
  final String photographer;
  final String photographerUrl;
  final int width;
  final int height;
  final String category;
  final ImageSourceProvider provider;
  final String? averageColorHex;
  final List<String> tags;

  SearchImage({
    required this.id,
    this.title = '',
    required this.previewUrl,
    required this.originalUrl,
    required this.photographer,
    required this.photographerUrl,
    required this.width,
    required this.height,
    required this.category,
    required this.provider,
    this.averageColorHex,
    this.tags = const [],
  });

  factory SearchImage.fromPexelsJson(Map<String, dynamic> json, String category) {
    final src = json['src'] as Map<String, dynamic>? ?? {};
    return SearchImage(
      id: 'pexels_${json['id']}',
      title: json['alt'] ?? 'Pexels Artwork',
      previewUrl: src['medium'] ?? src['small'] ?? '',
      originalUrl: src['large2x'] ?? src['large'] ?? src['original'] ?? '',
      photographer: json['photographer'] ?? 'Pexels Contributor',
      photographerUrl: json['photographer_url'] ?? '',
      width: json['width'] ?? 1080,
      height: json['height'] ?? 1920,
      category: category,
      provider: ImageSourceProvider.pexels,
      averageColorHex: json['avg_color'],
      tags: [],
    );
  }

  factory SearchImage.fromPixabayJson(Map<String, dynamic> json, String category) {
    return SearchImage(
      id: 'pixabay_${json['id']}',
      title: json['tags'] != null ? json['tags'].toString().split(',').first.trim() : 'Pixabay Artwork',
      previewUrl: json['webformatURL'] ?? json['previewURL'] ?? '',
      originalUrl: json['largeImageURL'] ?? json['webformatURL'] ?? '',
      photographer: json['user'] ?? 'Pixabay Artist',
      photographerUrl: json['pageURL'] ?? '',
      width: json['imageWidth'] ?? 1080,
      height: json['imageHeight'] ?? 1920,
      category: category,
      provider: ImageSourceProvider.pixabay,
      tags: (json['tags'] as String?)?.split(',').map((e) => e.trim()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'previewUrl': previewUrl,
      'originalUrl': originalUrl,
      'photographer': photographer,
      'photographerUrl': photographerUrl,
      'width': width,
      'height': height,
      'category': category,
      'provider': provider.name,
      'averageColorHex': averageColorHex,
      'tags': tags,
    };
  }

  factory SearchImage.fromJson(Map<String, dynamic> json) {
    return SearchImage(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      previewUrl: json['previewUrl'] ?? '',
      originalUrl: json['originalUrl'] ?? '',
      photographer: json['photographer'] ?? '',
      photographerUrl: json['photographerUrl'] ?? '',
      width: json['width'] ?? 1080,
      height: json['height'] ?? 1920,
      category: json['category'] ?? 'All',
      provider: ImageSourceProvider.values.firstWhere(
        (e) => e.name == json['provider'],
        orElse: () => ImageSourceProvider.curated,
      ),
      averageColorHex: json['averageColorHex'],
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}
