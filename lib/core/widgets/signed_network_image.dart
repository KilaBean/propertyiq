import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Renders an image from a signed URL, cached to disk and memory by the
/// underlying storage path rather than the URL itself.
///
/// Every signed URL in this app is a *fresh* token each time it's requested
/// (`createSignedUrl`, ~1 hour expiry), so caching by URL string — what a
/// bare `Image.network` does via Flutter's default in-memory `ImageCache` —
/// barely hits: the same unchanged photo re-downloads on every screen visit
/// once its signed URL has been re-fetched. [cacheKey] should be the stable
/// storage path the URL was signed for (the same one used to request it),
/// which is what actually identifies the image across re-signings.
///
/// [displayWidth]/[displayHeight], given, size the *decoded* bitmap to match
/// how large the image is actually painted (in logical pixels — this scales
/// by the device's pixel ratio itself), rather than decoding a multi-hundred
/// KB original just to paint a 44×44 thumbnail. Leave both null for a
/// full-resolution view (a photo viewer, say).
class SignedNetworkImage extends StatelessWidget {
  const SignedNetworkImage({
    super.key,
    required this.url,
    required this.cacheKey,
    this.fit = BoxFit.cover,
    this.displayWidth,
    this.displayHeight,
    this.placeholder,
    this.errorWidget,
  });

  final String url;
  final String cacheKey;
  final BoxFit fit;
  final double? displayWidth;
  final double? displayHeight;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return CachedNetworkImage(
      imageUrl: url,
      cacheKey: cacheKey,
      fit: fit,
      memCacheWidth:
          displayWidth == null ? null : (displayWidth! * dpr).round(),
      memCacheHeight:
          displayHeight == null ? null : (displayHeight! * dpr).round(),
      // Matches CLAUDE.md's motion guidance (150-250ms fade) rather than the
      // package default's longer crossfade.
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 150),
      placeholder: placeholder == null ? null : (_, _) => placeholder!,
      errorWidget: (_, _, _) =>
          errorWidget ?? const Icon(Icons.broken_image_outlined),
    );
  }
}
