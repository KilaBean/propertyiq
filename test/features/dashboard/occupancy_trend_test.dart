import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:propertyiq/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:propertyiq/features/tenancies/data/repositories/tenancy_repository.dart';

class MockTenancyRepository extends Mock implements TenancyRepository {}

/// The occupancy chart counts a unit as occupied in a month when any tenancy
/// overlaps it, including tenancies that have since ended. That date-range
/// arithmetic is the only real logic on the dashboard, and it is easy to get
/// off by a month at the boundaries.
void main() {
  late MockTenancyRepository repo;

  setUp(() => repo = MockTenancyRepository());

  String ym(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-01';

  ProviderContainer build({
    required int totalUnits,
    required List<Map<String, dynamic>> ranges,
  }) {
    when(() => repo.fetchDateRanges()).thenAnswer((_) async => ranges);
    final container = ProviderContainer(
      overrides: [
        tenancyRepositoryProvider.overrideWithValue(repo),
        dashboardStatsProvider.overrideWith(
          (ref) async => DashboardStats(
            propertyCount: 1,
            unitCount: totalUnits,
            occupiedCount: 0,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('returns six points, oldest first, for the monthly period', () async {
    final container = build(totalUnits: 2, ranges: const []);

    final points = await container
        .read(occupancyTrendProvider(OccupancyPeriod.monthly).future);

    expect(points, hasLength(6));
    expect(points.every((p) => p.rate == 0), isTrue);
  });

  test('returns five points for the yearly period', () async {
    final container = build(totalUnits: 2, ranges: const []);

    final points = await container
        .read(occupancyTrendProvider(OccupancyPeriod.yearly).future);

    expect(points, hasLength(5));
    final now = DateTime.now();
    expect(points.last.label, '${now.year}');
    expect(points.first.label, '${now.year - 4}');
  });

  test('an open-ended tenancy occupies every month from its start', () async {
    final now = DateTime.now();
    final container = build(
      totalUnits: 2,
      ranges: [
        {
          'unit_id': 'u1',
          'start_date': ym(DateTime(now.year, now.month - 5, 1)),
          'end_date': null,
        },
      ],
    );

    final points = await container
        .read(occupancyTrendProvider(OccupancyPeriod.monthly).future);

    // One of two units, every month in the window.
    expect(points.every((p) => p.rate == 50), isTrue);
  });

  test('a tenancy that ended still counts for the months it covered',
      () async {
    final now = DateTime.now();
    final container = build(
      totalUnits: 1,
      ranges: [
        {
          'unit_id': 'u1',
          'start_date': ym(DateTime(now.year, now.month - 5, 1)),
          'end_date': ym(DateTime(now.year, now.month - 4, 1)),
        },
      ],
    );

    final points = await container
        .read(occupancyTrendProvider(OccupancyPeriod.monthly).future);

    // Occupied for the first two buckets, vacant afterwards — history is not
    // rewritten just because the tenancy is over.
    expect(points[0].rate, 100);
    expect(points[1].rate, 100);
    expect(points[2].rate, 0);
    expect(points[5].rate, 0);
  });

  test('two tenancies on the same unit are not double counted', () async {
    final now = DateTime.now();
    final start = ym(DateTime(now.year, now.month - 1, 1));
    final container = build(
      totalUnits: 1,
      ranges: [
        {'unit_id': 'u1', 'start_date': start, 'end_date': null},
        {'unit_id': 'u1', 'start_date': start, 'end_date': null},
      ],
    );

    final points = await container
        .read(occupancyTrendProvider(OccupancyPeriod.monthly).future);

    expect(points.last.rate, 100);
  });

  test('is zero rather than NaN when the portfolio has no units', () async {
    final now = DateTime.now();
    final container = build(
      totalUnits: 0,
      ranges: [
        {
          'unit_id': 'u1',
          'start_date': ym(DateTime(now.year, now.month, 1)),
          'end_date': null,
        },
      ],
    );

    final points = await container
        .read(occupancyTrendProvider(OccupancyPeriod.monthly).future);

    expect(points.every((p) => p.rate == 0), isTrue);
  });

  test('rows with a null start date are skipped, not crashed on', () async {
    final container = build(
      totalUnits: 1,
      ranges: [
        {'unit_id': 'u1', 'start_date': null, 'end_date': null},
      ],
    );

    final points = await container
        .read(occupancyTrendProvider(OccupancyPeriod.monthly).future);

    expect(points.every((p) => p.rate == 0), isTrue);
  });
}
