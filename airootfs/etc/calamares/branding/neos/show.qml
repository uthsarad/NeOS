import QtQuick 2.0;
import Calamares 1.0;

Presentation {
    id: presentation
    // ⚡ Palette: Use reference counting for pause state to handle multiple sources (hover, focus)
    property int pauseLocks: 0
    property bool paused: pauseLocks > 0
    focus: true

    Keys.onLeftPressed: presentation.advance()
    Keys.onRightPressed: presentation.advance()
    Keys.onSpacePressed: presentation.advance()
    Keys.onReturnPressed: presentation.advance()
    Keys.onEnterPressed: presentation.advance()

    Timer {
        interval: 5000
        // ⚡ Palette: Timer should run unless explicitly paused (fixes issue where window focus paused it)
        running: !presentation.paused
        repeat: true
        onTriggered: presentation.advance()
    }

    Slide {
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            // ⚡ Palette: Update pause locks instead of direct assignment
            onEntered: presentation.pauseLocks++
            onExited: presentation.pauseLocks--
            onClicked: {
                presentation.forceActiveFocus()
                presentation.advance()
            }
            z: 1
        }

        Rectangle {
            id: slide1Background
            anchors.centerIn: parent
            width: parent.width * 0.9
            height: slide1Content.height + 60
            color: "#99000000"
            radius: 10
            border.width: presentation.activeFocus ? 2 : 0
            border.color: "#ffffff"
            z: 2

            Text {
                text: "⏸ " + qsTr("Paused")
                color: "white"
                style: Text.Outline
                styleColor: "black"
                opacity: 1.0
                font.bold: true
                font.pixelSize: 14
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 10
                visible: presentation.paused || presentation.activeFocus || nextButton1.activeFocus
                Accessible.role: Accessible.StaticText
                Accessible.name: text
            }

            NumberAnimation on opacity {
                from: 0
                to: 1
                duration: 800
                running: slide1Background.visible
            }

            Column {
                id: slide1Content
                anchors.centerIn: parent
                width: parent.width - 40
                spacing: 20

                Image {
                    source: "welcome.png"
                    width: 200
                    height: 200
                    // ⚡ Bolt: Load images asynchronously to prevent UI jank during slide transitions
                    asynchronous: true
                    cache: true
                    fillMode: Image.PreserveAspectFit
                    anchors.horizontalCenter: parent.horizontalCenter
                    // Accessibility
                    Accessible.role: Accessible.Graphic
                    Accessible.name: qsTr("Welcome to NeOS Logo")
                }

                Text {
                    text: qsTr("Welcome to NeOS")
                    color: "white"
                    style: Text.Outline
                    styleColor: "black"
                    font.pixelSize: 32
                    font.bold: true
                    width: parent.width
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    textFormat: Text.PlainText
                    // Accessibility
                    Accessible.role: Accessible.StaticText
                    Accessible.name: text
                }

                Row {
                    spacing: 10
                    anchors.horizontalCenter: parent.horizontalCenter

                    Rectangle {
                        width: 10
                        height: 10
                        radius: 5
                        color: "white"
                        opacity: 1.0
                        Accessible.role: Accessible.Graphic
                        Accessible.name: qsTr("Slide 1 active")
                    }

                    Rectangle {
                        width: 10
                        height: 10
                        radius: 5
                        color: "white"
                        opacity: 0.5
                        Accessible.role: Accessible.Graphic
                        Accessible.name: qsTr("Slide 2 inactive")
                    }
                }
            }

            Rectangle {
                id: nextButton1
                width: 30
                height: 30
                radius: 15
                // ⚡ Palette: Add keyboard focus support and visual feedback
                activeFocusOnTab: true
                // Update pause state based on focus
                onActiveFocusChanged: {
                    if (activeFocus) {
                        presentation.pauseLocks++
                    } else {
                        presentation.pauseLocks--
                    }
                }

                color: nextMouseArea1.pressed ? "#cccccc" : (nextMouseArea1.containsMouse || activeFocus ? "#eeeeee" : "#ffffff")
                // Add focus ring
                border.width: activeFocus ? 2 : 0
                border.color: "#3daee9"

                scale: nextMouseArea1.containsMouse || activeFocus ? 1.1 : 1.0
                Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
                Behavior on color { ColorAnimation { duration: 200 } }
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 10
                visible: presentation.paused || presentation.activeFocus || activeFocus
                z: 2

                Text {
                    text: "❯"
                    anchors.centerIn: parent
                    color: "black"
                    font.pixelSize: 16
                }

                MouseArea {
                    id: nextMouseArea1
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        presentation.forceActiveFocus()
                        presentation.advance()
                    }
                }

                // Keyboard activation
                Keys.onReturnPressed: presentation.advance()
                Keys.onEnterPressed: presentation.advance()
                Keys.onSpacePressed: presentation.advance()
                Keys.onLeftPressed: presentation.advance()
                Keys.onRightPressed: presentation.advance()

                Accessible.role: Accessible.Button
                Accessible.name: qsTr("Next Slide")
                Accessible.description: qsTr("Advance to the next slide")
            }
        }
    }

    Slide {
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            // ⚡ Palette: Update pause locks instead of direct assignment
            onEntered: presentation.pauseLocks++
            onExited: presentation.pauseLocks--
            onClicked: {
                presentation.forceActiveFocus()
                presentation.advance()
            }
            z: 1
        }

        Rectangle {
            id: slide2Background
            anchors.centerIn: parent
            width: parent.width * 0.9
            height: slide2Content.height + 60
            color: "#99000000"
            radius: 10
            border.width: presentation.activeFocus ? 2 : 0
            border.color: "#ffffff"
            z: 2

            Text {
                text: "⏸ " + qsTr("Paused")
                color: "white"
                style: Text.Outline
                styleColor: "black"
                opacity: 1.0
                font.bold: true
                font.pixelSize: 14
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 10
                visible: presentation.paused || presentation.activeFocus || nextButton2.activeFocus
                Accessible.role: Accessible.StaticText
                Accessible.name: text
            }

            NumberAnimation on opacity {
                from: 0
                to: 1
                duration: 800
                running: slide2Background.visible
            }

            Column {
                id: slide2Content
                anchors.centerIn: parent
                width: parent.width - 40
                spacing: 20

                Image {
                    source: "logo.png"
                    width: 150
                    height: 150
                    // ⚡ Bolt: Load images asynchronously to prevent UI jank during slide transitions
                    asynchronous: true
                    cache: true
                    fillMode: Image.PreserveAspectFit
                    anchors.horizontalCenter: parent.horizontalCenter
                    // Accessibility
                    Accessible.role: Accessible.Graphic
                    Accessible.name: qsTr("NeOS Logo")
                }

                Text {
                    text: qsTr("Fast, Secure, Reliable")
                    color: "white"
                    style: Text.Outline
                    styleColor: "black"
                    font.pixelSize: 24
                    font.bold: true
                    width: parent.width
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    textFormat: Text.PlainText
                    // Accessibility
                    Accessible.role: Accessible.StaticText
                    Accessible.name: text
                }

                Row {
                    spacing: 10
                    anchors.horizontalCenter: parent.horizontalCenter

                    Rectangle {
                        width: 10
                        height: 10
                        radius: 5
                        color: "white"
                        opacity: 0.5
                        Accessible.role: Accessible.Graphic
                        Accessible.name: qsTr("Slide 1 inactive")
                    }

                    Rectangle {
                        width: 10
                        height: 10
                        radius: 5
                        color: "white"
                        opacity: 1.0
                        Accessible.role: Accessible.Graphic
                        Accessible.name: qsTr("Slide 2 active")
                    }
                }
            }

            Rectangle {
                id: nextButton2
                width: 30
                height: 30
                radius: 15
                // ⚡ Palette: Add keyboard focus support and visual feedback
                activeFocusOnTab: true
                // Update pause state based on focus
                onActiveFocusChanged: {
                    if (activeFocus) {
                        presentation.pauseLocks++
                    } else {
                        presentation.pauseLocks--
                    }
                }

                color: nextMouseArea2.pressed ? "#cccccc" : (nextMouseArea2.containsMouse || activeFocus ? "#eeeeee" : "#ffffff")
                // Add focus ring
                border.width: activeFocus ? 2 : 0
                border.color: "#3daee9"

                scale: nextMouseArea2.containsMouse || activeFocus ? 1.1 : 1.0
                Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
                Behavior on color { ColorAnimation { duration: 200 } }
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 10
                visible: presentation.paused || presentation.activeFocus || activeFocus
                z: 2

                Text {
                    text: "❯"
                    anchors.centerIn: parent
                    color: "black"
                    font.pixelSize: 16
                }

                MouseArea {
                    id: nextMouseArea2
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        presentation.forceActiveFocus()
                        presentation.advance()
                    }
                }

                // Keyboard activation
                Keys.onReturnPressed: presentation.advance()
                Keys.onEnterPressed: presentation.advance()
                Keys.onSpacePressed: presentation.advance()
                Keys.onLeftPressed: presentation.advance()
                Keys.onRightPressed: presentation.advance()

                Accessible.role: Accessible.Button
                Accessible.name: qsTr("Next Slide")
                Accessible.description: qsTr("Advance to the next slide")
            }
        }
    }
}
