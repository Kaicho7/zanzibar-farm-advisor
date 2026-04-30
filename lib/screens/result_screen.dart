// lib/screens/result_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../models/prediction.dart';
import '../models/advice.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/confidence_bar.dart';
import '../widgets/advice_section.dart';
import '../widgets/image_source_sheet.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final result = state.result;
    final advice = state.advice;
    final top = result?.top;

    if (result == null || top == null) {
      return Scaffold(
        appBar: AppBar(title: Text(state.t('Result', 'Matokeo'))),
        body: Center(child: Text(state.t('No result', 'Hakuna matokeo'))),
      );
    }

    final severityColor = advice != null
        ? AppTheme.severityColor(advice.severity)
        : AppTheme.textSecondary;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero Image AppBar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppTheme.primaryDark,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
                tooltip: state.t('Scan Another', 'Piga Nyingine'),
                onPressed: () {
                  Navigator.pop(context);
                  ImageSourceSheet.show(context);
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (state.selectedImage != null)
                    Image.file(
                      state.selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.primaryDark.withOpacity(0.85),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: _DiagnosisBadge(
                      top: top,
                      advice: advice,
                      state: state,
                      severityColor: severityColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Low confidence warning
                  if (top.confidence < kLowConfidenceThreshold)
                    _LowConfidenceWarning(confidence: top.confidence, state: state),
                  if (top.confidence < kLowConfidenceThreshold)
                    const SizedBox(height: 12),
                  // Confidence scores
                  _ConfidenceSection(result: result, state: state),
                  const SizedBox(height: 16),

                  if (top.isHealthy) ...[
                    _HealthyCard(state: state, advice: advice),
                  ] else if (advice != null) ...[
                    // Symptoms
                    AdviceSection(
                      icon: Icons.search_rounded,
                      title: state.t('Symptoms', 'Dalili'),
                      content: advice.symptoms.get(state.language),
                      iconColor: AppTheme.warning,
                    ),

                    // Treatment
                    AdviceSection(
                      icon: Icons.medical_services_rounded,
                      title: state.t('Treatment', 'Matibabu'),
                      content: advice.treatment.get(state.language),
                      iconColor: AppTheme.primary,
                    ),

                    // Prevention
                    AdviceSection(
                      icon: Icons.shield_rounded,
                      title: state.t('Prevention', 'Kinga'),
                      content: advice.prevention.get(state.language),
                      iconColor: AppTheme.primaryLight,
                    ),

                    // Market Impact
                    AdviceSection(
                      icon: Icons.storefront_rounded,
                      title: state.t('Market Impact', 'Athari ya Soko'),
                      content: advice.marketImpact.get(state.language),
                      iconColor: AppTheme.accent,
                    ),

                    // Organic remedies
                    RemediesList(
                      title: state.t('Organic Remedies', 'Tiba za Kikaboni'),
                      icon: Icons.eco_rounded,
                      color: AppTheme.primaryLight,
                      items: advice.organicRemedies,
                    ),

                    // Chemical options
                    RemediesList(
                      title: state.t('Chemical Options', 'Chaguzi za Kemikali'),
                      icon: Icons.science_rounded,
                      color: AppTheme.warning,
                      items: advice.chemicalOptions,
                    ),
                  ] else ...[
                    // No advice found — generic
                    _NoAdviceCard(top: top, state: state),
                  ],

                  // Analysis time footer
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 32),
                      child: Text(
                        state.t(
                          'Analysed in ${result.analysisTime.inMilliseconds}ms',
                          'Ilichambuliwa kwa ms ${result.analysisTime.inMilliseconds}',
                        ),
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context);
          ImageSourceSheet.show(context);
        },
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
        label: Text(
          state.t('Scan Another', 'Piga Nyingine'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ── Diagnosis Badge ──────────────────────────────────────────────────────────

class _DiagnosisBadge extends StatelessWidget {
  final Prediction top;
  final DiseaseAdvice? advice;
  final AppState state;
  final Color severityColor;

  const _DiagnosisBadge({
    required this.top,
    required this.advice,
    required this.state,
    required this.severityColor,
  });

  @override
  Widget build(BuildContext context) {
    final diseaseName = advice?.name.get(state.language) ?? top.displayLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Crop chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: Text(
            top.crop,
            style: const TextStyle(
                color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          diseaseName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              AppTheme.severityIcon(advice?.severity ?? kSeverityLow),
              color: severityColor,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              _severityLabel(advice?.severity ?? kSeverityLow, state),
              style: TextStyle(
                color: severityColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${(top.confidence * 100).toStringAsFixed(1)}% ${state.t('confidence', 'uhakika')}',
                style: const TextStyle(
                    color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _severityLabel(String severity, AppState state) {
    switch (severity) {
      case kSeverityHigh:   return state.t('High severity', 'Ukali wa juu');
      case kSeverityMedium: return state.t('Medium severity', 'Ukali wa kati');
      default:              return state.t('Low severity', 'Ukali mdogo');
    }
  }
}

// ── Confidence Section ───────────────────────────────────────────────────────

class _ConfidenceSection extends StatelessWidget {
  final AnalysisResult result;
  final AppState state;

  const _ConfidenceSection({required this.result, required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart_rounded,
                    color: AppTheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  state.t('AI Confidence', 'Uhakika wa AI'),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...result.predictions.asMap().entries.map((e) => ConfidenceBar(
                  value: e.value.confidence,
                  label: e.value.displayLabel,
                  isTop: e.key == 0,
                )),
          ],
        ),
      ),
    );
  }
}

// ── Healthy Card ─────────────────────────────────────────────────────────────

class _HealthyCard extends StatelessWidget {
  final AppState state;
  final DiseaseAdvice? advice;

  const _HealthyCard({required this.state, required this.advice});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.severityLow.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppTheme.severityLow, size: 48),
            const SizedBox(height: 12),
            Text(
              state.t('Your plant looks healthy! 🌿',
                  'Mmea wako unaonekana mzuri! 🌿'),
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (advice != null)
              Text(
                advice!.prevention.get(state.language),
                style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.6),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Low Confidence Warning ─────────────────────────────────────────────────

class _LowConfidenceWarning extends StatelessWidget {
  final double confidence;
  final AppState state;
  const _LowConfidenceWarning({required this.confidence, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFD700)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFB8860B), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              state.t(
                'Low confidence — try a clearer photo of the leaf.',
                'Uhakika mdogo — jaribu picha wazi zaidi ya jani.',
              ),
              style: const TextStyle(fontSize: 13, color: Color(0xFF7B6000), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ── No Advice Fallback ────────────────────────────────────────────────────────

class _NoAdviceCard extends StatelessWidget {
  final Prediction top;
  final AppState state;

  const _NoAdviceCard({required this.top, required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.warning.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppTheme.warning),
                SizedBox(width: 8),
                Text(
                  'Disease Detected',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: AppTheme.warning),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              state.t(
                'Detected: ${top.displayLabel}\n\nContact your local agricultural extension officer for specific advice on this condition.',
                'Imegunduliwa: ${top.displayLabel}\n\nWasiliana na afisa wako wa ugani wa kilimo wa mtaa kwa ushauri maalum kuhusu hali hii.',
              ),
              style: const TextStyle(
                  fontSize: 14, color: AppTheme.textPrimary, height: 1.6),
            ),
            const SizedBox(height: 12),
            Text(
              state.t(
                'MANREC Zanzibar: +255 24 223 1951',
                'MANREC Zanzibar: +255 24 223 1951',
              ),
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: AppTheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}
