# Stale remote branches (2026-10-03)

Every remote branch except `main` and `testing` is a Jules bot branch with no pull request.
Their code changes were ported to `testing` in `dbf1cb8`; the rest is persona-report churn.
They are safe to delete. The cloud session that found them is not allowed to delete branches
(its git proxy refuses ref deletion), so run this from a clone with push access:

```bash
git push origin --delete \
  bolt/optimize-pacman-needed-17895896702666167495 \
  maestro-strategic-assessment-12678252523668915066 \
  palette-ux-build-errors-7247122620271887850 \
  sentinel-enforce-hkps-4563116103901002078
```

To stop new ones piling up, enable **Settings → General → Automatically delete head
branches** on GitHub. Restore a deleted branch with `git push origin <sha>:refs/heads/<name>`.

| Branch | Tip | Last commit |
| :-- | :-- | :-- |
| `bolt/optimize-pacman-needed-17895896702666167495` | `e6528430370c3ce7aeda31e76d83e109999f40d5` | 2026-10-03, ⚡ Bolt: Optimize pacman package installation |
| `maestro-strategic-assessment-12678252523668915066` | `2bd7ff823f463634f9d8cabc4faa348e8b54d76e` | 2026-10-02, Generate strategic directives and assessment reports |
| `palette-ux-build-errors-7247122620271887850` | `4112a245ae3ea26f8975b705f088ac682e0c5af1` | 2026-10-03, 🎨 Palette: Improve dependency error UX in build script |
| `sentinel-enforce-hkps-4563116103901002078` | `eaf80fe2395f9889dbff766b9023b746a5fb7b33` | 2026-10-03, Enforce TLS encryption (HKPS) for GPG keyserver fetches |
