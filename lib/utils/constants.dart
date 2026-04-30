// lib/utils/constants.dart
const int kInputImageSize = 224;
const int kTopK = 3;
const double kConfidenceThreshold = 0.40;
const double kLowConfidenceThreshold = 0.60; // warn below this
// Asset paths
const String kModelPath   = 'assets/zanzibar_plant_vM.tflite';
const String kLabelsPath  = 'assets/zanzibar_plant_vM_labels.json';
const String kAdvisorPath = 'assets/advisor_data.json';
// Shared prefs keys
const String kPrefLanguage = 'language';
// Severity levels
const String kSeverityLow    = 'low';
const String kSeverityMedium = 'medium';
const String kSeverityHigh   = 'high';
