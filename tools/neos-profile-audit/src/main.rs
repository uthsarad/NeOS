use std::collections::{BTreeSet, HashSet};
use std::env;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::ExitCode;

const PACKAGE_FILES: [&str; 3] = ["packages.x86_64", "packages.i686", "packages.aarch64"];
const REQUIRED_PROFILE_FILES: [&str; 6] = [
    "profiledef.sh",
    "pacman.conf",
    "grub/grub.cfg",
    "syslinux/syslinux.cfg",
    "airootfs/etc/pacman.d/neos-mirrorlist",
    "airootfs/etc/pacman.d/chaotic-mirrorlist",
];
const REQUIRED_ALL_ARCH_PACKAGES: [&str; 6] = [
    "base",
    "mkinitcpio",
    "mkinitcpio-archiso",
    "networkmanager",
    "sudo",
    "vim",
];

fn main() -> ExitCode {
    let root = parse_root_arg();

    match run_audit(&root) {
        Ok(summary) => {
            println!("✅ NeOS profile audit passed");
            println!("{summary}");
            ExitCode::SUCCESS
        }
        Err(err) => {
            eprintln!("❌ NeOS profile audit failed: {err}");
            ExitCode::from(1)
        }
    }
}

fn parse_root_arg() -> PathBuf {
    let mut args = env::args().skip(1);
    let mut root = PathBuf::from(".");

    while let Some(arg) = args.next() {
        if arg == "--root" {
            if let Some(value) = args.next() {
                root = PathBuf::from(value);
            }
        }
    }

    root
}

fn run_audit(root: &Path) -> Result<String, String> {
    assert_required_files(root)?;
    assert_mirrorlists_have_servers(root)?;

    let mut parsed_files: Vec<(String, BTreeSet<String>)> = Vec::new();
    for relative in PACKAGE_FILES {
        let path = root.join(relative);
        let packages = parse_package_file(&path)?;
        parsed_files.push((relative.to_string(), packages));
    }

    assert_required_packages(&parsed_files)?;
    assert_arch_specific_expectations(&parsed_files)?;

    Ok(build_summary(&parsed_files))
}

fn assert_required_files(root: &Path) -> Result<(), String> {
    for relative in REQUIRED_PROFILE_FILES {
        let path = root.join(relative);
        if !path.exists() {
            return Err(format!("missing required file: {}", path.display()));
        }
    }

    Ok(())
}

fn assert_mirrorlists_have_servers(root: &Path) -> Result<(), String> {
    let mirrorlists = [
        root.join("airootfs/etc/pacman.d/neos-mirrorlist"),
        root.join("airootfs/etc/pacman.d/chaotic-mirrorlist"),
    ];

    for path in mirrorlists {
        let content = fs::read_to_string(&path)
            .map_err(|err| format!("unable to read {}: {err}", path.display()))?;

        let has_server = content.lines().map(str::trim).any(|line| {
            !line.is_empty() && !line.starts_with('#') && line.starts_with("Server")
        });

        if !has_server {
            return Err(format!(
                "{} has no active Server entries",
                path.display()
            ));
        }
    }

    Ok(())
}

fn parse_package_file(path: &Path) -> Result<BTreeSet<String>, String> {
    let content =
        fs::read_to_string(path).map_err(|err| format!("unable to read {}: {err}", path.display()))?;

    let mut packages = BTreeSet::new();
    let mut duplicates = HashSet::new();

    for (index, raw_line) in content.lines().enumerate() {
        let trimmed = raw_line.trim();
        if trimmed.is_empty() || trimmed.starts_with('#') {
            continue;
        }

        if trimmed.contains(char::is_whitespace) {
            return Err(format!(
                "{}:{} contains invalid whitespace in package entry `{}`",
                path.display(),
                index + 1,
                trimmed
            ));
        }

        if !packages.insert(trimmed.to_string()) {
            duplicates.insert(trimmed.to_string());
        }
    }

    if packages.is_empty() {
        return Err(format!("{} contains no packages", path.display()));
    }

    if !duplicates.is_empty() {
        let mut list: Vec<String> = duplicates.into_iter().collect();
        list.sort();
        return Err(format!(
            "{} contains duplicate package entries: {}",
            path.display(),
            list.join(", ")
        ));
    }

    Ok(packages)
}

fn assert_required_packages(parsed_files: &[(String, BTreeSet<String>)]) -> Result<(), String> {
    for (name, packages) in parsed_files {
        let mut missing = Vec::new();
        for required in REQUIRED_ALL_ARCH_PACKAGES {
            if !packages.contains(required) {
                missing.push(required);
            }
        }

        if !missing.is_empty() {
            return Err(format!(
                "{name} is missing required packages: {}",
                missing.join(", ")
            ));
        }
    }

    Ok(())
}

fn assert_arch_specific_expectations(parsed_files: &[(String, BTreeSet<String>)]) -> Result<(), String> {
    let get = |name: &str| -> Result<&BTreeSet<String>, String> {
        parsed_files
            .iter()
            .find(|(n, _)| n == name)
            .map(|(_, pkgs)| pkgs)
            .ok_or_else(|| format!("missing package set for {name}"))
    };

    let x86 = get("packages.x86_64")?;
    if !(x86.contains("linux") && x86.contains("linux-zen")) {
        return Err("packages.x86_64 must include both linux and linux-zen kernels".to_string());
    }

    let i686 = get("packages.i686")?;
    let aarch64 = get("packages.aarch64")?;
    if i686.len() < 45 {
        return Err("packages.i686 unexpectedly small (expected at least 45 packages)".to_string());
    }
    if aarch64.len() < 45 {
        return Err("packages.aarch64 unexpectedly small (expected at least 45 packages)".to_string());
    }

    Ok(())
}

fn build_summary(parsed_files: &[(String, BTreeSet<String>)]) -> String {
    let mut lines = Vec::new();

    for (name, packages) in parsed_files {
        lines.push(format!("- {name}: {} unique packages", packages.len()));
    }

    if let Some((_, baseline)) = parsed_files.first() {
        let common = parsed_files
            .iter()
            .skip(1)
            .fold(baseline.clone(), |acc, (_, packages)| {
                acc.intersection(packages).cloned().collect()
            });

        lines.push(format!("- common across all architectures: {} packages", common.len()));
    }

    lines.join("\n")
}
