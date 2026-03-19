import unittest
from unittest.mock import patch, mock_open, MagicMock
import importlib.machinery
import importlib.util
import sys
import os

# Load the target module
file_path = "airootfs/usr/local/bin/neos-driver-manager"
if not os.path.exists(file_path):
    file_path = os.path.join(os.getcwd(), file_path)

loader = importlib.machinery.SourceFileLoader("neos_driver_manager", file_path)
spec = importlib.util.spec_from_loader(loader.name, loader)
neos_driver_manager = importlib.util.module_from_spec(spec)
loader.exec_module(neos_driver_manager)
sys.modules["neos_driver_manager"] = neos_driver_manager

class TestPciIO(unittest.TestCase):
    def setUp(self):
        # Reset cache before each test
        neos_driver_manager._PCI_DEVICES_CACHE = None

    @patch("os.path.isdir")
    @patch("os.listdir")
    @patch("builtins.open", new_callable=mock_open)
    @patch("neos_driver_manager.run_command")
    def test_filtered_io(self, mock_run_command, mock_file, mock_listdir, mock_isdir):
        # Setup mocks
        def isdir_side_effect(path):
            if path == "/sys/bus/pci/devices":
                return True
            if path.startswith("/sys/bus/pci/devices/"):
                return True
            return False

        mock_isdir.side_effect = isdir_side_effect
        mock_listdir.return_value = ["0000:00:02.0", "0000:04:03.0"]

        # Mock file contents
        file_contents = {
            "/sys/bus/pci/devices/0000:00:02.0/vendor": "0x8086\n",
            "/sys/bus/pci/devices/0000:00:02.0/device": "0x1916\n",
            "/sys/bus/pci/devices/0000:00:02.0/class": "0x030000\n", # GPU
            "/sys/bus/pci/devices/0000:04:03.0/vendor": "0x10ec\n",
            "/sys/bus/pci/devices/0000:04:03.0/device": "0x0887\n",
            "/sys/bus/pci/devices/0000:04:03.0/class": "0x040300\n", # Audio
        }

        def open_side_effect(filename, *args, **kwargs):
            if filename in file_contents:
                return mock_open(read_data=file_contents[filename]).return_value
            raise FileNotFoundError(f"File not found: {filename}")

        mock_file.side_effect = open_side_effect

        # Call get_pci_controllers asking for GPU ("03")
        # After optimization, it should call get_pci_devices(class_prefixes=("03",))
        # and skip reading vendor/device for class 0403.

        controllers = neos_driver_manager.get_pci_controllers(class_prefixes=("03",))

        self.assertEqual(len(controllers), 1)
        self.assertEqual(controllers[0]['class'], "0300")

        # Verify IO calls
        # We expect open call for GPU class, vendor, device
        mock_file.assert_any_call("/sys/bus/pci/devices/0000:00:02.0/class", "r")
        mock_file.assert_any_call("/sys/bus/pci/devices/0000:00:02.0/vendor", "r")
        mock_file.assert_any_call("/sys/bus/pci/devices/0000:00:02.0/device", "r")

        # We expect open call for Audio class
        mock_file.assert_any_call("/sys/bus/pci/devices/0000:04:03.0/class", "r")

        # ⚡ Bolt: CRITICAL ASSERTION
        # We expect NO open call for Audio vendor/device because class 0403 doesn't match 03 prefix

        # Helper to check if a file was opened
        def was_opened(path):
            for call in mock_file.call_args_list:
                if call[0][0] == path:
                    return True
            return False

        if was_opened("/sys/bus/pci/devices/0000:04:03.0/vendor"):
            raise AssertionError("Optimization failed: Opened vendor file for skipped device!")

        if was_opened("/sys/bus/pci/devices/0000:04:03.0/device"):
            raise AssertionError("Optimization failed: Opened device file for skipped device!")

if __name__ == '__main__':
    unittest.main()
