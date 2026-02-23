import unittest
from unittest.mock import patch, mock_open, MagicMock
import importlib.machinery
import importlib.util
import sys
import os

# Load the target module
# We use importlib because the file has no extension
file_path = "airootfs/usr/local/bin/neos-driver-manager"
if not os.path.exists(file_path):
    # Try relative path if running from repo root
    file_path = os.path.join(os.getcwd(), file_path)

loader = importlib.machinery.SourceFileLoader("neos_driver_manager", file_path)
spec = importlib.util.spec_from_loader(loader.name, loader)
neos_driver_manager = importlib.util.module_from_spec(spec)
loader.exec_module(neos_driver_manager)
sys.modules["neos_driver_manager"] = neos_driver_manager

class TestPciOptimization(unittest.TestCase):
    def setUp(self):
        # Reset cache before each test
        neos_driver_manager._PCI_DEVICES_CACHE = None

    @patch("os.path.isdir")
    @patch("os.listdir")
    @patch("builtins.open", new_callable=mock_open)
    @patch("neos_driver_manager.run_command")
    def test_sysfs_optimization(self, mock_run_command, mock_file, mock_listdir, mock_isdir):
        # Setup mocks for sysfs directory check
        # We need isdir to return True for /sys/bus/pci/devices AND the device directories
        def isdir_side_effect(path):
            if path == "/sys/bus/pci/devices":
                return True
            if path.startswith("/sys/bus/pci/devices/"):
                return True
            return False

        mock_isdir.side_effect = isdir_side_effect
        mock_listdir.return_value = ["0000:00:02.0", "0000:03:00.0"]

        # Mock file contents
        file_contents = {
            "/sys/bus/pci/devices/0000:00:02.0/vendor": "0x8086\n",
            "/sys/bus/pci/devices/0000:00:02.0/device": "0x1916\n",
            "/sys/bus/pci/devices/0000:00:02.0/class": "0x030000\n",
            "/sys/bus/pci/devices/0000:03:00.0/vendor": "0x10de\n",
            "/sys/bus/pci/devices/0000:03:00.0/device": "0x1c03\n",
            "/sys/bus/pci/devices/0000:03:00.0/class": "0x030200\n",
        }

        def open_side_effect(filename, *args, **kwargs):
            if filename in file_contents:
                return mock_open(read_data=file_contents[filename]).return_value
            # For other files (e.g. imports or whatever), delegate or fail
            raise FileNotFoundError(f"File not found: {filename}")

        mock_file.side_effect = open_side_effect

        # Run the function
        devices = neos_driver_manager.get_all_pci_devices(force_refresh=True)

        # Verify results
        self.assertEqual(len(devices), 2)

        # Check first device (Intel iGPU)
        dev1 = next(d for d in devices if d['vendor'] == "8086")
        self.assertEqual(dev1['device'], "1916")
        self.assertEqual(dev1['class'], "0300") # 030000 -> 0300

        # Check second device (Nvidia)
        dev2 = next(d for d in devices if d['vendor'] == "10de")
        self.assertEqual(dev2['device'], "1c03")
        self.assertEqual(dev2['class'], "0302") # 030200 -> 0302

        # Verify lspci was NOT called
        mock_run_command.assert_not_called()

    @patch("os.path.isdir")
    @patch("neos_driver_manager.run_command")
    def test_fallback_to_lspci(self, mock_run_command, mock_isdir):
        # Simulate sysfs not available
        mock_isdir.return_value = False

        # Mock lspci output
        mock_run_command.return_value = '"00:02.0" "0300" "8086" "1916"\n"03:00.0" "0302" "10de" "1c03"'

        # Run function
        devices = neos_driver_manager.get_all_pci_devices(force_refresh=True)

        # Verify results
        self.assertEqual(len(devices), 2)
        dev1 = next(d for d in devices if d['vendor'] == "8086")
        self.assertEqual(dev1['class'], "0300")

        # Verify lspci WAS called
        mock_run_command.assert_called_once()
        args, _ = mock_run_command.call_args
        self.assertIn("/usr/bin/lspci", args[0])

if __name__ == '__main__':
    unittest.main()
