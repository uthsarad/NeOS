use std::collections::HashSet;
use std::env;
use std::fs::{self, File};
use std::io::{BufRead, BufReader};
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

    let mut parsed_files: Vec<(String, HashSet<String>)> = Vec::new();
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

    // TODO(sentinel): Validate that the parsed values do not introduce command injection risks if used downstream.
    for line in content.lines() {
        if pacman_conf_found && bootmodes_found {
            break; // ⚡ Bolt: Early exit once all required properties are parsed to avoid processing the rest of the file
        }

        let trimmed = line.trim();
        if !pacman_conf_found && trimmed.starts_with("pacman_conf=") {
            pacman_conf_found = true;
            // ⚡ Bolt: Use slicing instead of trim_start_matches to avoid redundant string searching
            let val = trimmed[12..].trim_matches(|c| c == '"' || c == '\'');
            if val.is_empty() {
                return Err("pacman_conf is set to an empty string in profiledef.sh.\n\n💡 How to fix:\n  - Open 'profiledef.sh'\n  - Provide a valid file path for 'pacman_conf'.".to_string());
            }

            if val.starts_with('/')
                || val.contains("..")
                || val
                    .chars()
                    .any(|c| !c.is_alphanumeric() && c != '.' && c != '/' && c != '_' && c != '-')
            {
                return Err("pacman_conf contains invalid characters or path traversal.\n\n💡 How to fix:\n  - Ensure 'pacman_conf' in 'profiledef.sh' only contains alphanumeric characters, '.', '_', '-', and '/' without path traversal ('..') or absolute paths ('/').".to_string());
            }

            let conf_path = root.join(val);
            if !conf_path.exists() {
                return Err(format!("The pacman config referenced in profiledef.sh does not exist: {}.\n\n💡 How to fix:\n  - Verify the path provided for 'pacman_conf' in 'profiledef.sh' is correct and the file exists.", conf_path.display()));
            }
            let conf_content = fs::read_to_string(&conf_path)
                .map_err(|err| format!("unable to read {}: {err}", conf_path.display()))?;
            if !conf_content.contains("DatabaseOptional") {
                return Err(format!("The pacman config referenced in profiledef.sh ({}) does not use DatabaseOptional.\n\n💡 How to fix:\n  - Open '{}'\n  - Ensure 'SigLevel = ... DatabaseOptional' is set to allow building the ISO.", conf_path.display(), conf_path.display()));
            }
        } else if !bootmodes_found && trimmed.starts_with("bootmodes=(") {
            bootmodes_found = true;
            // ⚡ Bolt: Use slicing instead of trim_start_matches to avoid redundant string searching
            let val = trimmed[11..].trim_end_matches(')');
            // Note: simple splitting by whitespace works because valid bootmodes don't contain spaces.
            for mode_str in val.split_whitespace() {
                let mode = mode_str.trim_matches(|c| c == '"' || c == '\'');

                if mode
                    .chars()
                    .any(|c| !c.is_alphanumeric() && c != '.' && c != '-' && c != '_')
                {
                    return Err("bootmodes contains invalid characters (possible command injection).\n\n💡 How to fix:\n  - Ensure 'bootmodes' in 'profiledef.sh' only contains alphanumeric characters, '.', '-', and '_'.".to_string());
                }

                if !valid_bootmodes.contains(&mode) {
                    return Err(format!("Invalid bootmode in profiledef.sh: '{}'.\n\n💡 How to fix:\n  - Open 'profiledef.sh'\n  - Update 'bootmodes' to only include valid modes.\n  Valid modes are:\n    - {}", mode, valid_bootmodes.join("\n    - ")));
                }
            }
        }
    }

    if !pacman_conf_found {
        return Err("pacman_conf is NOT set in profiledef.sh.\n\n💡 How to fix:\n  - Open 'profiledef.sh'\n  - Set 'pacman_conf' to the path of your pacman configuration file. This property is required by mkarchiso to build the image.".to_string());
    }

    if !bootmodes_found {
        return Err("The bootmodes array is missing in profiledef.sh.\n\n💡 How to fix:\n  - Open 'profiledef.sh'\n  - Define an array of valid 'bootmodes' (e.g., bootmodes=('uefi.grub' 'bios.syslinux')).".to_string());
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
        let file =
            File::open(&path).map_err(|err| format!("unable to open {}: {err}", path.display()))?;
        let mut reader = BufReader::new(file);

        let mut has_server = false;

        // ⚡ Bolt: Reusing a single String buffer prevents per-line memory allocations when scanning
        // potentially massive mirrorlists, significantly improving stream parsing performance.
        let mut raw_line = String::new();
        while reader
            .read_line(&mut raw_line)
            .map_err(|err| format!("unable to read {}: {err}", path.display()))?
            > 0
        {
            let trimmed = raw_line.trim();
            if !trimmed.is_empty() && !trimmed.starts_with('#') && trimmed.starts_with("Server") {
                has_server = true;
                break; // ⚡ Bolt: Early exit once we find an active server entry
            }
            raw_line.clear();
        }

        if !has_server {
            return Err(format!("{} has no active Server entries", path.display()));
        }
    }

    Ok(())
}

fn parse_package_file(path: &Path) -> Result<HashSet<String>, String> {
    let file =
        File::open(path).map_err(|err| format!("unable to open {}: {err}", path.display()))?;
    let mut reader = BufReader::new(file);

    let mut packages = HashSet::new();
    let mut duplicates = HashSet::new();

    // ⚡ Bolt: Reusing a single String buffer across the loop prevents per-line memory allocations,
    // which is critical for performance when parsing large package lists or skipping numerous comment sections.
    let mut raw_line = String::new();

    for index in 0.. {
        raw_line.clear();
        if reader
            .read_line(&mut raw_line)
            .map_err(|err| format!("unable to read {}: {err}", path.display()))?
            == 0
        {
            break;
        }

        let trimmed = raw_line.trim();
        if trimmed.is_empty() || trimmed.starts_with('#') {
            continue;
        }

        if trimmed.chars().any(|c| {
            !c.is_alphanumeric() && c != '-' && c != '_' && c != '.' && c != '@' && c != '+'
        }) {
            return Err(format!(
                "{}:{} contains invalid characters or whitespace in package entry (possible terminal injection)",
                path.display(),
                index + 1
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

fn assert_required_packages(parsed_files: &[(String, HashSet<String>)]) -> Result<(), String> {
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

fn assert_arch_specific_expectations(
    parsed_files: &[(String, HashSet<String>)],
) -> Result<(), String> {
    let mut x86_opt = None;
    let mut i686_opt = None;
    let mut aarch64_opt = None;

    // Single pass over parsed_files avoids repeated iterator setup and redundant linear scans
    for (name, pkgs) in parsed_files {
        match name.as_str() {
            "packages.x86_64" => x86_opt = Some(pkgs),
            "packages.i686" => i686_opt = Some(pkgs),
            "packages.aarch64" => aarch64_opt = Some(pkgs),
            _ => {}
        }
    }

    let x86 = x86_opt.ok_or_else(|| "missing package set for packages.x86_64".to_string())?;
    let i686 = i686_opt.ok_or_else(|| "missing package set for packages.i686".to_string())?;
    let aarch64 =
        aarch64_opt.ok_or_else(|| "missing package set for packages.aarch64".to_string())?;

    if !(x86.contains("linux") && x86.contains("linux-zen")) {
        return Err("packages.x86_64 must include both linux and linux-zen kernels".to_string());
    }

    if i686.len() < 45 {
        return Err("packages.i686 unexpectedly small (expected at least 45 packages)".to_string());
    }
    if aarch64.len() < 45 {
        return Err(
            "packages.aarch64 unexpectedly small (expected at least 45 packages)".to_string(),
        );
    }

    Ok(())
}

fn build_summary(parsed_files: &[(String, HashSet<String>)]) -> String {
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

        lines.push(format!(
            "- common across all architectures: {} packages",
            common.len()
        ));
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

    #[test]
    fn test_path_traversal() {
        let dir = tempdir().unwrap();
        let root = dir.path();

        let profiledef_content = r#"
        pacman_conf="../etc/pacman.conf"
        bootmodes=('uefi.grub')
        "#;
        fs::write(root.join("profiledef.sh"), profiledef_content).unwrap();

        let err = assert_profiledef_properties(root).unwrap_err();
        assert!(err.contains("invalid characters or path traversal"));
    }

    #[test]
    fn test_absolute_path() {
        let dir = tempdir().unwrap();
        let root = dir.path();

        let profiledef_content = r#"
        pacman_conf="/etc/pacman.conf"
        bootmodes=('uefi.grub')
        "#;
        fs::write(root.join("profiledef.sh"), profiledef_content).unwrap();

        let err = assert_profiledef_properties(root).unwrap_err();
        assert!(err.contains("invalid characters or path traversal"));
    }

    #[test]
    fn test_bootmode_command_injection() {
        let dir = tempdir().unwrap();
        let root = dir.path();

        let profiledef_content = r#"
        pacman_conf="my_pacman.conf"
        bootmodes=('uefi.grub' '`echo malicious`')
        "#;
        fs::write(root.join("profiledef.sh"), profiledef_content).unwrap();

        let pacman_conf_content = "DatabaseOptional";
        fs::write(root.join("my_pacman.conf"), pacman_conf_content).unwrap();

        let err = assert_profiledef_properties(root).unwrap_err();
        assert!(err.contains("bootmodes contains invalid characters (possible command injection)"));
    }

    #[test]
    fn test_package_file_terminal_injection() {
        let dir = tempdir().unwrap();
        let root = dir.path();
        let path = root.join("packages.x86_64");

        // Write a package name that contains an escape sequence to simulate terminal injection
        // \x1b is the escape character
        let package_content = "valid-package\n\x1b[31mmalicious-package\x1b[0m\nanother-valid";
        fs::write(&path, package_content).unwrap();

        let err = parse_package_file(&path).unwrap_err();
        assert!(err.contains("contains invalid characters or whitespace in package entry (possible terminal injection)"));
    }
}
