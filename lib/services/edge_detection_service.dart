import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class EdgeFilterParams {
  final String sourcePathOrUrl;
  final double threshold;
  final bool invert;
  final String targetFilePath;

  EdgeFilterParams({
    required this.sourcePathOrUrl,
    required this.threshold,
    required this.invert,
    required this.targetFilePath,
  });
}

class EdgeDetectionService {
  /// Converts an input photo/image into a high-contrast pencil sketch outline
  /// and caches it on disk using MD5 hash so subsequent requests return instantly.
  static Future<String?> convertToLineArt({
    required String sourcePathOrUrl,
    double threshold = 0.5,
    bool invert = true,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final cacheKey = md5.convert(utf8.encode('$sourcePathOrUrl-$threshold-$invert')).toString();
      final cachedFilePath = p.join(tempDir.path, 'lineart_$cacheKey.png');

      final cachedFile = File(cachedFilePath);
      if (await cachedFile.exists() && await cachedFile.length() > 0) {
        debugPrint('EdgeDetectionService: Loaded from disk cache ($cachedFilePath)');
        return cachedFilePath;
      }

      final params = EdgeFilterParams(
        sourcePathOrUrl: sourcePathOrUrl,
        threshold: threshold,
        invert: invert,
        targetFilePath: cachedFilePath,
      );

      final resultPath = await compute(_processImageIsolate, params);
      return resultPath;
    } catch (e) {
      debugPrint('EdgeDetectionService error: $e');
      return null;
    }
  }

  static Future<String?> _processImageIsolate(EdgeFilterParams params) async {
    Uint8List? rawBytes;

    if (params.sourcePathOrUrl.startsWith('http://') || params.sourcePathOrUrl.startsWith('https://')) {
      final response = await http.get(Uri.parse(params.sourcePathOrUrl));
      if (response.statusCode == 200) {
        rawBytes = response.bodyBytes;
      }
    } else {
      final file = File(params.sourcePathOrUrl);
      if (await file.exists()) {
        rawBytes = await file.readAsBytes();
      }
    }

    if (rawBytes == null) return null;

    img.Image? original = img.decodeImage(rawBytes);
    if (original == null) return null;

    // Resize down if too high-res for speed and memory efficiency
    if (original.width > 1200 || original.height > 1200) {
      original = img.copyResize(
        original,
        width: original.width > original.height ? 1200 : null,
        height: original.height >= original.width ? 1200 : null,
      );
    }

    // Grayscale
    img.Image gray = img.grayscale(original);

    // Sobel operator
    img.Image edges = img.sobel(gray, amount: (params.threshold * 2.0).clamp(0.5, 3.0));

    // Invert to black pencil lines on white paper
    if (params.invert) {
      edges = img.invert(edges);
    }

    final encoded = img.encodePng(edges);
    final targetFile = File(params.targetFilePath);
    await targetFile.writeAsBytes(encoded);

    return targetFile.path;
  }
}
