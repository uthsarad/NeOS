import QtQuick 2.0;
import Calamares 1.0;

Presentation {
    id: presentation

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: presentation.advance()
    }

    Slide {
        Rectangle {
            id: slide1Background
            anchors.centerIn: parent
            width: parent.width * 0.9
            height: slide1Content.height + 60
            color: "#99000000"
            radius: 10

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
                    fillMode: Image.PreserveAspectFit
                    anchors.horizontalCenter: parent.horizontalCenter
                    // Accessibility
                    Accessible.role: Accessible.Graphic
                    Accessible.name: qsTr("Welcome to NeOS Logo")
                }

                Text {
                    text: qsTr("Welcome to NeOS")
                    color: "white"
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
            }
        }
    }

    Slide {
        Rectangle {
            id: slide2Background
            anchors.centerIn: parent
            width: parent.width * 0.9
            height: slide2Content.height + 60
            color: "#99000000"
            radius: 10

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
                    fillMode: Image.PreserveAspectFit
                    anchors.horizontalCenter: parent.horizontalCenter
                    // Accessibility
                    Accessible.role: Accessible.Graphic
                    Accessible.name: qsTr("NeOS Logo")
                }

                Text {
                    text: qsTr("Fast, Secure, Reliable")
                    color: "white"
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
            }
        }
    }
}
