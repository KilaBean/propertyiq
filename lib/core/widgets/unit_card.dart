import 'package:flutter/material.dart';

import '../../shared/models/unit.dart';
import '../../shared/models/unit_status.dart';
import '../utils/formatters.dart';
import 'status_badge.dart';

class UnitCard extends StatelessWidget {
  const UnitCard({
    super.key,
    required this.unit,
    required this.currency,
    this.onTap,
  });

  final Unit unit;
  final String currency;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(unit.label, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(
          '${unit.bedrooms} bed · ${formatMoney(unit.baseRent, currency)}',
        ),
        trailing: StatusBadge(
          label: unit.status.label,
          tone: unit.status == UnitStatus.occupied
              ? StatusTone.success
              : StatusTone.neutral,
        ),
        onTap: onTap,
      ),
    );
  }
}
