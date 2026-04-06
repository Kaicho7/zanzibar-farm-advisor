// lib/widgets/image_source_sheet.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../utils/app_theme.dart';

class ImageSourceSheet extends StatelessWidget {
  const ImageSourceSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const ImageSourceSheet(),
    );
  }

  Future<void> _pickFromCamera(BuildContext context) async {
    final appState = context.read<AppState>(); // capture before pop
    Navigator.pop(context);
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
      maxWidth: 1080,
    );
    if (xfile != null) {
      appState.analyseImage(File(xfile.path));
    }
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final appState = context.read<AppState>(); // capture before pop
    Navigator.pop(context);
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 1080,
    );
    if (xfile != null) {
      appState.analyseImage(File(xfile.path));
    }
  }

  Future<void> _pickFromFiles(BuildContext context) async {
    final appState = context.read<AppState>(); // capture before pop
    Navigator.pop(context);
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      appState.analyseImage(File(result.files.single.path!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppTheme.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            state.t('Select Image Source', 'Chagua Chanzo cha Picha'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SourceButton(
                icon: Icons.camera_alt_rounded,
                label: state.t('Camera', 'Kamera'),
                color: AppTheme.primary,
                onTap: () => _pickFromCamera(context),
              ),
              _SourceButton(
                icon: Icons.photo_library_rounded,
                label: state.t('Gallery', 'Picha'),
                color: AppTheme.primaryLight,
                onTap: () => _pickFromGallery(context),
              ),
              _SourceButton(
                icon: Icons.folder_open_rounded,
                label: state.t('Files', 'Faili'),
                color: AppTheme.accent,
                onTap: () => _pickFromFiles(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            state.t(
              'Supports Google Drive, Downloads, SD card',
              'Inasaidia Google Drive, Upakuaji, Kadi ya SD',
            ),
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SourceButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 68, height: 68,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
