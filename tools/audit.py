#!/usr/bin/env python3
"""Run repository gates with explicit coverage, bounded execution, and reports."""
import argparse
import datetime
import json
import os
import re
from pathlib import Path
import shlex
import shutil
import signal
import subprocess
import sys
import tempfile
import time


def snapshot(root, dest):
    """Preserve current edits and git executable/symlink modes on Windows mounts."""
    entries = subprocess.check_output(
        ["git", "ls-files", "--stage", "-z"], cwd=root
    ).decode().split("\0")
    modes = {}
    for entry in filter(None, entries):
        meta, name = entry.split("\t", 1)
        modes[name] = meta.split()[0]
    names = subprocess.check_output(
        ["git", "ls-files", "--cached", "--others", "--exclude-standard", "-z"], cwd=root
    ).decode().split("\0")
    for name in sorted(set(filter(None, names))):
        source, target = root / name, dest / name
        if not source.exists() and not source.is_symlink():
            continue
        target.parent.mkdir(parents=True, exist_ok=True)
        if source.is_symlink() or modes.get(name) == "120000":
            target.symlink_to(os.readlink(source) if source.is_symlink() else source.read_text())
        else:
            shutil.copyfile(source, target)
            is_exec = modes.get(name) == "100755" or (name not in modes and os.access(source, os.X_OK))
            target.chmod(0o755 if is_exec else 0o644)


def run(root, args, output):
    gates = sorted((root / "tests").glob("verify_*.sh"))
    results = []
    env = os.environ.copy()
    env["REQUIRE_TOOLS"] = "1" if args.strict else "0"
    for gate in gates:
        name = gate.name
        reason = None
        if args.only and name not in args.only:
            continue
        if name in {"verify_iso_calamares_libs.sh", "verify_iso_smoketest.sh"}:
            reason = "requires a built ISO; run through build.sh"
        elif name == "verify_ui_render.sh" and not args.include_ui:
            reason = "UI rendering not requested (use --include-ui)"
        if reason:
            results.append({"check": name, "status": "skipped", "reason": reason})
            print(f"SKIPPED {name}: {reason}", flush=True)
            continue
        timeout = args.timeout
        if any(lang in name for lang in ("rust", "go_", "ruby", "csharp")):
            timeout = max(timeout, 420)
        start = time.monotonic()
        log = output / (gate.stem + ".log")
        command = ["bash", str(gate.relative_to(root))]
        backend = "host"
        if name == "verify_install_repo.sh" and getattr(args, "arch_container", False):
            command = ["docker", "run", "--rm", "--mount",
                       f"type=bind,source={root},target=/repo,readonly", "--workdir", "/repo",
                       "archlinux:latest", "bash", str(gate.relative_to(root))]
            backend = "arch-container"
        with log.open("wb") as stream:
            process = subprocess.Popen(
                command, cwd=root, env=env,
                stdin=subprocess.DEVNULL, stdout=stream, stderr=subprocess.STDOUT,
                start_new_session=True,
            )
            try:
                code = process.wait(timeout=timeout)
                status = "passed" if code == 0 else "failed"
            except subprocess.TimeoutExpired:
                os.killpg(process.pid, signal.SIGKILL)
                process.wait()
                code, status = 124, "timeout"
        text = log.read_text(errors="replace")
        # Existing gates can return zero after declining to execute a tool.
        incomplete = bool(re.search(
            r"(?im)^\s*\[(?:WARN|INFO)\].*(?:not installed|missing|skipp|static(?:ally| check only))", text
        ))
        if status == "passed" and incomplete:
            status = "incomplete"
        results.append({"check": name, "status": status, "exit_code": code,
                        "seconds": round(time.monotonic() - start, 2), "log": log.name, "backend": backend})
        print(f"{status.upper()} {name} ({results[-1]['seconds']}s)", flush=True)
    summary = {"time": datetime.datetime.now(datetime.timezone.utc).isoformat(),
               "strict": args.strict, "results": results}
    (output / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
    counts = {status: sum(r["status"] == status for r in results)
              for status in ("passed", "failed", "timeout", "incomplete", "skipped")}
    print(json.dumps(counts), flush=True)
    print(f"Reports: {output}", flush=True)
    return int(any(r["status"] in ("failed", "timeout") or
                   (args.strict and r["status"] == "incomplete") for r in results))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--strict", action="store_true", help="fail on missing tools or incomplete checks")
    parser.add_argument("--arch-container", action="store_true", help="run the Arch-only repository gate in Docker (archlinux:latest)")
    parser.add_argument("--include-ui", action="store_true", help="include offscreen GUI render gates")
    parser.add_argument("--timeout", type=int, default=120, help="seconds per ordinary gate")
    parser.add_argument("--output", type=Path, default=Path("reports/audit-latest"))
    parser.add_argument("--only", action="append", help="run a named verify_*.sh gate (repeatable)")
    parser.add_argument("--snapshot", action="store_true", help="test current files in a temporary Linux copy")
    args = parser.parse_args()
    if args.timeout < 1:
        parser.error("--timeout must be positive")
    root = Path(__file__).resolve().parents[1]
    known = {p.name for p in (root / "tests").glob("verify_*.sh")}
    if args.only and set(args.only) - known:
        parser.error("unknown gate: " + ", ".join(sorted(set(args.only) - known)))
    if os.name == "nt":
        # Pass a shell-quoted command to WSL; never interpolate unquoted paths.
        path = subprocess.check_output(["wsl", "--exec", "wslpath", "-a", "-u", str(root)]).decode().strip()
        forwarded = list(sys.argv[1:])
        # Resolve report paths in the caller's Windows filesystem before crossing WSL.
        linux_output = subprocess.check_output(
            ["wsl", "--exec", "wslpath", "-a", "-u", str(args.output.resolve())]
        ).decode().strip()
        for index, value in enumerate(forwarded):
            if value == "--output":
                forwarded[index + 1] = linux_output
            elif value.startswith("--output="):
                forwarded[index] = "--output=" + linux_output
        command = ["python3", path + "/tools/audit.py", *forwarded]
        if not args.snapshot:
            command.append("--snapshot")
        return subprocess.call(["wsl", "--exec", "bash", "-lc", "cd " + shlex.quote(path) + " && " + shlex.join(command)])
    if args.arch_container and not shutil.which("docker"):
        parser.error("--arch-container requires Docker")
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    if args.snapshot:
        with tempfile.TemporaryDirectory(prefix="neos-audit-") as folder:
            isolated = Path(folder)
            snapshot(root, isolated)
            return run(isolated, args, output)
    return run(root, args, output)


if __name__ == "__main__":
    sys.exit(main())
