import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: root
    
    property var snapshots: []
    property bool isLoading: false
    
    Component.onCompleted: loadSnapshots()
    
    function loadSnapshots() {
        if (isLoading) return;
        isLoading = true;
        // Simulate async loading
        loadTimer.start();
    }

    Timer {
        id: loadTimer
        interval: 1000
        repeat: false
        onTriggered: {
            // In a real implementation, this would use a system call to get snapshots
            // For now, we'll simulate with dummy data
            var data = [
                { date: "2026-01-30 14:30", number: "15", description: "Post-automatic-update-20260130_143015" },
                { date: "2026-01-23 14:30", number: "12", description: "Post-automatic-update-20260123_143015" },
                { date: "2026-01-16 14:30", number: "9", description: "Post-automatic-update-20260116_143015" },
                { date: "2026-01-09 14:30", number: "6", description: "Post-automatic-update-20260109_143015" },
                { date: "2026-01-02 14:30", number: "3", description: "Post-automatic-update-20260102_143015" },
                { date: "2025-12-26 10:15", number: "1", description: "Initial system installation" }
            ];

            // ⚡ Bolt: Pre-calculate relative time strings to avoid re-calculation during scrolling
            // This moves O(n) Date creation from the render loop (binding) to the load phase
            for (var i = 0; i < data.length; i++) {
                data[i].ago = root.timeAgo(data[i].date);
            }

            snapshots = data;

            // Update UI
            snapshotList.model = snapshots;
            isLoading = false;

            if (snapshotList.count > 0) {
                snapshotList.currentIndex = 0;
                snapshotList.forceActiveFocus();
            }
        }
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

    function timeAgo(dateString) {
        var date = new Date(dateString);
        var now = new Date();
        var diff = Math.floor((now.getTime() - date.getTime()) / 1000);

        if (diff < 60) return qsTr("just now");

        var m = Math.floor(diff / 60);
        if (m < 60) return m === 1 ? qsTr("1 minute ago") : qsTr("%1 minutes ago").arg(m);

        var h = Math.floor(m / 60);
        if (h < 24) return h === 1 ? qsTr("1 hour ago") : qsTr("%1 hours ago").arg(h);

        var d = Math.floor(h / 24);
        if (d < 30) return d === 1 ? qsTr("1 day ago") : qsTr("%1 days ago").arg(d);

        return "";
    }
    
    Flickable {
        anchors.fill: parent
        contentHeight: mainLayout.implicitHeight
        
        ColumnLayout {
            id: mainLayout
            anchors.fill: parent
            spacing: 20
            
            Label {
                text: qsTr("NeOS System Restore")
                font.pointSize: 16
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }
            
            Label {
                text: qsTr("Select a system snapshot to restore from:")
                font.pointSize: 12
                Layout.leftMargin: 20
            }
            
            StackLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 400
                currentIndex: isLoading ? 2 : (snapshotList.count > 0 ? 0 : 1)

                ListView {
                    id: snapshotList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    focus: true
                    
                    // ⚡ Bolt: Enable item reuse for smoother scrolling performance
                    reuseItems: true

                    Accessible.name: qsTr("System Snapshots")

                    delegate: ItemDelegate {
                        id: snapshotDelegate
                        width: ListView.view.width
                        padding: 15
                        
                        KeyNavigation.right: restoreButton

                        Accessible.role: Accessible.ListItem
                        Accessible.name: qsTr("Snapshot %1 from %2. %3").arg(modelData.number).arg(modelData.date).arg(modelData.description)

                        contentItem: RowLayout {
                            spacing: 15
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Row {
                                    spacing: 10

                                    Label {
                                        text: qsTr("Snapshot #%1").arg(modelData.number)
                                        font.bold: true
                                        textFormat: Text.PlainText
                                    }

                                    Label {
                                        // ⚡ Bolt: Use pre-calculated relative time
                                        text: modelData.date + (modelData.ago ? " • " + modelData.ago : "")
                                        color: snapshotDelegate.highlighted ? palette.highlightedText : palette.text
                                        opacity: snapshotDelegate.highlighted ? 0.8 : 0.6
                                        textFormat: Text.PlainText
                                    }
                                }

                                Label {
                                    text: modelData.description
                                    font.pixelSize: 12
                                    wrapMode: Text.Wrap
                                    Layout.fillWidth: true
                                    textFormat: Text.PlainText
                                }
                            }
                            
                            Button {
                                id: restoreButton
                                text: qsTr("Restore...")
                                highlighted: true

                                KeyNavigation.left: snapshotDelegate

                                onClicked: {
                                    if (confirmDialog) {
                                        confirmDialog.snapshotNumber = modelData.number;
                                        confirmDialog.open();
                                    }
                                }

                                ToolTip.visible: hovered || activeFocus
                                ToolTip.text: qsTr("Restore system to this snapshot")
                                ToolTip.delay: 500

                                Accessible.name: qsTr("Restore snapshot %1").arg(modelData.number)
                                Accessible.description: qsTr("Restores the system to this snapshot")
                            }
                        }
                        
                        highlighted: ListView.isCurrentItem

                        onClicked: {
                           ListView.view.currentIndex = index
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 15
                    
                    Item { Layout.fillHeight: true }

                    Label {
                        text: "📂"
                        font.pixelSize: 48
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Label {
                        text: qsTr("No Snapshots Found")
                        font.bold: true
                        font.pointSize: 14
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: qsTr("Check your configuration or try refreshing.")
                        color: palette.text
                        opacity: 0.6
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Button {
                        text: qsTr("Refresh Now")
                        Layout.alignment: Qt.AlignHCenter
                        onClicked: loadSnapshots()
                        Accessible.name: qsTr("Refresh Now")
                        Accessible.description: qsTr("Reloads the list of system snapshots.")

                        ToolTip.visible: hovered || activeFocus
                        ToolTip.text: qsTr("Reload available snapshots (F5)")
                    }

                    Item { Layout.fillHeight: true }
                }

                // Loading State (Index 2)
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Item { Layout.fillHeight: true }

                    BusyIndicator {
                        running: root.isLoading
                        Layout.alignment: Qt.AlignHCenter

                        Accessible.name: qsTr("Loading snapshots")
                        Accessible.role: Accessible.Animation
                    }

                    Label {
                        text: qsTr("Loading snapshots...")
                        color: palette.text
                        opacity: 0.6
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Item { Layout.fillHeight: true }
                }
            }
            
            Button {
                text: qsTr("Refresh Snapshots")
                visible: snapshotList.count > 0
                enabled: !isLoading
                Layout.alignment: Qt.AlignHCenter

                Accessible.name: qsTr("Refresh Snapshots")
                Accessible.description: qsTr("Reloads the list of system snapshots from disk.")

                ToolTip.visible: hovered || activeFocus
                ToolTip.text: qsTr("Reload available snapshots (F5)")

                onClicked: loadSnapshots()
            }
        }
    }
    
    Shortcut {
        sequence: StandardKey.Refresh
        onActivated: loadSnapshots()
    }

    Shortcut {
        sequence: "Ctrl+R"
        onActivated: loadSnapshots()
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
        
        onOpened: cancelButton.forceActiveFocus()

        Column {
            anchors.centerIn: parent
            spacing: 20
            
            Accessible.role: Accessible.Dialog
            Accessible.name: qsTr("Confirm System Rollback")
            Accessible.description: warningLabel.text

            Label {
                text: qsTr("Confirm System Rollback")
                font.bold: true
                font.pointSize: 14
            }
            
            Label {
                id: warningLabel
                textFormat: Text.RichText
                text: qsTr("Are you sure you want to rollback to snapshot #%1? This will <b>restore your system</b> to the state at that time and <b>reboot the computer</b>.").arg(confirmDialog.snapshotNumber)
                wrapMode: Text.Wrap
                width: parent.width - 40
            }
            
            Row {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter
                
                Button {
                    text: qsTr("Rollback & Reboot")
                    Accessible.name: qsTr("Rollback and Reboot")
                    Accessible.description: qsTr("Restores the system to the selected snapshot and restarts the computer immediately.")

                    ToolTip.visible: hovered || activeFocus
                    ToolTip.text: qsTr("Warning: This will reboot your computer immediately")
                    ToolTip.delay: 500

                    onClicked: {
                        rollbackToSnapshot(confirmDialog.snapshotNumber);
                        confirmDialog.close();
                    }
                }
                
                Button {
                    id: cancelButton
                    text: qsTr("Cancel")
                    Accessible.name: qsTr("Cancel")
                    Accessible.description: qsTr("Closes this dialog without making changes.")

                    ToolTip.visible: hovered || activeFocus
                    ToolTip.text: qsTr("Close without changes")
                    ToolTip.delay: 500

                    onClicked: confirmDialog.close()
                }
            }
        }
    }
}
