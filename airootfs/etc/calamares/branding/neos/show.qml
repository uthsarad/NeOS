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
        Column {
            anchors.centerIn: parent
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
                font.pixelSize: 24
                anchors.horizontalCenter: parent.horizontalCenter
                textFormat: Text.PlainText
                // Accessibility
                Accessible.role: Accessible.StaticText
                Accessible.name: text
            }
        }
    }

    Slide {
        Column {
            anchors.centerIn: parent
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
                anchors.horizontalCenter: parent.horizontalCenter
                textFormat: Text.PlainText
                // Accessibility
                Accessible.role: Accessible.StaticText
                Accessible.name: text
            }
        }
    }
}
