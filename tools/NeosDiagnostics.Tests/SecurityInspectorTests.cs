using System;
using System.IO;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Neos.Diagnostics;

namespace NeosDiagnostics.Tests
{
    [TestClass]
    public class SecurityInspectorTests
    {
        private string? _tempPath;

        [TestInitialize]
        public void Setup()
        {
            _tempPath = Path.Combine(Path.GetTempPath(), Guid.NewGuid().ToString());
            Directory.CreateDirectory(_tempPath);
        }

        [TestCleanup]
        public void Cleanup()
        {
            if (_tempPath != null && Directory.Exists(_tempPath))
            {
                Directory.Delete(_tempPath, true);
            }
        }

        [TestMethod]
        public void RunAudit_AllFilesExistAndValid_ShouldPassAllChecks()
        {
            // Arrange
            var airootfsEtc = Path.Combine(_tempPath!, "profile", "airootfs", "etc");
            var sysctlDir = Path.Combine(airootfsEtc, "sysctl.d");
            Directory.CreateDirectory(sysctlDir);

            var secSysctlPath = Path.Combine(sysctlDir, "90-neos-security.conf");
            File.WriteAllText(secSysctlPath, "kernel.unprivileged_bpf_disabled = 1\nnet.ipv4.tcp_syncookies = 1\nnet.ipv4.conf.all.rp_filter = 1");

            var perfSysctlPath = Path.Combine(sysctlDir, "99-neos-performance.conf");
            File.WriteAllText(perfSysctlPath, "vm.swappiness = 100\nnet.ipv4.tcp_congestion_control = bbr");

            var pacmanConfPath = Path.Combine(_tempPath!, "profile", "pacman.conf");
            File.WriteAllText(pacmanConfPath, "DatabaseOptional");

            // Act
            var report = SecurityInspector.RunAudit(_tempPath!);

            // Assert
            Assert.IsNotNull(report);
            Assert.IsTrue(report.Checks.All(c => c.Passed));
        }

        [TestMethod]
        public void RunAudit_MissingFiles_ShouldFailPresenceChecks()
        {
            // Act
            var report = SecurityInspector.RunAudit(_tempPath!);

            // Assert
            Assert.IsNotNull(report);
            Assert.IsFalse(report.Checks.First(c => c.Name == "90-neos-security.conf presence").Passed);
            Assert.IsFalse(report.Checks.First(c => c.Name == "99-neos-performance.conf presence").Passed);
            Assert.IsFalse(report.Checks.First(c => c.Name == "pacman.conf presence").Passed);
        }

        [TestMethod]
        public void RunAudit_PacmanConfWithTrustAll_ShouldFail()
        {
            // Arrange
            var pacmanConfPath = Path.Combine(_tempPath!, "profile", "pacman.conf");
            Directory.CreateDirectory(Path.GetDirectoryName(pacmanConfPath)!);
            File.WriteAllText(pacmanConfPath, "DatabaseOptional\nTrustAll");

            // Act
            var report = SecurityInspector.RunAudit(_tempPath!);

            // Assert
            var check = report.Checks.First(c => c.Name == "Pacman Signature Enforcement");
            Assert.IsFalse(check.Passed);
        }

        [TestMethod]
        public void RunAudit_SysctlInvalidSettings_ShouldFail()
        {
            // Arrange
            var airootfsEtc = Path.Combine(_tempPath!, "profile", "airootfs", "etc");
            var sysctlDir = Path.Combine(airootfsEtc, "sysctl.d");
            Directory.CreateDirectory(sysctlDir);

            var secSysctlPath = Path.Combine(sysctlDir, "90-neos-security.conf");
            File.WriteAllText(secSysctlPath, "kernel.unprivileged_bpf_disabled = 0\nnet.ipv4.tcp_syncookies = 0\nnet.ipv4.conf.all.rp_filter = 0");

            var perfSysctlPath = Path.Combine(sysctlDir, "99-neos-performance.conf");
            File.WriteAllText(perfSysctlPath, "vm.swappiness = 60\nnet.ipv4.tcp_congestion_control = cubic");

            var pacmanConfPath = Path.Combine(_tempPath!, "profile", "pacman.conf");
            File.WriteAllText(pacmanConfPath, "DatabaseOptional");

            // Act
            var report = SecurityInspector.RunAudit(_tempPath!);

            // Assert
            Assert.IsFalse(report.Checks.First(c => c.Name == "Kernel BPF Restrictions").Passed);
            Assert.IsFalse(report.Checks.First(c => c.Name == "SYN Cookies (DoS Protection)").Passed);
            Assert.IsFalse(report.Checks.First(c => c.Name == "Reverse Path Filtering").Passed);
            Assert.IsFalse(report.Checks.First(c => c.Name == "ZRAM Swappiness Tuning").Passed);
            Assert.IsFalse(report.Checks.First(c => c.Name == "TCP BBR Congestion Control").Passed);
        }
    }
}
