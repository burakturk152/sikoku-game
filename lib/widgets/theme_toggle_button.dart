import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/theme_cubit.dart';
import '../bloc/theme_state.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final size = MediaQuery.sizeOf(context);
        final base = math.min(size.width, size.height);
        final double buttonSize = (base * 0.08).clamp(36.0, 56.0);

        final bool isDark = state.themeMode == ThemeMode.dark;
        final icon = isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round;
        final ColorScheme scheme = Theme.of(context).colorScheme;

        return Material(
          color: Colors.transparent,
          child: Container
            (
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: scheme.surface.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: IconButton(
              onPressed: () => context.read<ThemeCubit>().toggleTheme(),
              icon: Icon(icon,
                  size: buttonSize * 0.5,
                  color: isDark ? Colors.amber : Colors.blueGrey.shade700),
            ),
          ),
        );
      },
    );
  }
}
