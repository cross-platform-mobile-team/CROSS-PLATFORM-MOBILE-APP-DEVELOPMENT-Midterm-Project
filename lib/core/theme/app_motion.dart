import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Finite, shared transitions. Respect the OS accessibility preference.
abstract final class AppMotion {
  static Duration duration(BuildContext context, [int milliseconds = 200]) =>
      MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : Duration(milliseconds: milliseconds);
  static const curve = Curves.easeOutCubic;
}

/// Changes paint properties only: child identity, focus and layout stay intact.
class MotionSurface extends StatefulWidget {
  const MotionSurface({
    super.key,
    required this.child,
    this.tint = Colors.white,
    this.accent = AppTheme.accent,
    this.padding = EdgeInsets.zero,
  });
  final Widget child;
  final Color tint;
  final Color accent;
  final EdgeInsetsGeometry padding;

  @override
  State<MotionSurface> createState() => _MotionSurfaceState();
}

class _MotionSurfaceState extends State<MotionSurface> {
  bool hovering = false;
  bool focused = false;

  @override
  Widget build(BuildContext context) {
    final active = hovering || focused;
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        // Observe descendant focus without grouping their accessible labels.
        includeSemantics: false,
        onFocusChange: (value) => setState(() => focused = value),
        child: AnimatedContainer(
          duration: AppMotion.duration(context),
          curve: AppMotion.curve,
          decoration: BoxDecoration(
            color: widget.tint,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: active ? widget.accent : AppTheme.line),
            boxShadow: [
              BoxShadow(
                color: widget.accent.withValues(alpha: active ? .10 : .035),
                blurRadius: active ? 22 : 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        ),
      ),
    );
  }
}

/// One entrance per mounted region; rebuilding never restarts the animation.
class WorkspaceEntrance extends StatelessWidget {
  const WorkspaceEntrance({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: AppMotion.duration(context, 320),
    curve: AppMotion.curve,
    child: child,
    builder: (context, value, child) => Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, (1 - value) * 8),
        child: child,
      ),
    ),
  );
}
