import QtQuick 2.0
import QtQuick.XmlListModel 2.0
// Note: This module assumes a QML environment where the 'Process' type is available,
// typically provided by a custom C++ plugin or a specific Qt module (e.g., via a helper library).
// If 'Process' is not available standardly, this implementation serves as a blueprint for the
// required logic, needing only the specific import or type name adjustment for the target environment.

Item {
    id: root
    property var snapshots: []

    // Timer to trigger the load
    Timer {
        id: loadTimer
        interval: 1000
        repeat: false
        running: true
        onTriggered: {
            fetchSnapshots()
        }
    }

    // Execute sh to handle redirection of snapper output to XML file.
    // We use /root/snapshots.xml to avoid security risks associated with /tmp (symlink attacks).
    // The Calamares process runs as root in the live environment, so this is safe and permissible.
    Process {
        id: snapperProcess
        command: "sh"
        arguments: ["-c", "snapper list --xml > /root/snapshots.xml"]

        onFinished: {
             if (exitCode === 0) {
                 snapshotModel.reload()
             } else {
                 console.warn("Snapper list failed with exit code: " + exitCode)
                 root.snapshots = [] // Clear snapshots on failure
             }
        }

        // Error handling if Process supports it
        onErrorOccurred: {
            console.warn("Process error: " + error)
            root.snapshots = []
        }
    }

    function fetchSnapshots() {
        // Start process if not running
        if (snapperProcess.state !== Process.Running) {
             snapperProcess.start()
        }
    }

    XmlListModel {
        id: snapshotModel
        source: "file:///root/snapshots.xml"
        query: "/snapper-snapshots/snapshot"

        XmlRole { name: "id"; query: "id/string()" }
        XmlRole { name: "type"; query: "type/string()" }
        XmlRole { name: "pre"; query: "pre/string()" }
        XmlRole { name: "date"; query: "date/string()" }
        XmlRole { name: "user"; query: "user/string()" }
        XmlRole { name: "cleanup"; query: "cleanup/string()" }
        XmlRole { name: "description"; query: "description/string()" }

        onStatusChanged: {
            if (status === XmlListModel.Ready) {
                var newSnapshots = []
                for (var i = 0; i < count; i++) {
                    newSnapshots.push({
                        "id": get(i).id,
                        "type": get(i).type,
                        "pre": get(i).pre,
                        "date": get(i).date,
                        "user": get(i).user,
                        "cleanup": get(i).cleanup,
                        "description": get(i).description
                    })
                }
                root.snapshots = newSnapshots
                console.log("Snapshots loaded: " + newSnapshots.length)
            } else if (status === XmlListModel.Error) {
                console.warn("XmlListModel error: " + errorString())
            }
        }
    }
}
