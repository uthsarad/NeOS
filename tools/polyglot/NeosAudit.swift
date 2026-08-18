import Foundation

let arguments = CommandLine.arguments
let rootPath = arguments.count > 1 ? arguments[1] : "."

print("\u{001B}[1;36m[Swift::Audit]\u{001B}[0m Checking NeOS profile structure at: \(rootPath)")

let fileManager = FileManager.default
let requiredFiles = [
    "profile/profiledef.sh",
    "profile/pacman.conf",
    "profile/grub/grub.cfg",
    "profile/syslinux/syslinux.cfg",
    "profile/packages.x86_64",
    "profile/airootfs/etc/pacman.d/neos-mirrorlist"
]

var missingFiles: [String] = []
for file in requiredFiles {
    let fullPath = (rootPath as NSString).appendingPathComponent(file)
    if !fileManager.fileExists(atPath: fullPath) {
        missingFiles.append(file)
    }
}

guard missingFiles.isEmpty else {
    print("❌ Missing required profile files: \(missingFiles.joined(separator: ", "))")
    exit(1)
}

let pkgPath = (rootPath as NSString).appendingPathComponent("profile/packages.x86_64")
guard let content = try? String(contentsOfFile: pkgPath, encoding: .utf8) else {
    print("❌ Failed to read packages.x86_64")
    exit(1)
}

let lines = content.components(separatedBy: .newlines)
var seen = Set<String>()
var count = 0

for rawLine in lines {
    let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
    if line.isEmpty || line.hasPrefix("#") {
        continue
    }
    if seen.contains(line) {
        print("❌ Duplicate package found in Swift audit: \(line)")
        exit(1)
    }
    seen.insert(line)
    count += 1
}

print("\u{001B}[1;32m✓ Swift Audit Passed! Verified \(count) unique packages.\u{001B}[0m")
