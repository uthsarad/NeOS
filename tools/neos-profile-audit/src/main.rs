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
    assert_profiledef_properties(root)?;

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

fn assert_profiledef_properties(root: &Path) -> Result<(), String> {
    let path = root.join("profiledef.sh");
    let content = fs::read_to_string(&path)
        .map_err(|err| format!("unable to read {}: {err}", path.display()))?;

    let valid_bootmodes = [
        "uefi.grub",
        "uefi.systemd-boot",
        "bios.syslinux",
        "bios.syslinux.mbr",
        "bios.syslinux.eltorito",
        "uefi-ia32.grub.esp",
        "uefi-x64.grub.esp",
        "uefi-x64.grub.eltorito",
    ];

    let mut pacman_conf_found = false;
    let mut bootmodes_found = false;

    // TODO(bolt): Consider optimizing this line-by-line regex-free parsing logic if profiling shows it's a bottleneck.
    // TODO(palette): Ensure these error messages are easily understandable by end users fixing their configuration.
    // TODO(sentinel): Validate that the parsed values do not introduce command injection risks if used downstream.
    for line in content.lines() {
        let trimmed = line.trim();
        if trimmed.starts_with("pacman_conf=") {
            pacman_conf_found = true;
            let val = trimmed.trim_start_matches("pacman_conf=").trim_matches(|c| c == '"' || c == '\'');
            if val.is_empty() {
                return Err("pacman_conf is set to an empty string in profiledef.sh".to_string());
            }
            let conf_path = root.join(val);
            if !conf_path.exists() {
                return Err(format!("pacman config referenced in profiledef.sh does not exist: {}", conf_path.display()));
            }
            let conf_content = fs::read_to_string(&conf_path).map_err(|err| format!("unable to read {}: {err}", conf_path.display()))?;
            if !conf_content.contains("DatabaseOptional") {
                return Err(format!("pacman config referenced in profiledef.sh ({}) does not use DatabaseOptional", conf_path.display()));
            }
        } else if trimmed.starts_with("bootmodes=(") {
            bootmodes_found = true;
            let val = trimmed.trim_start_matches("bootmodes=(").trim_end_matches(')');
            // Note: simple splitting by whitespace works because valid bootmodes don't contain spaces.
            for mode_str in val.split_whitespace() {
                let mode = mode_str.trim_matches(|c| c == '"' || c == '\'');
                if !valid_bootmodes.contains(&mode) {
                    return Err(format!("Invalid bootmode in profiledef.sh: '{}'. Valid modes are: {}", mode, valid_bootmodes.join(", ")));
                }
            }
        }
    }

    if !pacman_conf_found {
        return Err("pacman_conf is NOT set in profiledef.sh (mkarchiso will fail with realpath error)".to_string());
    }

    if !bootmodes_found {
        return Err("bootmodes array is missing in profiledef.sh".to_string());
    }

    Ok(())
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

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;
    use tempfile::tempdir;

    #[test]
    fn test_valid_profiledef() {
        let dir = tempdir().unwrap();
        let root = dir.path();

        let profiledef_content = r#"
        pacman_conf="my_pacman.conf"
        bootmodes=('uefi.grub' 'bios.syslinux')
        "#;
        fs::write(root.join("profiledef.sh"), profiledef_content).unwrap();

        let pacman_conf_content = "DatabaseOptional";
        fs::write(root.join("my_pacman.conf"), pacman_conf_content).unwrap();

        assert!(assert_profiledef_properties(root).is_ok());
    }

    #[test]
    fn test_missing_pacman_conf_file() {
        let dir = tempdir().unwrap();
        let root = dir.path();

        let profiledef_content = r#"
        pacman_conf="missing.conf"
        bootmodes=('uefi.grub')
        "#;
        fs::write(root.join("profiledef.sh"), profiledef_content).unwrap();

        let err = assert_profiledef_properties(root).unwrap_err();
        assert!(err.contains("does not exist"));
    }

    #[test]
    fn test_invalid_bootmode() {
        let dir = tempdir().unwrap();
        let root = dir.path();

        let profiledef_content = r#"
        pacman_conf="my_pacman.conf"
        bootmodes=('uefi.grub' 'invalid.mode')
        "#;
        fs::write(root.join("profiledef.sh"), profiledef_content).unwrap();

        let pacman_conf_content = "DatabaseOptional";
        fs::write(root.join("my_pacman.conf"), pacman_conf_content).unwrap();

        let err = assert_profiledef_properties(root).unwrap_err();
        assert!(err.contains("Invalid bootmode"));
    }

    #[test]
    fn test_missing_database_optional() {
        let dir = tempdir().unwrap();
        let root = dir.path();

        let profiledef_content = r#"
        pacman_conf="my_pacman.conf"
        bootmodes=('uefi.grub')
        "#;
        fs::write(root.join("profiledef.sh"), profiledef_content).unwrap();

        let pacman_conf_content = "SigLevel = Required";
        fs::write(root.join("my_pacman.conf"), pacman_conf_content).unwrap();

        let err = assert_profiledef_properties(root).unwrap_err();
        assert!(err.contains("does not use DatabaseOptional"));
    }
}
