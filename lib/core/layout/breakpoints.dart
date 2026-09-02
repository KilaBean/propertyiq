import 'package:flutter/material.dart';

/// Layout breakpoints for PropertyIQ.
///
/// One place to change them, so screens describe intent ("this is a list of
/// cards") rather than repeating magic numbers. Values are logical pixels of
/// the *available* width, read from a [LayoutBuilder] rather than
/// `MediaQuery.size` — a screen inside a split view or a wide tablet pane gets
/// the width it actually has, not the window's.
enum FormFactor {
  /// Phones, and any pane narrower than a phone.
  compact,

  /// Small tablets, foldables, phone landscape.
  medium,

  /// Large tablets and desktop.
  expanded;

  static const double mediumMin = 600;
  static const double expandedMin = 1000;

  static FormFactor of(double width) {
    if (width >= expandedMin) return FormFactor.expanded;
    if (width >= mediumMin) return FormFactor.medium;
    return FormFactor.compact;
  }

  bool get isCompact => this == FormFactor.compact;

  /// Columns for a grid of cards at this size.
  int get cardColumns => switch (this) {
        FormFactor.compact => 1,
        FormFactor.medium => 2,
        FormFactor.expanded => 3,
      };
}

/// The widest a column of text or form fields should get before it becomes
/// tiring to read. Content wider than this is centred with gutters instead of
/// being stretched edge to edge.
const double kReadableWidth = 720;

/// Centres [child] and caps its width at [maxWidth].
///
/// Used by form and detail screens: on a phone it is a no-op, on a desktop
/// window it stops a single column of fields spanning 1600px.
class ReadableWidth extends StatelessWidget {
  const ReadableWidth({
    super.key,
    required this.child,
    this.maxWidth = kReadableWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Lays a list of cards out as a single column on a phone and as a grid on
/// wider screens, keeping one scroll view either way so pull-to-refresh and
/// scroll position behave identically.
///
/// [childAspectRatio] is the ratio for grid mode only; in single-column mode
/// each card sizes itself.
class ResponsiveCardList extends StatelessWidget {
  const ResponsiveCardList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 96),
    this.childAspectRatio = 3.2,
    this.controller,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final EdgeInsets padding;
  final double childAspectRatio;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = FormFactor.of(constraints.maxWidth).cardColumns;

        if (columns == 1) {
          return ListView.builder(
            controller: controller,
            padding: padding,
            itemCount: itemCount,
            itemBuilder: itemBuilder,
          );
        }

        return ReadableWidth(
          maxWidth: 1400,
          child: GridView.builder(
            controller: controller,
            padding: padding,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              // The cards carry a bottom margin of their own for list mode, so
              // only the horizontal gap is added here.
              mainAxisSpacing: 0,
              crossAxisSpacing: 12,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: itemCount,
            itemBuilder: itemBuilder,
          ),
        );
      },
    );
  }
}
