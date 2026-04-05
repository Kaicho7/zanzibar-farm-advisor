// lib/models/prediction.dart

class Prediction {
  final String label;
  final double confidence;
  final int index;

  const Prediction({
    required this.label,
    required this.confidence,
    required this.index,
  });

  /// e.g. "Tomato___Early_blight" → "Tomato Early Blight"
  String get displayLabel {
    return label
        .replaceAll('___', ' — ')
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  /// The crop part: "Tomato___Early_blight" → "Tomato"
  String get crop {
    final parts = label.split('___');
    return parts[0].replaceAll('_', ' ');
  }

  /// The condition part: "Tomato___Early_blight" → "Early blight"
  String get condition {
    final parts = label.split('___');
    if (parts.length < 2) return label.replaceAll('_', ' ');
    return parts[1].replaceAll('_', ' ');
  }

  bool get isHealthy => label.toLowerCase().contains('healthy');

  @override
  String toString() => 'Prediction(label: $label, confidence: $confidence)';
}

class AnalysisResult {
  final List<Prediction> predictions;
  final Duration analysisTime;
  final DateTime timestamp;

  const AnalysisResult({
    required this.predictions,
    required this.analysisTime,
    required this.timestamp,
  });

  Prediction? get top => predictions.isNotEmpty ? predictions.first : null;
  bool get hasResult => predictions.isNotEmpty;
}
