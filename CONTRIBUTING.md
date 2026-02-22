# Contributing to NeOS

Thanks for your interest in improving NeOS! This guide covers how to propose changes and keep the project maintainable.

## Getting started

1. Fork the repository and create a feature branch from `main`.
2. Make sure your changes are focused and documented.
3. Run any relevant checks for the area you touched.
4. Open a pull request with a clear summary and testing notes.

## Development tips

- Keep commits small and descriptive.
- Update documentation whenever behavior changes.
- Include sample commands or screenshots for user-facing changes.

## Testing

We have a suite of verification scripts in the `tests/` directory to ensure the ISO configuration is valid.

To run the tests:
```bash
# Run all verification tests
for test in tests/verify_*.sh; do
    echo "Running $test..."
    bash "$test"
done
```

Please run these tests before submitting a PR to ensure your changes don't break the build or security configuration.

## Reporting issues

Please include:

- A brief summary of the problem.
- Steps to reproduce.
- Expected vs. actual behavior.
- Any logs or screenshots that help illustrate the issue.

## Code of conduct

By participating, you agree to follow the [Code of Conduct](CODE_OF_CONDUCT.md).
