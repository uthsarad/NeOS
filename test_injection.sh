#!/bin/bash
set -euo pipefail
# In bash, if a trap is evaluated inside single quotes:
# trap 'logger -t test "Command: \"$BASH_COMMAND\""' ERR
# When the error occurs, bash evaluates:
# logger -t test "Command: \"BASH_COMMAND_VALUE\""
# This evaluates `BASH_COMMAND_VALUE` inside double quotes, so it is safe.
# BUT wait! The prompt says: "ensure dynamically evaluated variables like $BASH_COMMAND are wrapped in double quotes within the single-quoted trap definition (e.g., trap '... "$BASH_COMMAND" ...' ERR). This ensures the delayed expansion is treated strictly as a literal string by the target command."
# So I should use "$BASH_COMMAND" instead of \"$BASH_COMMAND\"?
# Yes, because \"$BASH_COMMAND\" makes it a single argument where the double quotes are LITERAL.
# `trap '... "Command: " "$BASH_COMMAND" ...' ERR`
