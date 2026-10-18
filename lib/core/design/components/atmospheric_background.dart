import 'package:flutter/material.dart';

/// Renders a smoothly animated multi-stop atmospheric gradient background.
///
/// Transitions between weather conditions and day/night transitions softly
/// without jarring flashes, respecting accessibility motion preferences.
class AtmosphericBackground extends StatelessWidget {
  const AtmosphericBackground({
    required this.gradient,
    required this.child,
    super.key,
    this.duration = const Duration(milliseconds: 900),
  });

  /// The active atmospheric linear gradient.
  final LinearGradient gradient;

  /// Content to render on top of the gradient.
  final Widget child;

  /// Transition duration between weather states.
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final effectiveDuration = reduceMotion ? Duration.zero : duration;

    return AnimatedContainer(
      duration: effectiveDuration,
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        gradient: gradient,
      ),
      child: child,
    );
  }
}
