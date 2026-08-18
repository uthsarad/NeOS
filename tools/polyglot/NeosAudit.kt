package neos.polyglot

import java.io.File

fun main(args: Array<String>) {
    val rootPath = if (args.isNotEmpty()) args[0] else "."
    println("\u001B[1;36m[Kotlin::Audit]\u001B[0m Checking NeOS profile structure at: $rootPath")

    val requiredFiles = listOf(
        "profile/profiledef.sh",
        "profile/pacman.conf",
        "profile/grub/grub.cfg",
        "profile/syslinux/syslinux.cfg",
        "profile/packages.x86_64",
        "profile/airootfs/etc/pacman.d/neos-mirrorlist"
    )

    val missing = requiredFiles.filter { !File(rootPath, it).exists() }
    if (missing.isNotEmpty()) {
        System.err.println("❌ Missing required profile files: ${missing.joinToString(", ")}")
        System.exit(1)
    }

    val pkgFile = File(rootPath, "profile/packages.x86_64")
    val packages = pkgFile.readLines()
        .map { it.trim() }
        .filter { it.isNotEmpty() && !it.startsWith("#") }

    val duplicates = packages.groupingBy { it }.eachCount().filter { it.value > 1 }.keys
    if (duplicates.isNotEmpty()) {
        System.err.println("❌ Duplicate packages found: ${duplicates.joinToString(", ")}")
        System.exit(1)
    }

    println("\u001B[1;32m✓ Kotlin Audit Passed! Verified ${packages.size} unique packages.\u001B[0m")
}
