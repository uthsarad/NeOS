## 2024-07-20 - Plymouth Refresh Rate Optimization
**Learning:** Plymouth's `SetRefreshFunction` callback fires at approximately 50Hz regardless of the intended animation speed. Unconditionally updating sprites based on a divided tick counter causes severe redundant redraws in software rendering.
**Action:** Always wrap `SetImage()` calls in Plymouth scripts with a state tracker (e.g., `if (frame != last_frame)`) to prevent unnecessary texture invalidations.
