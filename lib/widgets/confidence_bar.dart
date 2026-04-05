// lib/widgets/confidence_bar.dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ConfidenceBar extends StatelessWidget {
  final double value; // 0.0 – 1.0
  final String label;
  final bool isTop;

  const ConfidenceBar({
    super.key,
    required this.value,
    required this.label,
    this.isTop = false,
  });

  Color get _barColor {
    if (value >= 0.75) return AppTheme.primary;
    if (value >= 0.50) return AppTheme.warning;
    return AppTheme.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isTop ? 14 : 12,
                    fontWeight: isTop ? FontWeight.w600 : FontWeight.normal,
                    color: AppTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(value * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: isTop ? 14 : 12,
                  fontWeight: FontWeight.w700,
                  color: _barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: isTop ? 8 : 5,
              backgroundColor: AppTheme.divider,
              valueColor: AlwaysStoppedAnimation(_barColor),
            ),
          ),
        ],
      ),
    );
  }
}
