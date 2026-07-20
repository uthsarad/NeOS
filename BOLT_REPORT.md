# Bolt Report

- What was optimized:
  Optimized Plymouth boot animation in `neos.script` by deduplicating frame updates. Added a `last_frame` check to ensure `SetImage()` is only called when the actual frame index changes.

- Before/after reasoning:
  Before: `SetImage()` was called unconditionally on every Plymouth tick (50Hz), even though the frame calculation `Math.Int(tick / 2)` only changes every 2 ticks (25Hz). This caused redundant texture invalidations and wasted CPU cycles during critical early boot.
  After: `SetImage()` is conditionally called only when the frame changes, eliminating 50% of the image update overhead and keeping software rendering lightweight.

- Any remaining performance risks:
  None. The logic safely prevents duplicate calls without altering the animation timing or visual appearance.