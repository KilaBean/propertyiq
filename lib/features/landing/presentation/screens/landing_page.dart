import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';

const _contactEmail = 'tandohp5@gmail.com';
const _maxContentWidth = 1160.0;

final _featuresKey = GlobalKey();
final _howItWorksKey = GlobalKey();

Future<void> _emailContact() =>
    launchUrl(Uri(scheme: 'mailto', path: _contactEmail));

void _scrollTo(GlobalKey key) {
  final ctx = key.currentContext;
  if (ctx == null) return;
  Scrollable.ensureVisible(
    ctx,
    duration: const Duration(milliseconds: 450),
    curve: Curves.easeOutCubic,
  );
}

/// Marketing landing page — the only thing served on the web platform.
/// The actual app (auth, dashboard, etc.) is mobile-only for now; web visitors
/// get a static, informational page instead of a half-working web build.
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _NavBar(),
            _Hero(),
            _FeatureSection(),
            _HowItWorksSection(),
            _CtaSection(),
            _Footer(),
          ],
        ),
      ),
    );
  }
}

/// Centers content with a max width — full-bleed on mobile, readable column
/// on desktop, matching typical SaaS landing pages.
class _Section extends StatelessWidget {
  const _Section({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
  });

  final Widget child;
  final Color? color;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: color,
      padding: padding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: child,
        ),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: _Section(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final showLinks = constraints.maxWidth > 700;
            return Row(
              children: [
                Image.asset(
                  'assets/branding/propertyiq_logo_with_text.png',
                  height: 26,
                ),
                if (showLinks)
                  Expanded(
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _NavLink(
                            'Features',
                            onTap: () => _scrollTo(_featuresKey),
                          ),
                          const SizedBox(width: 36),
                          _NavLink(
                            'How it works',
                            onTap: () => _scrollTo(_howItWorksKey),
                          ),
                          const SizedBox(width: 36),
                          _NavLink('Contact', onTap: _emailContact),
                        ],
                      ),
                    ),
                  )
                else
                  const Spacer(),
                FilledButton(
                  onPressed: _emailContact,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Get Started'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink(this.label, {required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextButton(
      onPressed: widget.onTap,
      style: TextButton.styleFrom(
        foregroundColor: scheme.onSurfaceVariant,
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        widget.label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 14, color: scheme.primary),
          const SizedBox(width: 8),
          Text(
            'AI-powered property management',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: scheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [scheme.primaryContainer.withValues(alpha: 0.35), scheme.surface],
        ),
      ),
      child: _Section(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 88),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 860;
            final content = Column(
              crossAxisAlignment:
                  isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                const _Badge(),
                const SizedBox(height: 24),
                RichText(
                  textAlign: isWide ? TextAlign.left : TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: isWide ? 52 : 34,
                      height: 1.12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.2,
                      color: scheme.onSurface,
                    ),
                    children: [
                      const TextSpan(text: 'Manage Properties.\n'),
                      const TextSpan(text: 'Delight Tenants.\n'),
                      TextSpan(
                        text: 'Grow With AI.',
                        style: TextStyle(color: scheme.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isWide ? 480 : 520),
                  child: Text(
                    'PropertyIQ helps landlords streamline operations, '
                    'automate maintenance triage, and grow their portfolio — '
                    'all in one place.',
                    textAlign: isWide ? TextAlign.left : TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      height: 1.55,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Wrap(
                  alignment:
                      isWide ? WrapAlignment.start : WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: _emailContact,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text('Get Started Free'),
                      style: FilledButton.styleFrom(
                        // Overrides the app theme's default
                        // minimumSize: Size.fromHeight(52), which forces
                        // infinite width and made this always wrap onto its
                        // own line inside the hero's Wrap.
                        minimumSize: const Size(0, 52),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () => _scrollTo(_featuresKey),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 52),
                        backgroundColor: scheme.surface,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 16,
                        ),
                        side: BorderSide(color: scheme.outlineVariant),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('View Features'),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                _HeroHighlights(isWide: isWide),
              ],
            );

            final mock = _HeroMockImage(maxWidth: isWide ? 560 : 420);

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 5, child: content),
                  const SizedBox(width: 56),
                  Expanded(flex: 6, child: Center(child: mock)),
                ],
              );
            }
            return Column(
              children: [content, const SizedBox(height: 48), mock],
            );
          },
        ),
      ),
    );
  }
}

/// Hero product visual — a single finished mockup image (two overlapping
/// phones showing the real DashboardScreen in light + dark mode), designed
/// in Canva from screenshots produced by lib/dev_preview/dashboard_preview_main.dart.
class _HeroMockImage extends StatelessWidget {
  const _HeroMockImage({required this.maxWidth});
  final double maxWidth;

  // The mockup's own baked-in background (~#F6F7FC) is fixed regardless of
  // site theme, so it's framed in a matching light card rather than left to
  // float directly on the hero gradient — avoids a visible seam in both
  // light and dark mode.
  static const _frameColor = Color(0xFFF6F7FC);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _frameColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Image.asset(
          'assets/branding/app_preview_hero.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

const _heroHighlights = [
  (
    Icons.grid_view_outlined,
    'All your properties',
    'In one dashboard',
  ),
  (
    Icons.insights_outlined,
    'Data-driven insights',
    'Occupancy & performance trends',
  ),
  (
    Icons.shield_outlined,
    'Secure & reliable',
    'Row-level security by design',
  ),
];

/// Icon + bold title + subtitle trio shown under the hero CTAs — real,
/// shipped features only (dashboard, occupancy trend chart, RLS security).
class _HeroHighlights extends StatelessWidget {
  const _HeroHighlights({required this.isWide});
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = [
      for (final h in _heroHighlights)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(h.$1, size: 18, color: scheme.primary),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  h.$2,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                Text(
                  h.$3,
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
    ];

    if (isWide) {
      return Wrap(spacing: 32, runSpacing: 16, children: items);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i != 0) const SizedBox(height: 14),
          items[i],
        ],
      ],
    );
  }
}

class _Feature {
  const _Feature(this.icon, this.title, this.description);
  final IconData icon;
  final String title;
  final String description;
}

const _features = [
  _Feature(
    Icons.apartment_outlined,
    'Properties & units',
    'Organize every property and unit you manage, with photos and rent '
        'details in one clean view.',
  ),
  _Feature(
    Icons.groups_outlined,
    'Tenant management',
    'Invite tenants securely, track lease terms, deposits, and contact '
        'details without spreadsheets.',
  ),
  _Feature(
    Icons.auto_awesome_outlined,
    'AI maintenance copilot',
    'Every request is automatically categorized and prioritized by AI the '
        'moment a tenant reports it.',
  ),
  _Feature(
    Icons.insights_outlined,
    'Portfolio insights',
    'See occupancy trends and rent status across your whole portfolio at a '
        'glance.',
  ),
  _Feature(
    Icons.lock_outline,
    'Secure by design',
    'Every manager’s data is isolated at the database level — no '
        'cross-account leaks, ever.',
  ),
  _Feature(
    Icons.build_outlined,
    'Maintenance tracking',
    'Tenants report issues with photos; managers track status from open to '
        'resolved.',
  ),
];

class _FeatureSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _Section(
      key: _featuresKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Everything you need to run your properties',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Built for landlords who want less busywork and more visibility.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 900
                  ? 3
                  : constraints.maxWidth > 560
                      ? 2
                      : 1;
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: columns == 1 ? 2.4 : 1.25,
                children: [for (final f in _features) _FeatureCard(feature: f)],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature});
  final _Feature feature;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(feature.icon, color: scheme.primary, size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            feature.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            feature.description,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

const _steps = [
  (
    '1',
    'Add your properties',
    'Bring in every property and unit — rent, bedrooms, and photos in one form.',
  ),
  (
    '2',
    'Invite your tenants',
    'Tenants get their own portal to view their lease and report issues.',
  ),
  (
    '3',
    'Let the copilot handle the rest',
    'Maintenance requests are triaged and prioritized by AI the moment they land.',
  ),
];

class _HowItWorksSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _Section(
      key: _howItWorksKey,
      color: scheme.surfaceContainerLowest,
      child: Column(
        children: [
          Text(
            'From setup to insight in three steps',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              final cards = [for (final s in _steps) _StepCard(step: s)];
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      if (i != 0) const SizedBox(width: 24),
                      Expanded(child: cards[i]),
                    ],
                  ],
                );
              }
              return Column(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i != 0) const SizedBox(height: 24),
                    cards[i],
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.step});
  final (String, String, String) step;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            step.$1,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          step.$2,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          step.$3,
          style: TextStyle(
            fontSize: 13.5,
            height: 1.5,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _CtaSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _Section(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 56),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.primary, AppColors.accent],
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          children: [
            Text(
              'Ready to see PropertyIQ in action?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: scheme.onPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'The mobile app is currently in private testing. Reach out and '
              'we’ll get you set up.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: scheme.onPrimary.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _emailContact,
              style: FilledButton.styleFrom(
                backgroundColor: scheme.onPrimary,
                foregroundColor: scheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Get in touch'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: _Section(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 620;
                final brand = Column(
                  crossAxisAlignment: isWide
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/branding/propertyiq_logo_with_text.png',
                      height: 24,
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: Text(
                        'Modern, AI-assisted property management for landlords '
                        'and tenants.',
                        textAlign: isWide ? TextAlign.left : TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                );
                final contact = GestureDetector(
                  onTap: _emailContact,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.mail_outline, size: 16, color: scheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        _contactEmail,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ),
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: brand),
                      contact,
                    ],
                  );
                }
                return Column(
                  children: [brand, const SizedBox(height: 20), contact],
                );
              },
            ),
            const SizedBox(height: 32),
            Divider(color: scheme.outlineVariant),
            const SizedBox(height: 20),
            Text(
              '© ${DateTime.now().year} PropertyIQ. All rights reserved.',
              style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
