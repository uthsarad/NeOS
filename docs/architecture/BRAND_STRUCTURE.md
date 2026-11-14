# NeOS Brand Structure

## Brand Core
**NeOS = Next Evolution Operating System.**

The NeOS brand is built around one central promise: always push toward the **next evolution** of the operating system experience. Evolution for NeOS means practical progress, not change for its own sake.

## Brand Ethos
NeOS is grounded in adaptation and continuous refinement:

- **Evolve forward:** NeOS should continuously improve structure, defaults, and delivery as better approaches emerge.
- **Adapt with evidence:** decisions should respond to real user pain points, reliability data, and operational outcomes.
- **Fix what breaks:** if a process or choice introduces friction, NeOS should correct it quickly and fold the learning into the platform.
- **Preserve what works:** stable, proven behavior is treated as a feature and carried forward.

This ethos takes strong inspiration from biology: survival through adaptation, iteration, and selective retention of traits that improve resilience.

## Current Implementation of the Ethos
Today, NeOS expresses "next evolution" through a **rolling release foundation** inspired by Arch Linux, while adding curated control:

- Arch's rolling model provides fast access to modern packages and platform capabilities.
- NeOS introduces curation, snapshot gating, and coherence checks to reduce breakage risk.
- Updates are treated as managed evolution, not uncontrolled churn.

In short: NeOS uses Arch-inspired rolling release mechanics as a base, then adds policy and quality controls aligned with the brand promise.

## Future Evolution Principle
NeOS is not locked to one implementation forever.

If better models appear—whether technical, operational, or UX-focused—NeOS should be willing to adapt. The brand commitment is to the **outcome** (next evolution), not to permanent loyalty to a single mechanism.

## Brand Voice and Narrative
When describing NeOS publicly, messaging should consistently reflect:

1. **Progress with stability** - modern platform, predictable user experience.
2. **Adaptation over dogma** - use what works best now; improve when better paths are proven.
3. **Resilience mindset** - identify weak points early, fix quickly, and keep refining.
4. **User-centered evolution** - every change should improve real-world usability and trust.

## Internal Brand Check (Decision Filter)
Before major product or release decisions, ask:

- Does this move NeOS toward a better next state?
- Does it improve reliability or user outcomes without avoidable complexity?
- Are we fixing known pain rather than introducing novelty for branding alone?
- If a better evolution path exists, are we willing to pivot?

If the answer is "no" to most of these, the decision likely does not fit the NeOS brand structure.

## Visual Identity

One restrained accent on deep navy. The single source of truth is
[`tools/palette.json`](../../tools/palette.json); every themed file keeps its own literal
copy, and `tests/verify_palette_consistency.sh` keeps them in step.

| Token | Value | Use |
| :-- | :-- | :-- |
| `accent` | `#38bdf8` | Primary buttons, selection, focus, links, glyphs on navy |
| `accentHover` / `accentPressed` | `#7dd3fc` / `#0ea5e9` | Button hover and pressed states |
| `onAccent` | `#0A0E1A` | **Text on any accent fill** (9:1). Never white: white on the accent is 2.1:1 |
| `bg` → `bgGradientBottom` | `#0A0E1A` → `#16203A` | Backgrounds (boot splash, installer, welcome app, login) |

Rules: no emoji in shipped UI (use monochrome text glyphs in the accent colour, or
drawn shapes); one accent family only; secondary text uses `textSecondary`/`textTertiary`.

### Assets and how they are made

Every raster asset is generated, so changing the palette means re-running the generators,
not hand-editing images. Run all of them from the repository root (needs Pillow; the two
renderers need PyQt6):

| Asset | Shipped at | Generator |
| :-- | :-- | :-- |
| Logo (installer, docs, boot splash, `neos-logo` icon set for `os-release LOGO=`) | `etc/calamares/branding/neos/logo.png`, `docs/assets/neos-logo.png`, `usr/share/plymouth/themes/neos/logo.png`, `usr/share/icons/hicolor/{*x*,scalable}/apps/neos-logo.*`, `usr/share/pixmaps/neos-logo.png` | `tools/gen-logo.py --all`, rendered from `tools/brand/neos-logo.svg`, which is the website's mark (`uthsarad/NeOSweb`, `public/assets/favicon.svg`). Change the mark on the website first, then copy it here |
| Wallpaper (desktop, login background) | `usr/share/backgrounds/neos-wallpaper.png` | `tools/gen-wallpaper.py` (design reference: `tools/wallpaper-reference.html`) |
| Installer welcome banner, BIOS boot-menu background, boot-splash dot | `etc/calamares/branding/neos/welcome.png`, `profile/syslinux/splash.png`, `usr/share/plymouth/themes/neos/dot.png` | `tools/gen-brand-images.py` |
| Login theme preview (System Settings → Login Screen) | `usr/share/sddm/themes/neos/preview.png` | `tools/render-sddm-preview.py` (a real headless render of `Main.qml`) |
| Installer slideshow review images (not shipped) | — | `tools/render-installer-slides.py <dir>` |

The boot splash (`usr/share/plymouth/themes/neos/neos.script`) shows the logo with three
pulsing accent dots and handles the disk-unlock prompt. The KDE splash after login is
disabled (`etc/skel/.config/ksplashrc`), so Plymouth is the only boot screen.
`tests/verify_ui_render.sh` renders the login theme, slideshow and welcome app on every CI
run.
