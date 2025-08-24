import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class ThemeToggleWidget extends StatelessWidget {
  final bool showLabel;
  final double? size;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const ThemeToggleWidget({
    Key? key,
    this.showLabel = false,
    this.size,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        return PopupMenuButton<ThemeMode>(
          icon: Icon(
            themeProvider.getThemeModeIcon(),
            size: size ?? 24,
            color: foregroundColor ?? theme.colorScheme.onSurface,
          ),
          tooltip: 'Toggle theme',
          onSelected: (ThemeMode mode) {
            themeProvider.setThemeMode(mode);
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<ThemeMode>(
              value: ThemeMode.light,
              child: Row(
                children: [
                  Icon(
                    Icons.light_mode,
                    color: theme.colorScheme.primary,
                  ),
                  if (showLabel) ...[
                    const SizedBox(width: 12),
                    const Text('Light'),
                  ],
                ],
              ),
            ),
            PopupMenuItem<ThemeMode>(
              value: ThemeMode.dark,
              child: Row(
                children: [
                  Icon(
                    Icons.dark_mode,
                    color: theme.colorScheme.primary,
                  ),
                  if (showLabel) ...[
                    const SizedBox(width: 12),
                    const Text('Dark'),
                  ],
                ],
              ),
            ),
            PopupMenuItem<ThemeMode>(
              value: ThemeMode.system,
              child: Row(
                children: [
                  Icon(
                    Icons.brightness_auto,
                    color: theme.colorScheme.primary,
                  ),
                  if (showLabel) ...[
                    const SizedBox(width: 12),
                    const Text('System'),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class SimpleThemeToggle extends StatelessWidget {
  final double? size;
  final Color? color;

  const SimpleThemeToggle({
    Key? key,
    this.size,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return IconButton(
          icon: Icon(
            themeProvider.getThemeModeIcon(),
            size: size ?? 24,
            color: color,
          ),
          onPressed: () => themeProvider.toggleTheme(),
          tooltip: 'Toggle theme',
        );
      },
    );
  }
}
