# .claude/skills/logo-asset-pipeline/SKILL.md

---

name: propertyiq-logo-asset-pipeline
description: Turning an AI-generated logo image into real, theme-safe app assets (launcher icon + wordmark)

Use when: the user picks/uploads a logo image (from Gemini/ChatGPT/etc.) and
wants it wired into the app as the launcher icon and/or an in-app wordmark.

## The core problem

AI image generators render logos on a page, not a transparent canvas. The
result always has SOME background baked in — sometimes an obvious white
rectangle, sometimes a barely-visible "card" tint (as low as 1-8 RGB units
off pure white — indistinguishable from PNG noise/anti-aliasing by eye). If
you paste that straight into the app it shows as a floating box that doesn't
match the light/dark theme.

## Environment gotcha (check this first, every time)

On this machine `convert` resolves to the **Windows built-in disk-conversion
utility**, NOT ImageMagick. Never invoke bare `convert` for image work — it
is a genuinely dangerous name collision. There is no `magick` binary
installed either. Use **Python + Pillow + numpy** instead (already
installed: Pillow 12.1.1, numpy 1.26.4). Verify before assuming:

```bash
python -c "import PIL, numpy; print(PIL.__version__, numpy.__version__)"
```

## Step 1 — find the source file

Chat-attached images aren't directly readable as files. They're almost
always auto-saved to Downloads by the browser/generator. Search recent
files, not by name (generators use generic names like "Generated Image…"):

```bash
find "/c/Users/<user>/Downloads" -maxdepth 2 -type f \
  \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.webp" \) \
  -newermt "-30 minutes"
```

If several candidates exist, `Read` each one and visually compare against
what the user showed in chat before picking one — don't guess.

## Step 2 — the extraction technique (this is the reusable part)

**Don't try to sample/extract the source's background color.** It's often
too close to white to distinguish from noise. Instead:

1. Compute `dist_from_white = 255 - arr.min(axis=2)` per pixel (low for
   white/near-white, high for saturated color).
2. **Histogram it** and look for a gap: `np.unique(dist, return_counts=True)`.
   Noise/anti-aliasing clusters low (often 0-30); real glyph/text color
   clusters much higher (100+) with a visible empty gap between them. This
   check is mandatory — don't guess a threshold, confirm the gap exists.
3. Threshold **inside that gap**, not at its edge, and prefer a **hard
   cutoff** (`alpha = 255 if dist > T else 0`) over a soft ramp for icon
   marks — a soft ramp can pick up faint card-edge antialiasing as a visible
   ghost ring around the glyph. A narrow, tightly-bounded ramp is fine for
   text (nicer curve edges) since text has a wide safety margin from the gap.

```python
from PIL import Image
import numpy as np

img = Image.open(SRC).convert("RGB")
arr = np.array(img).astype(int)
dist = 255 - arr.min(axis=2)

vals, counts = np.unique(dist, return_counts=True)
for v, c in zip(vals, counts):
    if c > 100: print(v, c)   # eyeball the gap before picking T

mask = dist > T                      # T chosen from the gap above
ys, xs = np.where(mask)
x0, y0, x1, y1 = xs.min(), ys.min(), xs.max(), ys.max()
glyph = img.crop((x0, y0, x1 + 1, y1 + 1))

garr = np.array(glyph).astype(int)
alpha = np.where(255 - garr.min(axis=2) > T, 255, 0).astype(np.uint8)
rgba = np.dstack([np.array(glyph), alpha])
Image.fromarray(rgba, "RGBA").save("out.png")
```

## Step 3a — building the app launcher icon (opaque, square)

Don't try to preserve the source's own backdrop card — composite the
extracted glyph onto **the app's own established brand backdrop color**
(check the theme file, e.g. `lib/core/theme/app_colors.dart`, for the
existing pale token rather than inventing a new one).

Generate, from one 1024×1024 flattened composite:
- `assets/branding/<name>_icon_only.png` — the flattened composite, for
  reuse anywhere in-app.
- Legacy launcher icons at `android/app/src/main/res/mipmap-{mdpi,hdpi,
  xhdpi,xxhdpi,xxxhdpi}/ic_launcher.png` (48/72/96/144/192px).
- Adaptive icon layers: `drawable/ic_launcher_foreground.png` (the glyph
  ALONE, transparent bg, scaled to ~55% of a 1024 canvas — safely inside
  Android's ~66% adaptive-icon safe zone) and `drawable/ic_launcher_background.png`
  (solid brand color, same 1024 canvas). These are combined by the existing
  `mipmap-anydpi-v26/ic_launcher.xml` — don't recreate that file.
- Splash: `drawable-nodpi/launch_image.png` (360×360), referenced by
  `drawable/launch_background.xml` and `drawable-v21/launch_background.xml`
  — check those already point at it before assuming you need to edit them.

Round the legacy icon's corners yourself (`ImageDraw.rounded_rectangle` as
an alpha mask) — most launchers apply their own mask too, but this keeps the
fallback icon looking intentional.

**After changing the launcher icon, Android may cache the old one per
install.** If it doesn't visually update after `flutter run` reinstalls,
uninstall the app first, then reinstall.

## Step 3b — building an in-app wordmark (transparent, theme-aware)

For a logo+text lockup used inside the app UI (e.g. an auth-screen header),
transparency alone isn't enough if any text is dark-colored — it will
vanish on a dark theme. So:

1. Extract to transparent PNG as in Step 2 → this is the **light-mode**
   variant, save as `assets/branding/<name>_logo_with_text.png`.
2. Build a **dark-mode** variant from the same alpha mask: identify which
   pixels are the dark/neutral text (vs. the brand-color glyph elements,
   which usually read fine on both light and dark surfaces) — a channel
   threshold works, e.g. "blue channel < 150 among colored pixels" isolates
   navy text from a blue glyph. Recolor those pixels to a light theme token
   (check the theme's dark-mode text color, e.g. `textPrimaryDark`). Leave
   the brand-color glyph pixels untouched. Save as
   `assets/branding/<name>_logo_with_text_dark.png`.
3. **Verify by compositing both onto swatches of the app's actual light and
   dark background colors** (not white) before wiring anything in — this is
   the only reliable way to confirm blending actually worked:

```python
light_bg = Image.new('RGB', size, LIGHT_BG_TOKEN)
light_bg.paste(light_logo, (0,0), light_logo)   # third arg = use alpha as mask
dark_bg = Image.new('RGB', size, DARK_BG_TOKEN)
dark_bg.paste(dark_logo, (0,0), dark_logo)
```

4. Register both files individually in `pubspec.yaml` under `flutter: assets:`
   (this project lists each asset explicitly, not folder-wildcarded — check
   the existing list style before adding a wildcard).
5. Wire the widget to pick the variant via `Theme.of(context).brightness`:

```dart
final asset = Theme.of(context).brightness == Brightness.dark
    ? 'assets/branding/<name>_logo_with_text_dark.png'
    : 'assets/branding/<name>_logo_with_text.png';
```

## Step 4 — cleanup + validate + deploy

- Delete every temp script/copy/preview you created in `assets/branding/`
  before finishing — only the final named PNGs should remain there.
- `flutter analyze` then `flutter test` — if any widget test asserted on a
  `Text('AppName')` that you replaced with an `Image.asset`, update the
  assertion (e.g. `find.byType(Image)`) rather than leaving it broken.
- Deploy to the connected device and visually confirm both the icon and any
  themed wordmark, in both light and dark mode if the device supports
  toggling it.
