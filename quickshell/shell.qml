import Qt.labs.folderlistmodel
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {  
    // ── Borders ─────────────────────────────────────────────────────

    PanelWindow {
        implicitHeight: 1
        implicitWidth: 2
        color: "#A7C080"
        WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.exclusiveZone: -1

        anchors {
            top: true
            left: true
            bottom: true
        }

    }

    PanelWindow {
        implicitHeight: 2
        implicitWidth: 2
        color: "#A7C080"
        WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.exclusiveZone: -1

        anchors {
            top: false
            left: true
            bottom: true
            right: true
        }

    }

    PanelWindow {
        implicitHeight: 10
        implicitWidth: 3
        color: "#A7C080"
        WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.exclusiveZone: -1

        anchors {
            top: true
            left: false
            bottom: true
            right: true
        }

    }

    PanelWindow {
        implicitHeight: 2
        implicitWidth: 3
        color: "#A7C080"
        WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.exclusiveZone: -1

        anchors {
            top: true
            left: true
            bottom: false
            right: true
        }

    }

}