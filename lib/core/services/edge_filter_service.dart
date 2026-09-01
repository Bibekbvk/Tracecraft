import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class EdgeFilterParams {
  final String sourcePathOrUrl;
  final double threshold; // 0.1 to 1.0 (sensitivity)
  final bool invert; // true = black lines on white/transparent
  final String targetFilePath;

  EdgeFilterParams({
    required this.sourcePathOrUrl,
    required this.threshold,
    required this.invert,
    required this.targetFilePath,
  });
}

class EdgeFilterService {
  /// Converts an image into a crisp pencil sketch / line art outline
  /// using an isolate for zero UI stutter.
  static Future<String?> generateLineArt({
    required String sourcePathOrUrl,
    double threshold = 0.5,
    bool invert = true,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filename = 'edge_${DateTime.now().millisecondsSinceEpoch}.png';
      final targetPath = p.join(tempDir.path, filename);

      final params = EdgeFilterParams(
        sourcePathOrUrl: sourcePathOrUrl,
        threshold: threshold,
        invert: invert,
        targetFilePath: targetPath,
      );

      final resultPath = await compute(_processImageIsolate, params);
      return resultPath;
    } catch (e) {
      debugPrint('Error generating line art: $e');
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

    // Resize if too large to ensure high performance
    if (original.width > 1200 || original.height > 1200) {
      original = img.copyResize(
        original,
        width: original.width > original.height ? 1200 : null,
        height: original.height >= original.width ? 1200 : null,
      );
    }

    // Convert to grayscale
    img.Image gray = img.grayscale(original);

    // Apply Sobel edge detection
    img.Image edges = img.sobel(gray, amount: (params.threshold * 2.0).clamp(0.5, 3.0));

    // Invert so edges are dark pencil strokes on a clear/white background
    if (params.invert) {
      edges = img.invert(edges);
    }

    // Save output PNG
    final encoded = img.encodePng(edges);
    final targetFile = File(params.targetFilePath);
    await targetFile.writeAsBytes(encoded);

    return targetFile.path;
  }
}
