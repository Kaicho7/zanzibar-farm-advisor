// lib/services/tflite_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:convert';

import '../models/prediction.dart';
import '../utils/constants.dart';

class TFLiteService {
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  /// Load model and labels from assets
  Future<void> load() async {
    try {
      // Load labels
      final labelData = await rootBundle.loadString(kLabelsPath);
      final decoded = jsonDecode(labelData);
      if (decoded is List) {
        _labels = List<String>.from(decoded);
      } else if (decoded is Map) {
        // Support {"0": "Apple___Scab", "1": ...} format
        final keys = decoded.keys.toList()
          ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
        _labels = keys.map((k) => decoded[k] as String).toList();
      }

      // Load interpreter
      _interpreter = await Interpreter.fromAsset(kModelPath);
      _isLoaded = true;
    } catch (e) {
      _isLoaded = false;
      rethrow;
    }
  }

  /// Run inference on an image file
  Future<AnalysisResult> analyse(File imageFile) async {
    if (!_isLoaded || _interpreter == null) {
      throw StateError('Model not loaded — call load() first.');
    }

    final stopwatch = Stopwatch()..start();

    // Load and preprocess image
    final bytes = await imageFile.readAsBytes();
    final rawImage = img.decodeImage(bytes);
    if (rawImage == null) throw Exception('Could not decode image.');

    final input = _preprocess(rawImage);
    final output = _runInference(input);

    stopwatch.stop();

    final predictions = _buildPredictions(output);

    return AnalysisResult(
      predictions: predictions,
      analysisTime: stopwatch.elapsed,
      timestamp: DateTime.now(),
    );
  }

  /// Preprocess: resize to 224x224, normalise to [0,1]
  List<List<List<List<double>>>> _preprocess(img.Image image) {
    final resized = img.copyResize(
      image,
      width: kInputImageSize,
      height: kInputImageSize,
      interpolation: img.Interpolation.linear,
    );

    // Shape: [1, 224, 224, 3]
    final input = List.generate(
      1,
      (_) => List.generate(
        kInputImageSize,
        (y) => List.generate(
          kInputImageSize,
          (x) {
            final pixel = resized.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );
    return input;
  }

  List<double> _runInference(List<List<List<List<double>>>> input) {
    final numClasses = _labels.length;
    final output = [List<double>.filled(numClasses, 0)];
    _interpreter!.run(input, output);
    return output[0];
  }

  List<Prediction> _buildPredictions(List<double> output) {
    final indexed = <MapEntry<int, double>>[];
    for (int i = 0; i < output.length; i++) {
      indexed.add(MapEntry(i, output[i]));
    }
    indexed.sort((a, b) => b.value.compareTo(a.value));

    final results = <Prediction>[];
    for (int i = 0; i < kTopK && i < indexed.length; i++) {
      final entry = indexed[i];
      if (entry.value >= kConfidenceThreshold) {
        final label = entry.key < _labels.length
            ? _labels[entry.key]
            : 'Unknown_${entry.key}';
        results.add(Prediction(
          label: label,
          confidence: entry.value,
          index: entry.key,
        ));
      }
    }
    if (results.isEmpty && indexed.isNotEmpty) {
      final e = indexed[0];
      final label = e.key < _labels.length ? _labels[e.key] : 'Unknown';
      results.add(Prediction(label: label, confidence: e.value, index: e.key));
    }
    return results;
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isLoaded = false;
  }
}
