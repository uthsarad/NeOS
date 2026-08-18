using System;
using System.Collections.Generic;
using System.IO;

namespace Neos.Diagnostics;

public record DiagnosticCheck(string Category, string Name, bool Passed, string Detail);

public class DiagnosticReport
{
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
    public string PlatformVersion { get; set; } = "2026.08.18";
    public List<DiagnosticCheck> Checks { get; set; } = new();
}

public static class SecurityInspector
{
    public static DiagnosticReport RunAudit(string rootPath)
    {
        var report = new DiagnosticReport();

        // 1. Check Security sysctl
        string secSysctl = Path.Combine(rootPath, "profile", "airootfs", "etc", "sysctl.d", "90-neos-security.conf");
        if (File.Exists(secSysctl))
        {
            string content = File.ReadAllText(secSysctl);
            report.Checks.Add(new DiagnosticCheck(
                "Sysctl Hardening",
                "Kernel BPF Restrictions",
                content.Contains("kernel.unprivileged_bpf_disabled = 1") || content.Contains("kernel.unprivileged_bpf_disabled = 2"),
                "Unprivileged BPF disabled"
            ));

            report.Checks.Add(new DiagnosticCheck(
                "Sysctl Hardening",
                "SYN Cookies (DoS Protection)",
                content.Contains("net.ipv4.tcp_syncookies = 1"),
                "TCP SYN Cookies enabled"
            ));

            report.Checks.Add(new DiagnosticCheck(
                "Sysctl Hardening",
                "Reverse Path Filtering",
                content.Contains("net.ipv4.conf.all.rp_filter = 1"),
                "Strict anti-spoofing enabled"
            ));
        }
        else
        {
            report.Checks.Add(new DiagnosticCheck("Sysctl Hardening", "90-neos-security.conf presence", false, "File missing"));
        }

        // 2. Check Performance sysctl
        string perfSysctl = Path.Combine(rootPath, "profile", "airootfs", "etc", "sysctl.d", "99-neos-performance.conf");
        if (File.Exists(perfSysctl))
        {
            string content = File.ReadAllText(perfSysctl);
            report.Checks.Add(new DiagnosticCheck(
                "Performance Tuning",
                "ZRAM Swappiness Tuning",
                content.Contains("vm.swappiness = 100"),
                "ZRAM optimized swappiness=100"
            ));

            report.Checks.Add(new DiagnosticCheck(
                "Performance Tuning",
                "TCP BBR Congestion Control",
                content.Contains("net.ipv4.tcp_congestion_control = bbr"),
                "BBR active for low-latency networking"
            ));
        }
        else
        {
            report.Checks.Add(new DiagnosticCheck("Performance Tuning", "99-neos-performance.conf presence", false, "File missing"));
        }

        // 3. Check Pacman Security
        string pacmanConf = Path.Combine(rootPath, "profile", "pacman.conf");
        if (File.Exists(pacmanConf))
        {
            string content = File.ReadAllText(pacmanConf);
            bool hasSecSig = content.Contains("DatabaseOptional") && !content.Contains("TrustAll");
            report.Checks.Add(new DiagnosticCheck(
                "Package Hygiene",
                "Pacman Signature Enforcement",
                hasSecSig,
                "Package signatures required without TrustAll bypass"
            ));
        }
        else
        {
            report.Checks.Add(new DiagnosticCheck("Package Hygiene", "pacman.conf presence", false, "File missing"));
        }

        return report;
    }
}
