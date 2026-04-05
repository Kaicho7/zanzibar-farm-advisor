// lib/models/advice.dart

class LocalizedText {
  final String en;
  final String sw;

  const LocalizedText({required this.en, required this.sw});

  String get(String lang) => lang == 'sw' ? sw : en;

  factory LocalizedText.fromJson(Map<String, dynamic> json) => LocalizedText(
        en: json['en'] as String? ?? '',
        sw: json['sw'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'en': en, 'sw': sw};
}

class DiseaseAdvice {
  final String key;            // matches label substring, e.g. "Early_blight"
  final LocalizedText name;
  final String severity;       // low / medium / high
  final LocalizedText symptoms;
  final LocalizedText treatment;
  final LocalizedText prevention;
  final LocalizedText marketImpact;
  final List<String> organicRemedies;
  final List<String> chemicalOptions;

  const DiseaseAdvice({
    required this.key,
    required this.name,
    required this.severity,
    required this.symptoms,
    required this.treatment,
    required this.prevention,
    required this.marketImpact,
    this.organicRemedies = const [],
    this.chemicalOptions = const [],
  });

  factory DiseaseAdvice.fromJson(Map<String, dynamic> json) => DiseaseAdvice(
        key: json['key'] as String,
        name: LocalizedText.fromJson(json['name']),
        severity: json['severity'] as String? ?? 'medium',
        symptoms: LocalizedText.fromJson(json['symptoms']),
        treatment: LocalizedText.fromJson(json['treatment']),
        prevention: LocalizedText.fromJson(json['prevention']),
        marketImpact: LocalizedText.fromJson(json['market_impact']),
        organicRemedies:
            List<String>.from(json['organic_remedies'] as List? ?? []),
        chemicalOptions:
            List<String>.from(json['chemical_options'] as List? ?? []),
      );
}

class HealthyAdvice {
  final LocalizedText message;
  final LocalizedText tips;

  const HealthyAdvice({required this.message, required this.tips});

  factory HealthyAdvice.fromJson(Map<String, dynamic> json) => HealthyAdvice(
        message: LocalizedText.fromJson(json['message']),
        tips: LocalizedText.fromJson(json['tips']),
      );
}
