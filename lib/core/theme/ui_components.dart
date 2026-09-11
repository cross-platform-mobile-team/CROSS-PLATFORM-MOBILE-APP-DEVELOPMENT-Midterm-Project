import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Decorative artwork never adds focus targets or obscures the text surface.
class StudioHeader extends StatelessWidget {
  const StudioHeader({super.key, required this.summary});
  final String summary;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: Stack(
      children: [
        const Positioned.fill(
          child: ExcludeSemantics(child: CustomPaint(painter: _StudioArt())),
        ),
        Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'YOUR DAILY SPACE',
                style: TextStyle(
                  color: AppTheme.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 8),
              Semantics(
                header: true,
                child: Text(
                  'Make room for what matters.',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  summary,
                  style: const TextStyle(color: AppTheme.muted),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _StudioArt extends CustomPainter {
  const _StudioArt();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppTheme.lavender);
    canvas.drawCircle(
      Offset(size.width, 0),
      size.height * .85,
      Paint()..color = AppTheme.mint,
    );
    canvas.drawCircle(
      Offset(size.width, size.height),
      size.height * .48,
      Paint()..color = AppTheme.peach,
    );
    canvas.drawCircle(
      Offset(size.width - 18, 22),
      8,
      Paint()..color = const Color(0xFFFFD890),
    );
  }

  @override
  bool shouldRepaint(covariant _StudioArt oldDelegate) => false;
}

class BrandTitle extends StatelessWidget {
  const BrandTitle({super.key});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.accent, Color(0xFF355FAD)],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.done_all_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
      const SizedBox(width: 10),
      const Flexible(child: Text('TaskFlow QA Lab')),
    ],
  );
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, this.subtitle, this.icon});
  final String title;
  final String? subtitle;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.lavender,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: AppTheme.accent),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                container: true,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: const TextStyle(color: AppTheme.muted, fontSize: 13),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

class SurfacePanel extends StatelessWidget {
  const SurfacePanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Card(
    semanticContainer: false,
    child: Padding(padding: padding, child: child),
  );
}

class StatePanel extends StatelessWidget {
  const StatePanel({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.error = false,
  });
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  final bool error;
  @override
  Widget build(BuildContext context) => SurfacePanel(
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: error ? const Color(0xFFFFEFF1) : const Color(0xFFEEF1FF),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            icon,
            color: error
                ? Theme.of(context).colorScheme.error
                : AppTheme.accent,
            size: 28,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Semantics(
          liveRegion: error,
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.muted),
          ),
        ),
        if (action != null) ...[const SizedBox(height: 12), action!],
      ],
    ),
  );
}

class AuthFrame extends StatelessWidget {
  const AuthFrame({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final wide =
          constraints.maxWidth >= 960 &&
          MediaQuery.textScalerOf(context).scale(14) <= 20;
      return SingleChildScrollView(
        padding: EdgeInsets.all(wide ? 40 : 16),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: wide ? 1080 : 520),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (wide) ...[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF352568), Color(0xFF173F4B)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.checklist_rounded,
                            size: 56,
                            color: Color(0xFFFFD890),
                          ),
                          const SizedBox(height: 48),
                          const Text(
                            'Less noise.\nMore progress.',
                            style: TextStyle(
                              fontSize: 46,
                              height: 1.1,
                              letterSpacing: -1.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'A calm place to plan your day, focus on what matters and celebrate the small wins.',
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.7,
                              color: Color(0xFFD3DCF3),
                            ),
                          ),
                          const SizedBox(height: 48),
                          for (final item in [
                            (Icons.tune_rounded, 'Priorities that make sense'),
                            (
                              Icons.devices_rounded,
                              'Your workspace, across screens',
                            ),
                            (
                              Icons.shield_outlined,
                              'Offline and account data stay separate',
                            ),
                          ])
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Row(
                                children: [
                                  Icon(
                                    item.$1,
                                    size: 20,
                                    color: const Color(0xFFB8C5FF),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item.$2,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                ],
                Expanded(
                  child: SurfacePanel(
                    padding: EdgeInsets.all(wide ? 32 : 20),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
