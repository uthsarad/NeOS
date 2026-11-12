using System;
using System.IO;
using System.Text.Json;
using System.Threading.Tasks;

namespace Neos.Diagnostics;

public class Program
{
    public static async Task<int> Main(string[] args)
    {
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.WriteLine("=================================================================");
        Console.WriteLine("NeOS System & Compliance Diagnostics (.NET Core Engine)");
        Console.WriteLine("=================================================================");
        Console.ResetColor();

        string rootDir = Directory.GetCurrentDirectory();
        foreach (string arg in args)
        {
            if (!arg.StartsWith("--", StringComparison.Ordinal))
            {
                rootDir = arg;
                break;
            }
        }
        Console.WriteLine($"Scanning Repository Root: {rootDir}\n");

        var report = SecurityInspector.RunAudit(rootDir);

        Console.ForegroundColor = ConsoleColor.White;
        Console.WriteLine("--- Security & Performance Rule Evaluation ---");
        Console.ResetColor();

        int passed = 0;
        int failed = 0;

        foreach (var check in report.Checks)
        {
            if (check.Passed)
            {
                passed++;
                Console.ForegroundColor = ConsoleColor.Green;
                Console.Write("  [PASS] ");
                Console.ResetColor();
                Console.WriteLine($"{check.Category}: {check.Name} ({check.Detail})");
            }
            else
            {
                failed++;
                Console.ForegroundColor = ConsoleColor.Red;
                Console.Write("  [FAIL] ");
                Console.ResetColor();
                Console.WriteLine($"{check.Category}: {check.Name} - Reason: {check.Detail}");
            }
        }

        Console.WriteLine();
        Console.ForegroundColor = failed == 0 ? ConsoleColor.Green : ConsoleColor.Red;
        Console.WriteLine($"Summary: {passed} checks passed, {failed} checks failed.");
        Console.ResetColor();

        if (Array.Exists(args, a => a == "--json"))
        {
            string reportPath = Path.Combine(rootDir, "neos-diagnostics-report.json");
            string json = JsonSerializer.Serialize(report, new JsonSerializerOptions { WriteIndented = true });
            await File.WriteAllTextAsync(reportPath, json);
            Console.WriteLine($"📄 JSON Report saved to '{reportPath}'.");
        }

        return failed == 0 ? 0 : 1;
    }
}
