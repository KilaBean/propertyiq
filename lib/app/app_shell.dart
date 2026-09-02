import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/router/app_routes.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
import '../shared/models/user_role.dart';

class _Tab {
  const _Tab(this.route, this.icon, this.selectedIcon, this.label);
  final String route;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

const _managerTabs = [
  _Tab(
    AppRoutes.dashboard,
    Icons.grid_view_outlined,
    Icons.grid_view_rounded,
    'Home',
  ),
  _Tab(
    AppRoutes.properties,
    Icons.apartment_outlined,
    Icons.apartment,
    'Properties',
  ),
  _Tab(AppRoutes.maintenance, Icons.build_outlined, Icons.build, 'Requests'),
  _Tab(AppRoutes.profile, Icons.person_outline, Icons.person, 'Profile'),
];

const _tenantTabs = [
  _Tab(AppRoutes.myUnit, Icons.home_outlined, Icons.home, 'Home'),
  _Tab(
    AppRoutes.tenantPayments,
    Icons.account_balance_wallet_outlined,
    Icons.account_balance_wallet,
    'Pay',
  ),
  _Tab(
    AppRoutes.tenantMaintenance,
    Icons.build_outlined,
    Icons.build,
    'Requests',
  ),
  _Tab(AppRoutes.profile, Icons.person_outline, Icons.person, 'Profile'),
];

/// Persistent shell with a floating bottom bar + a raised center "add" button.
/// Destinations adapt to the user's role; detail/form screens push full-screen
/// over the bar. Both role's tab sets are kept even (4) so the center button
/// splits into two equal halves.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTenant =
        ref.watch(currentProfileProvider).value?.role == UserRole.tenant;
    final tabs = isTenant ? _tenantTabs : _managerTabs;
    final location = GoRouterState.of(context).uri.path;
    final index = _selectedIndex(location, tabs);

    final mid = tabs.length ~/ 2;
    final left = tabs.sublist(0, mid);
    final right = tabs.sublist(mid);

    Widget half(List<_Tab> items, int base) => Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var i = 0; i < items.length; i++)
            _NavItem(
              tab: items[i],
              selected: index == base + i,
              onTap: () {
                if (index != base + i) context.go(items[i].route);
              },
            ),
        ],
      ),
    );

    return Scaffold(
      body: child,
      bottomNavigationBar: SafeArea(
        top: false,
        child: SizedBox(
          height: 78,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  height: 58,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      half(left, 0),
                      const SizedBox(width: 56),
                      half(right, mid),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: _AddButton(
                  label: isTenant ? 'New maintenance request' : 'New property',
                  onTap: () => context.push(
                    isTenant
                        ? AppRoutes.tenantMaintenanceNew
                        : AppRoutes.propertyNew,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Longest matching route prefix wins, so /my-unit/maintenance beats /my-unit.
  int _selectedIndex(String location, List<_Tab> tabs) {
    var best = 0;
    var bestLen = -1;
    for (var i = 0; i < tabs.length; i++) {
      final r = tabs[i].route;
      if ((location == r ||
              location.startsWith('$r/') ||
              location.startsWith(r)) &&
          r.length > bestLen) {
        best = i;
        bestLen = r.length;
      }
    }
    return best;
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final _Tab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;
    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            // The design system's 44px minimum: the icon + label column is
            // shorter than that on its own.
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    selected ? tab.selectedIcon : tab.icon,
                    color: color,
                    size: 22,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    tab.label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap, required this.label});

  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: scheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
