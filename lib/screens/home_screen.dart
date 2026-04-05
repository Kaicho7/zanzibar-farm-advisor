// lib/screens/home_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../utils/app_theme.dart';
import '../widgets/image_source_sheet.dart';
import 'result_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    // Navigate to results when done
    if (state.status == AppStatus.done && state.result != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ResultScreen()),
        ).then((_) => state.reset());
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.eco_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(state.t('Zanzibar Farm AI', 'Kilimo Akili — Zanzibar')),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WelcomeBanner(state: state),
            const SizedBox(height: 24),
            _ScanButton(state: state),
            const SizedBox(height: 24),
            if (state.status == AppStatus.analysing) ...[
              _AnalysingCard(state: state),
              const SizedBox(height: 24),
            ],
            if (state.status == AppStatus.error) ...[
              _ErrorCard(message: state.errorMessage, state: state),
              const SizedBox(height: 24),
            ],
            _HowItWorksSection(state: state),
            const SizedBox(height: 24),
            _CropsGrid(state: state),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Welcome Banner ──────────────────────────────────────────────────────────

class _WelcomeBanner extends StatelessWidget {
  final AppState state;
  const _WelcomeBanner({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_florist_rounded,
                  color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Text(
                state.t('AI-Powered Plant Doctor', 'Daktari wa Mimea wa AI'),
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            state.t(
              'Scan your crop.\nGet expert advice.',
              'Piga picha zao.\nPata ushauri wa kitaalamu.',
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.accent.withOpacity(0.4)),
            ),
            child: Text(
              state.t(
                '🌿 Identifies 50+ diseases across your 25 crops',
                '🌿 Inatambua magonjwa 50+ kwenye mazao yako 25',
              ),
              style: const TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Scan Button ─────────────────────────────────────────────────────────────

class _ScanButton extends StatelessWidget {
  final AppState state;
  const _ScanButton({required this.state});

  @override
  Widget build(BuildContext context) {
    final isLoading = state.status == AppStatus.analysing ||
        state.status == AppStatus.initialising;

    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: isLoading
            ? null
            : () => ImageSourceSheet.show(context),
        icon: isLoading
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.camera_alt_rounded, size: 22),
        label: Text(
          isLoading
              ? state.t('Analysing...', 'Inachambua...')
              : state.t('📸  Scan Plant / Crop', '📸  Piga Picha Mmea / Zao'),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ── Analysing Card ──────────────────────────────────────────────────────────

class _AnalysingCard extends StatelessWidget {
  final AppState state;
  const _AnalysingCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (state.selectedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  state.selectedImage!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
            const SizedBox(height: 12),
            Text(
              state.t(
                'AI is analysing your plant…',
                'AI inachambua mmea wako…',
              ),
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error Card ──────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  final String message;
  final AppState state;
  const _ErrorCard({required this.message, required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.error.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: AppTheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.t('Error', 'Hitilafu'),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: AppTheme.error),
                  ),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 12, color: AppTheme.error),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: state.reset,
              child: Text(state.t('Retry', 'Jaribu Tena')),
            ),
          ],
        ),
      ),
    );
  }
}

// ── How It Works ────────────────────────────────────────────────────────────

class _HowItWorksSection extends StatelessWidget {
  final AppState state;
  const _HowItWorksSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (
        Icons.camera_alt_rounded,
        state.t('Take Photo', 'Piga Picha'),
        state.t('Camera, gallery\nor file', 'Kamera, picha\nau faili'),
        AppTheme.primaryLight,
      ),
      (
        Icons.psychology_rounded,
        state.t('AI Analyses', 'AI Inachambua'),
        state.t('Model detects\ndisease', 'Modeli hugundua\nugonjwa'),
        AppTheme.accent,
      ),
      (
        Icons.medical_services_rounded,
        state.t('Get Advice', 'Pata Ushauri'),
        state.t('Treatment &\nprevention tips', 'Ushauri wa\nmatibabu'),
        AppTheme.primary,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state.t('How It Works', 'Jinsi Inavyofanya Kazi'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: steps.asMap().entries.map((entry) {
            final i = entry.key;
            final s = entry.value;
            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _StepCard(
                      icon: s.$1,
                      title: s.$2,
                      subtitle: s.$3,
                      color: s.$4,
                      step: i + 1,
                    ),
                  ),
                  if (i < steps.length - 1)
                    const Icon(Icons.chevron_right_rounded,
                        color: AppTheme.divider),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final int step;

  const _StepCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: const TextStyle(
                fontSize: 9, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Crops Grid ──────────────────────────────────────────────────────────────

class _CropsGrid extends StatelessWidget {
  final AppState state;
  const _CropsGrid({required this.state});

  static const _crops = [
    ('🍅', 'Tomato', 'Nyanya'),
    ('🥒', 'Cucumber', 'Tango'),
    ('🌽', 'Corn', 'Mahindi'),
    ('🥭', 'Mango', 'Embe'),
    ('🌶️', 'Chili', 'Pilipili'),
    ('🍌', 'Banana', 'Ndizi'),
    ('🍠', 'Cassava', 'Muhogo'),
    ('🥑', 'Avocado', 'Parachichi'),
    ('🌿', 'Leafy Veg', 'Mboga'),
    ('🍈', 'Papaya', 'Papai'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state.t('Supported Crops', 'Mazao Yanayosaidiwa'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _crops.map((c) => Chip(
            avatar: Text(c.$1, style: const TextStyle(fontSize: 14)),
            label: Text(
              state.t(c.$2, c.$3),
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w500),
            ),
          )).toList(),
        ),
      ],
    );
  }
}
