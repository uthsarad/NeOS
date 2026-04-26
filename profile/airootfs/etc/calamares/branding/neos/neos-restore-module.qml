import QtQuick 2.15

Item {
    id: root

    function rollbackToSnapshot(snapshotNumber) {
        snapperProcess.snapshotNumber = snapshotNumber;
        snapperProcess.start();
    }

    Process {
        id: snapperProcess
        property int snapshotNumber: 0
        command: "snapper"
        args: ["--config=root", "undochange", snapshotNumber]
    }
}
