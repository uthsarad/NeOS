import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: root
    
    property var snapshots: []
    
    Component.onCompleted: loadSnapshots()
    
    function loadSnapshots() {
        // In a real implementation, this would use a system call to get snapshots
        // For now, we'll simulate with dummy data
        snapshots = [
            { date: "2026-01-30 14:30", number: "15", description: "Post-automatic-update-20260130_143015" },
            { date: "2026-01-23 14:30", number: "12", description: "Post-automatic-update-20260123_143015" },
            { date: "2026-01-16 14:30", number: "9", description: "Post-automatic-update-20260116_143015" },
            { date: "2026-01-09 14:30", number: "6", description: "Post-automatic-update-20260109_143015" },
            { date: "2026-01-02 14:30", number: "3", description: "Post-automatic-update-20260102_143015" },
            { date: "2025-12-26 10:15", number: "1", description: "Initial system installation" }
        ];
        
        // Update UI
        snapshotList.model = snapshots;
    }
    
    function rollbackToSnapshot(snapshotNumber) {
        // In a real implementation, this would execute the rollback command
        console.log("Would rollback to snapshot: " + snapshotNumber);
        // Execute rollback command
        // const proc = Qt.createQmlObject("import QtCore; Process {}", root);
        // proc.program = "pkexec";
        // proc.arguments = ["sh", "-c", `snapper rollback ${snapshotNumber} && reboot`];
        // proc.start();
    }
    
    Flickable {
        anchors.fill: parent
        contentHeight: mainLayout.implicitHeight
        
        ColumnLayout {
            id: mainLayout
            anchors.fill: parent
            spacing: 20
            
            Label {
                text: "NeOS System Restore"
                font.pointSize: 16
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }
            
            Label {
                text: "Select a system snapshot to restore from:"
                font.pointSize: 12
                Layout.leftMargin: 20
            }
            
            ListView {
                id: snapshotList
                Layout.fillWidth: true
                Layout.preferredHeight: 400
                clip: true
                focus: true
                
                delegate: ItemDelegate {
                    width: ListView.view.width
                    padding: 15
                    
                    Accessible.role: Accessible.ListItem
                    Accessible.name: "Snapshot " + modelData.number + " from " + modelData.date + ". " + modelData.description

                    Column {
                        anchors.fill: parent
                        
                        Row {
                            spacing: 10
                            
                            Label {
                                text: "Snapshot #" + modelData.number
                                font.bold: true
                            }
                            
                            Label {
                                text: "(" + modelData.date + ")"
                                color: "gray"
                            }
                        }
                        
                        Label {
                            text: modelData.description
                            font.pixelSize: 12
                            wrapMode: Text.Wrap
                            width: parent.width - 40
                        }
                    }
                    
                    highlighted: ListView.isCurrentItem
                    
                    onClicked: {
                        // Show confirmation dialog before rollback
                        if (confirmDialog) {
                            confirmDialog.snapshotNumber = modelData.number;
                            confirmDialog.open();
                        }
                    }
                }
            }

            Label {
                text: "No snapshots found. Click Refresh or check your configuration."
                visible: snapshotList.count === 0
                Layout.alignment: Qt.AlignHCenter
                font.italic: true
                color: "gray"
            }
            
            Button {
                text: "Refresh Snapshots"
                Layout.alignment: Qt.AlignHCenter

                Accessible.name: "Refresh Snapshots"
                Accessible.description: "Reloads the list of system snapshots from disk."

                ToolTip.visible: hovered
                ToolTip.text: "Reload available snapshots"

                onClicked: loadSnapshots()
            }
        }
    }
    
    // Confirmation Dialog
    Popup {
        id: confirmDialog
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: 400
        height: 200
        modal: true
        focus: true
        
        property string snapshotNumber: ""
        
        Column {
            anchors.centerIn: parent
            spacing: 20
            
            Label {
                text: "Confirm System Rollback"
                font.bold: true
                font.pointSize: 14
            }
            
            Label {
                text: "Are you sure you want to rollback to snapshot #" + confirmDialog.snapshotNumber + "? " +
                      "This will restore your system to the state at that time and reboot the computer."
                wrapMode: Text.Wrap
                width: parent.width - 40
            }
            
            Row {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter
                
                Button {
                    text: "Rollback & Reboot"
                    Accessible.name: "Rollback and Reboot"
                    Accessible.description: "Restores the system to the selected snapshot and restarts the computer immediately."
                    onClicked: {
                        rollbackToSnapshot(confirmDialog.snapshotNumber);
                        confirmDialog.close();
                    }
                }
                
                Button {
                    text: "Cancel"
                    Accessible.name: "Cancel"
                    Accessible.description: "Closes this dialog without making changes."
                    onClicked: confirmDialog.close()
                }
            }
        }
    }
}
