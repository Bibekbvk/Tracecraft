class AppConstants {
  static const String appName = 'TraceCraft';
  static const String appTagline = 'AR Camera Lucida Photo Tracing Assistant';
  static const String appVersion = '1.0.0';

  // Hive Box Names
  static const String settingsBox = 'settings_box';
  static const String sessionsBox = 'sessions_box';
  static const String streakBox = 'streak_box';
  static const String favoritesBox = 'favorites_box';

  // Keys
  static const String pexelsApiKeyKey = 'pexels_api_key';
  static const String pixabayApiKeyKey = 'pixabay_api_key';

  // Demo API Keys (users can also provide their own free keys in settings)
  // Pexels & Pixabay allow free keys for developers.
  static const String defaultPexelsKey = 'iK98k5sP4xGgHlXo49gK8sM7aN2bV5cW';
  static const String defaultPixabayKey = '49283741-9a7c3b4e5f6d7a8b9c0d1e2f3';

  // Default Session Values
  static const double defaultOpacity = 0.45;
  static const double minOpacity = 0.05;
  static const double maxOpacity = 0.95;
  static const int defaultGridDivisions = 3;

  // Categories
  static const List<String> imageCategories = [
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
}
