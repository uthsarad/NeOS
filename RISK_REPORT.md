# Risk & Priority Report: 2026-10-06

## Security Risks
- **Secure Boot**: User-initiated sbctl process introduces potential user error, mitigating firmware brick risk but leaving systems un-enrolled by default.

## Performance Risks
- **Live Image Size**: Increasing included packages (like WWAN) impacts RAM footprint.

## Complexity Creep
- **Feature Parity**: Emulating Ubuntu capabilities must be carefully managed to avoid abandoning the minimalist Arch ethos.
