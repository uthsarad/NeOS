## 2025-02-23 - [Standardize Error Handling]
**Vulnerability:** [Inconsistent error handling and trap usage in core bash scripts leading to potential command injection or exit code masking.]
**Learning:** [Shell trap commands executing arbitrary strings without sanitation pose high risks; evaluating variables inside unquoted trap bodies can lead to command injection.]
**Prevention:** [Standardize error handler functions that securely evaluate parameters and use properly constructed traps (`trap '_error_handler $? $LINENO' ERR`) to avoid evaluation issues.]
