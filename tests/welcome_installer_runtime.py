"""Exercise the real welcome widget's asynchronous launcher lifecycle offscreen."""
import os
import pathlib
import runpy
import tempfile
import time
from unittest.mock import patch

os.environ['QT_QPA_PLATFORM'] = 'offscreen'
os.environ['USER'] = 'liveuser'
from PyQt6.QtCore import QProcess
from PyQt6.QtWidgets import QApplication, QMessageBox

app = QApplication([])
namespace = runpy.run_path('profile/airootfs/usr/local/bin/neos-welcome-app')
Welcome = namespace['NeosWelcome']


def wait(window):
    deadline = time.monotonic() + 5
    while window.installer is not None and time.monotonic() < deadline:
        app.processEvents()
        time.sleep(0.01)
    assert window.installer is None, 'Launcher did not finish'


with tempfile.TemporaryDirectory() as temp:
    launcher = pathlib.Path(temp) / 'launcher'

    class TestProcess(QProcess):
        def start(self, program, arguments):
            assert program == '/usr/local/bin/neos-welcome'
            super().start(str(launcher), arguments)

    with patch.dict(Welcome.run_installer.__globals__, QProcess=TestProcess), \
            patch.object(QMessageBox, 'critical') as critical:
        window = Welcome()
        window.show()
        window.run_installer()  # Missing executable must be visible and retryable.
        wait(window)
        assert critical.call_count == 1
        assert window.isVisible() and window.primary_button.isEnabled()

        launcher.write_text('#!/bin/sh\necho "test launch failure"\nexit 1\n')
        launcher.chmod(0o755)
        window.run_installer()
        process = window.installer
        window.run_installer()
        assert window.installer is process, 'Duplicate click started another launcher'
        assert not window.primary_button.isEnabled()
        wait(window)
        assert critical.call_count == 2
        assert 'test launch failure' in critical.call_args.args[2]
        assert window.isVisible() and window.primary_button.isEnabled()

        launcher.write_text('#!/bin/sh\nsleep 0.1\nexit 0\n')
        window.run_installer()
        window.close()
        assert window.isVisible(), 'Closing welcome destroyed the running launcher'
        wait(window)
        assert critical.call_count == 2, 'Successful launch reported an error'
        assert window.isVisible() and window.primary_button.isEnabled()
        window.close()

        with patch.dict(Welcome.closeEvent.__globals__, is_live_mode=lambda: False), \
                patch.dict(os.environ, XDG_CONFIG_HOME=temp):
            installed = Welcome()
            installed.show()
            installed.close()
            assert (pathlib.Path(temp) / 'neos/firstboot-done').is_file()

print('[PASS] Installer start failure, nonzero exit, retry, duplicate click and success')
