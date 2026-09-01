import 'dart:typed_data';
import 'package:flutter/material.dart';

class MatrixConverter {
  /// Converts a Flutter Matrix4 into a plain List of 16 double values
  static List<double> matrix4ToList(Matrix4 matrix) {
    return matrix.storage.toList();
  }

  /// Converts a 16-element List of double values back into a Matrix4
  static Matrix4 listToMatrix4(List<double>? values) {
    if (values == null || values.length != 16) {
      return Matrix4.identity();
    }
    // Verify no NaNs or Infinities
    for (final v in values) {
      if (v.isNaN || v.isInfinite) {
        return Matrix4.identity();
      }
    }
    return Matrix4.fromFloat64List(Float64List.fromList(values));
  }

  /// Creates a clean identity matrix
  static Matrix4 defaultMatrix() => Matrix4.identity();

  /// Applies horizontal flip to an existing transform matrix
  static Matrix4 applyHorizontalFlip(Matrix4 current) {
    final flipped = Matrix4.copy(current);
    flipped.scaleByDouble(-1.0, 1.0, 1.0, 1.0);
    return flipped;
  }

  /// Applies vertical flip to an existing transform matrix
  static Matrix4 applyVerticalFlip(Matrix4 current) {
    final flipped = Matrix4.copy(current);
    flipped.scaleByDouble(1.0, -1.0, 1.0, 1.0);
    return flipped;
  }
}
