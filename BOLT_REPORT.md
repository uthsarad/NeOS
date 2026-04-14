# BOLT REPORT: User Enumeration Optimization

## Optimization Implemented
In `airootfs/usr/local/bin/neos-autoupdate.sh`, the logic for notifying active users about insufficient disk space was optimized. The previous implementation iterated over active sessions using `loginctl list-sessions`, piping the output through `awk` and `sort`, and then invoking an `id -nu` subprocess for each session to retrieve the username. This was replaced with a more direct approach using `while read -r uid user_name _ ; do ... done < <(loginctl list-users --no-legend)`.

## Before/After Reasoning
- **Before:** The code used `for uid in $(loginctl list-sessions --no-legend | awk '{print $2}' | sort -u); do ... user_name=$(id -nu "$uid") ... done`. This approach spawned a pipeline with multiple processes (`loginctl`, `awk`, `sort`) and then executed a new `id` process for every iteration inside the loop. This incurs significant fork/exec overhead, especially on systems with multiple users or if the notification loop runs frequently.
- **After:** The new approach uses `loginctl list-users --no-legend`, which outputs the UID and username on the same line natively. The output is processed directly by a bash `while read` loop. This completely eliminates the need for the `awk | sort` pipeline and removes the repeated `id -nu` subshell entirely, minimizing the performance penalty.

## Remaining Performance Risks
The optimization speeds up the execution by reducing fork/exec overhead. However, the internal call inside the loop (`su - "$user_name" -c "..."`) still requires an external process creation for `su` and `notify-send`. If a system has a massive number of active users, this could theoretically cause a slight bottleneck. However, for a typical desktop or limited multi-user environment, this risk is negligible. No significant remaining performance risks are identified in this block.
