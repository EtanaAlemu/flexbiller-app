import 'package:flutter/material.dart';
import 'localization_service.dart';

class LanguageSelectorWidget extends StatelessWidget {
  final bool showLabel;
  final double? size;
  final Color? color;

  const LanguageSelectorWidget({
    Key? key,
    this.showLabel = false,
    this.size,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.language,
        size: size ?? 24,
        color: color ?? theme.colorScheme.onSurface,
      ),
      tooltip: 'Select language',
      onSelected: (String languageCode) async {
        await LocalizationService.setLanguage(languageCode);
        // Note: In a real app, you'd want to rebuild the entire app
        // This is a simplified version for demonstration
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'en',
          child: Row(
            children: [
              const Text('🇺🇸'),
              if (showLabel) ...[
                const SizedBox(width: 12),
                Text(LocalizationService.getLanguageName('en')),
              ],
            ],
          ),
        ),
        // Add more languages here when needed
        // PopupMenuItem<String>(
        //   value: 'es',
        //   child: Row(
        //     children: [
        //       const Text('🇪🇸'),
        //       if (showLabel) ...[
        //         const SizedBox(width: 12),
        //         Text(LocalizationService.getLanguageName('es')),
        //       ],
        //     ],
        //   ),
        // ),
      ],
    );
  }
}

class SimpleLanguageSelector extends StatelessWidget {
  final double? size;
  final Color? color;

  const SimpleLanguageSelector({
    Key? key,
    this.size,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return IconButton(
      icon: Icon(
        Icons.language,
        size: size ?? 24,
        color: color ?? theme.colorScheme.onSurface,
      ),
      onPressed: () {
        // Show current language info
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Current language: ${LocalizationService.getCurrentLanguageName()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      tooltip: 'Current language: ${LocalizationService.getCurrentLanguageName()}',
    );
  }
}
