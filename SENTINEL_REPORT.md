## Risks Found
- Medium: Local Denial of Service (DoS) vulnerability in the root autoupdate script when invoking notify-send across user-controlled DBus sessions without a timeout.

## Fixes Applied
- Wrapped the outbound notify-send IPC call with a strict timeout 10s to ensure the root process cannot be hung by a frozen or malicious user DBus session.

## Remaining Attack Surface
- The script relies on user-controlled DBus boundaries for notifications. While the timeout mitigates hanging, underlying DBus vulnerabilities or notification spamming could still be a minor concern.

## Severity Summary
- 1 Medium severity issue resolved.
