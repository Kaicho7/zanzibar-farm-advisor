// lib/services/app_state.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'tflite_service.dart';
import 'advisor_service.dart';
import '../models/prediction.dart';
import '../models/advice.dart';
import '../utils/constants.dart';

enum AppStatus { initialising, ready, analysing, done, error }

class AppState extends ChangeNotifier {
  final TFLiteService _tflite = TFLiteService();
  final AdvisorService _advisor = AdvisorService();

  AppStatus _status = AppStatus.initialising;
  String _language = 'en';
  String _errorMessage = '';

  // Analysis state
  File? _selectedImage;
  AnalysisResult? _result;
  DiseaseAdvice? _advice;

  // Getters
  AppStatus get status => _status;
  String get language => _language;
  String get errorMessage => _errorMessage;
  File? get selectedImage => _selectedImage;
  AnalysisResult? get result => _result;
  DiseaseAdvice? get advice => _advice;
  bool get isReady => _status == AppStatus.ready || _status == AppStatus.done;

  String t(String en, String sw) => _language == 'sw' ? sw : en;

  Future<void> init() async {
    try {
      _status = AppStatus.initialising;
      notifyListeners();

      // Load language preference
      final prefs = await SharedPreferences.getInstance();
      _language = prefs.getString(kPrefLanguage) ?? 'en';

      await Future.wait([
        _tflite.load(),
        _advisor.load(),
      ]);

      _status = AppStatus.ready;
    } catch (e, stack) {
      debugPrint("analyseImage error: $e\n$stack");
      _errorMessage = e.toString();
      _status = AppStatus.error;
    }
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kPrefLanguage, lang);
    notifyListeners();
  }

  Future<void> analyseImage(File image) async {
    _selectedImage = image;
    _result = null;
    _advice = null;
    _status = AppStatus.analysing;
    notifyListeners();

    try {
      final result = await _tflite.analyse(image);
      _result = result;

      if (result.top != null) {
        _advice = _advisor.getAdviceFor(result.top!);
      }

      _status = AppStatus.done;
    } catch (e, stack) {
      debugPrint("analyseImage error: $e\n$stack");
      _errorMessage = e.toString();
      _status = AppStatus.error;
    }
    notifyListeners();
  }

  void reset() {
    _selectedImage = null;
    _result = null;
    _advice = null;
    _status = AppStatus.ready;
    notifyListeners();
  }

  @override
  void dispose() {
    _tflite.dispose();
    super.dispose();
  }
}
