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
      return _diseases.firstWhereOrNull(
        (d) => d.key.toLowerCase() == 'healthy',
      );
    }

    final rawLabel = prediction.label.toLowerCase()
        .replaceAll('(', '').replaceAll(')', '').replaceAll(' ', '_');
    final cropPart = prediction.crop.toLowerCase()
        .replaceAll('(', '').replaceAll(')', '').replaceAll(' ', '_');
    final conditionPart = prediction.condition.toLowerCase()
        .replaceAll(' ', '_');

    // 1. Full label contains the advice key
    DiseaseAdvice? best = _diseases.firstWhereOrNull(
      (d) => rawLabel.contains(d.key.toLowerCase().replaceAll(' ', '_')),
    );

    // 2. Both crop AND condition must match
    best ??= _diseases.firstWhereOrNull((d) {
      final dk = d.key.toLowerCase().replaceAll(' ', '_');
      final parts = dk.split('_').where((w) => w.length > 3).toList();
      return parts.isNotEmpty &&
             parts.every((w) => rawLabel.contains(w));
    });

    // 3. All significant condition words must match (not just any)
    best ??= _diseases.firstWhereOrNull((d) {
      final dkWords = d.key.toLowerCase().replaceAll('_', ' ')
          .split(' ').where((w) => w.length > 4).toList();
      return dkWords.length >= 2 &&
             dkWords.every((w) => conditionPart.contains(w));
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
