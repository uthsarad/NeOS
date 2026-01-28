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
        Image {
            source: "welcome.png"
            anchors.centerIn: parent
            width: 200
            height: 200
            fillMode: Image.PreserveAspectFit
        }
        Text {
            anchors.top: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Welcome to NeOS"
            color: "white"
            font.pixelSize: 24
        }
    }
}
