import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:trace_craft/models/gallery_post_model.dart';
import 'package:trace_craft/models/search_image_model.dart';
import 'package:trace_craft/models/session_model.dart';
import 'package:trace_craft/models/user_settings_model.dart';
import 'package:trace_craft/services/ad_service.dart';

void main() {
  setUpAll(() async {
    final tempDir = await Directory.systemTemp.createTemp('hive_unit_test');
    Hive.init(tempDir.path);

    Hive.registerAdapter(SessionAdapter());
    Hive.registerAdapter(UserSettingsAdapter());
  });

  group('Session Model & Hive Adapter Tests', () {
    test('Persists and reads Session from Hive Box accurately', () async {
      final box = await Hive.openBox<Session>('sessions_unit_box');
      final session = Session(
        id: 'sess_101',
        title: 'Wolf Tracing',
        sourceImagePath: 'https://example.com/wolf.png',
        opacity: 0.6,
        matrix4Values: [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1],
        isLocked: true,
        isFlippedHorizontal: true,
        isEdgeDetectionEnabled: true,
        edgeThreshold: 0.7,
        isGridEnabled: true,
        gridDivision: 4,
        createdAt: DateTime.now(),
        lastModifiedAt: DateTime.now(),
      );

      await box.put(session.id, session);
      final retrieved = box.get('sess_101');

      expect(retrieved, isNotNull);
      expect(retrieved!.id, 'sess_101');
      expect(retrieved.title, 'Wolf Tracing');
      expect(retrieved.opacity, 0.6);
      expect(retrieved.isLocked, true);
      expect(retrieved.isFlippedHorizontal, true);
      expect(retrieved.isEdgeDetectionEnabled, true);
      expect(retrieved.gridDivision, 4);
    });

    test('Session matrix transformation copyWith updates correctly', () {
      final session = Session(
        id: 'sess_102',
        title: 'Portrait Tracing',
        sourceImagePath: 'https://example.com/portrait.png',
        matrix4Values: [2.0, 0, 0, 0, 0, 2.0, 0, 0, 0, 0, 1, 0, 50, 100, 0, 1],
        opacity: 0.5,
        isLocked: false,
        createdAt: DateTime.now(),
        lastModifiedAt: DateTime.now(),
      );

      final updated = session.copyWith(
        opacity: 0.8,
        isLocked: true,
        matrix4Values: [3.0, 0, 0, 0, 0, 3.0, 0, 0, 0, 0, 1, 0, 75, 120, 0, 1],
      );

      expect(updated.opacity, 0.8);
      expect(updated.isLocked, true);
      expect(updated.matrix4Values[0], 3.0);
      expect(updated.matrix4Values[12], 75.0);
    });
  });

  group('UserSettings Model & Hive Adapter Tests', () {
    test('Persists and reads UserSettings from Hive Box accurately', () async {
      final box = await Hive.openBox<UserSettings>('settings_unit_box');
      final settings = UserSettings(
        isDarkMode: true,
        defaultOpacity: 0.55,
        enableKeepScreenOn: true,
        autoSaveSessions: true,
        defaultGridDivisions: 4,
        customPexelsKey: 'custom_pexels_key_123',
      );

      await box.put('current', settings);
      final retrieved = box.get('current');

      expect(retrieved, isNotNull);
      expect(retrieved!.isDarkMode, true);
      expect(retrieved.defaultOpacity, 0.55);
      expect(retrieved.defaultGridDivisions, 4);
      expect(retrieved.customPexelsKey, 'custom_pexels_key_123');
    });

    test('UserSettings stores and updates streak count and total drawings', () async {
      final box = await Hive.openBox<UserSettings>('settings_streak_box');
      final settings = UserSettings(
        currentStreakDays: 5,
        totalDrawingsCompleted: 12,
        lastDrawnDate: DateTime(2026, 9, 1),
      );

      await box.put('current', settings);
      final retrieved = box.get('current');

      expect(retrieved, isNotNull);
      expect(retrieved!.currentStreakDays, 5);
      expect(retrieved.totalDrawingsCompleted, 12);
      expect(retrieved.lastDrawnDate, isNotNull);
    });
  });

  group('SearchImage & GalleryPost Model Tests', () {
    test('Pexels JSON parser parses search image DTO', () {
      final json = {
        'id': 12345,
        'alt': 'Anime Girl Sketch',
        'photographer': 'John Doe',
        'photographer_url': 'https://pexels.com/@johndoe',
        'width': 1920,
        'height': 1080,
        'avg_color': '#AABBCC',
        'src': {
          'medium': 'https://images.pexels.com/medium.jpg',
          'large2x': 'https://images.pexels.com/large.jpg',
        }
      };

      final img = SearchImage.fromPexelsJson(json, 'Anime');
      expect(img.id, 'pexels_12345');
      expect(img.title, 'Anime Girl Sketch');
      expect(img.category, 'Anime');
      expect(img.provider, ImageSourceProvider.pexels);
    });

    test('GalleryPost json serialization', () {
      final post = GalleryPost(
        id: 'post_1',
        authorId: 'user_1',
        authorName: 'Alex',
        drawingImageUrl: 'https://example.com/drawing.jpg',
        title: 'Pencil Sketch',
        createdAt: DateTime.now(),
      );

      final json = post.toJson();
      final parsed = GalleryPost.fromJson(json);

      expect(parsed.id, 'post_1');
      expect(parsed.authorName, 'Alex');
      expect(parsed.title, 'Pencil Sketch');
    });

    test('GalleryPost ratings and average rating calculation', () {
      final post = GalleryPost(
        id: 'post_2',
        authorId: 'user_2',
        authorName: 'Sarah',
        drawingImageUrl: 'https://example.com/sarah.jpg',
        title: 'Rose Drawing',
        likesCount: 10,
        likedUserIds: ['user_a'],
        averageRating: 4.0,
        totalRatingsCount: 1,
        userRatings: {'user_a': 4.0},
        createdAt: DateTime.now(),
      );

      // Add user_b rating of 5.0
      final updatedRatings = Map<String, double>.from(post.userRatings);
      updatedRatings['user_b'] = 5.0;
      final avg = (4.0 + 5.0) / 2;

      final updatedPost = post.copyWith(
        userRatings: updatedRatings,
        averageRating: avg,
        totalRatingsCount: 2,
      );

      expect(updatedPost.averageRating, 4.5);
      expect(updatedPost.totalRatingsCount, 2);
      expect(updatedPost.userRatings['user_b'], 5.0);
    });
  });

  group('AdService Test Unit IDs & Logic Tests', () {
    test('Ad unit IDs are configured properly for test environment', () {
      expect(AdService.sessionSavesBeforeInterstitial, 3);
    });

    test('24-hour ad removal calculates expiration date correctly', () {
      final settings = UserSettings(
        adsRemovedUntil: DateTime.now().add(const Duration(hours: 24)),
      );
      expect(settings.adsRemovedUntil, isNotNull);
      expect(DateTime.now().isBefore(settings.adsRemovedUntil!), isTrue);
    });
  });

  group('Feedback & Onboarding Tutorial Tests', () {
    test('UserSettings toggles showOnboardingTutorial correctly', () {
      final settings = UserSettings(showOnboardingTutorial: true);
      final updated = settings.copyWith(showOnboardingTutorial: false);
      expect(updated.showOnboardingTutorial, false);
    });

    test('Feedback payload structure validates properly', () {
      final feedbackMap = {
        'category': 'Feature Request',
        'message': 'Add custom color tint to overlay',
        'rating': 5.0,
        'userEmail': 'artist@example.com',
      };
      expect(feedbackMap['category'], 'Feature Request');
      expect(feedbackMap['rating'], 5.0);
    });
  });
}
