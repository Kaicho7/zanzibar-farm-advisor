// lib/services/advisor_service.dart
import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/advice.dart';
import '../models/prediction.dart';
import '../utils/constants.dart';

class AdvisorService {
  List<DiseaseAdvice> _diseases = [];
  HealthyAdvice? _healthyAdvice;
  bool _loaded = false;

  bool get isLoaded => _loaded;

  Future<void> load() async {
    final raw = await rootBundle.loadString(kAdvisorPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final list = json['diseases'] as List;
    _diseases = list.map((e) => DiseaseAdvice.fromJson(e)).toList();

    // Separate the "healthy" entry
    final healthyEntry = _diseases.firstWhere(
      (d) => d.key.toLowerCase() == 'healthy',
      orElse: () => DiseaseAdvice(
        key: 'healthy',
        name: const LocalizedText(en: 'Healthy', sw: 'Yenye Afya'),
        severity: 'low',
        symptoms: const LocalizedText(en: '', sw: ''),
        treatment: const LocalizedText(en: '', sw: ''),
        prevention: const LocalizedText(en: '', sw: ''),
        marketImpact: const LocalizedText(en: '', sw: ''),
      ),
    );

    _healthyAdvice = HealthyAdvice(
      message: healthyEntry.name,
      tips: healthyEntry.prevention,
    );

    _loaded = true;
  }

  /// Find the best advice for a prediction
  DiseaseAdvice? getAdviceFor(Prediction prediction) {
    if (prediction.isHealthy) {
      // Return the healthy entry
      return _diseases.firstWhere(
        (d) => d.key.toLowerCase() == 'healthy',
        orElse: () => _diseases.first,
      );
    }

    final labelLower = prediction.label.toLowerCase();
    final conditionLower = prediction.condition.toLowerCase();

    // Exact key match first
    DiseaseAdvice? best = _diseases.firstWhereOrNull(
      (d) => labelLower.contains(d.key.toLowerCase()),
    );

    // Fuzzy match on condition words if no exact match
    best ??= _diseases.firstWhereOrNull((d) {
      final keyWords = d.key.toLowerCase().replaceAll('_', ' ').split(' ');
      return keyWords.any((w) => conditionLower.contains(w) && w.length > 3);
    });

    return best;
  }

  List<DiseaseAdvice> get allDiseases => List.unmodifiable(_diseases);
}

extension ListWhereOrNull<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
