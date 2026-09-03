import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:propertyiq/core/widgets/signed_network_image.dart';

/// Every signed URL in this app is a fresh token per fetch, so caching by URL
/// string (what a bare Image.network would do) barely hits. This pins that
/// the widget keys its cache by the stable storage path instead, and that it
/// asks for a decode size that accounts for device pixel ratio rather than
/// the raw logical size.
void main() {
  Widget wrap(Widget child, {double devicePixelRatio = 1}) {
    return MediaQuery(
      data: MediaQueryData(devicePixelRatio: devicePixelRatio),
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  testWidgets('caches by the storage path, not the signed URL', (tester) async {
    await tester.pumpWidget(wrap(
      const SignedNetworkImage(
        url: 'https://example.supabase.co/storage/v1/object/sign/p1?token=abc',
        cacheKey: 'property-photos/p1/cover.jpg',
      ),
    ));

    final widget = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(widget.cacheKey, 'property-photos/p1/cover.jpg');
    expect(
      widget.imageUrl,
      'https://example.supabase.co/storage/v1/object/sign/p1?token=abc',
    );
  });

  testWidgets('scales the decode target by the device pixel ratio',
      (tester) async {
    await tester.pumpWidget(wrap(
      const SignedNetworkImage(
        url: 'https://example.com/a.jpg',
        cacheKey: 'a.jpg',
        displayWidth: 44,
        displayHeight: 88,
      ),
      devicePixelRatio: 3,
    ));

    final widget = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    // Logical size × device pixel ratio -- decoding at the logical size on a
    // 3x device would leave the thumbnail visibly soft.
    expect(widget.memCacheWidth, 132);
    expect(widget.memCacheHeight, 264);
  });

  testWidgets('leaves the decode size unconstrained when none is given',
      (tester) async {
    await tester.pumpWidget(wrap(
      const SignedNetworkImage(url: 'https://example.com/a.jpg', cacheKey: 'a.jpg'),
    ));

    final widget = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(widget.memCacheWidth, isNull);
    expect(widget.memCacheHeight, isNull);
  });
}
