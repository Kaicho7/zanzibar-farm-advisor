// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(state.t('Settings', 'Mipangilio')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Language ────────────────────────────────────────────────
          _SectionHeader(title: state.t('Language', 'Lugha')),
          Card(
            child: Column(
              children: [
                _LanguageTile(
                  flag: '🇬🇧',
                  name: 'English',
                  code: 'en',
                  selected: state.language == 'en',
                  onTap: () => state.setLanguage('en'),
                ),
                const Divider(height: 0, indent: 16),
                _LanguageTile(
                  flag: '🇹🇿',
                  name: 'Kiswahili',
                  code: 'sw',
                  selected: state.language == 'sw',
                  onTap: () => state.setLanguage('sw'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Model Info ──────────────────────────────────────────────
          _SectionHeader(title: state.t('AI Model', 'Modeli ya AI')),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    label: state.t('Model', 'Modeli'),
                    value: 'zanzibar_plant_vM.tflite',
                  ),
                  _InfoRow(
                    label: state.t('Architecture', 'Usanifu'),
                    value: 'MobileNetV2 + EfficientNetB3 Ensemble',
                  ),
                  _InfoRow(
                    label: state.t('Input size', 'Ukubwa wa ingizo'),
                    value: '224 × 224 px',
                  ),
                  _InfoRow(
                    label: state.t('Status', 'Hali'),
                    value: state.isReady
                        ? state.t('✅ Loaded', '✅ Imepakiwa')
                        : state.t('⏳ Loading...', '⏳ Inapakia...'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── About ────────────────────────────────────────────────────
          _SectionHeader(title: state.t('About', 'Kuhusu')),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.eco_rounded,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Zanzibar Farm AI',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary),
                          ),
                          Text(
                            state.t('Version 1.0.0', 'Toleo 1.0.0'),
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.t(
                      'AI-powered crop disease detection and farm advisory system built for Zanzibar smallholder farmers.',
                      'Mfumo wa kutambua magonjwa ya mazao na ushauri wa shamba unaotumia AI, uliojengwa kwa wakulima wadogo wa Zanzibar.',
                    ),
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.divider.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      state.t(
                        '⚠️ This app provides guidance only. Always consult your local agricultural extension officer (MANREC +255 24 223 1951) for serious crop disease issues.',
                        '⚠️ Programu hii hutoa mwongozo tu. Daima wasiliana na afisa wako wa ugani wa kilimo (MANREC +255 24 223 1951) kwa matatizo makubwa ya magonjwa ya mazao.',
                      ),
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String flag;
  final String name;
  final String code;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.flag,
    required this.name,
    required this.code,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
          color: selected ? AppTheme.primary : AppTheme.textPrimary,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check_circle_rounded, color: AppTheme.primary)
          : null,
      onTap: onTap,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
